import 'dart:async';

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bar/keyboard_bar.dart';
import 'bar/keyboard_bar_style.dart';
import 'field/text_input_finder.dart';
import 'keyboard_field.dart';
import 'keyboard_scope.dart';
import 'platform/platform_check.dart';
import 'tap_region.dart';
import 'theme/keyboard_actions_theme.dart';

/// Whether the bar shows previous/next controls.
enum KeyboardNavigation {
  /// Done only (or custom trailing). No arrows.
  none,

  /// Show Prev/Next when there are 2+ focusable fields.
  auto,
}

/// The easiest way to create a professional keyboard experience in Flutter.
///
/// ## Why this design works with ListViews / sheets / dialogs
/// Instead of wrapping your tree in custom scroll padding (the #1 source of
/// layout bugs), [KeyboardActions]:
/// 1. Draws a floating toolbar in an [Overlay]
/// 2. Reserves the toolbar/footer height at the bottom of [child], so the
///    focused field can always clear the bar
/// 3. Optionally calls [Scrollable.ensureVisible] on the focused field
///
/// Keep `Scaffold.resizeToAvoidBottomInset: true` (Flutter's default).
///
/// ## Quick start
/// ```dart
/// KeyboardActions(
///   child: ListView(children: [TextField(), TextField()]),
/// )
/// ```
///
/// Wrap the Scaffold body, a scrollable, or a single field. To also lift a
/// [FloatingActionButton] above the Done bar, wrap the [Scaffold] itself —
/// [KeyboardActions] inflates `viewInsets` so Scaffold resize handles it
/// without a double-spacing gap.
///
/// ```dart
/// KeyboardActions.done(child: TextField(...))
/// ```
///
/// ## Per-field customization
/// ```dart
/// KeyboardField(
///   footer: MyCustomPad(),
///   child: TextField(...),
/// )
/// ```
class KeyboardActions extends StatefulWidget {
  final Widget child;

  /// Prev/Next behavior. Defaults to [KeyboardNavigation.auto].
  final KeyboardNavigation navigation;

  /// Scroll the focused field into view via [Scrollable.ensureVisible].
  final bool ensureVisible;

  /// Alignment passed to [Scrollable.ensureVisible] (0 = top, 1 = bottom).
  final double ensureVisibleAlignment;

  /// Dismiss focus when tapping outside the field / bar.
  ///
  /// Only a real tap dismisses: starting a scroll on the content leaves the
  /// keyboard up, and moving between fields does not close it either.
  /// Dismissing this way also triggers [onDismissed].
  final bool dismissOnTapOutside;

  /// Done button label. Falls back to the theme, then to `'Done'`.
  final String? doneText;

  /// Submit label shown on the last field. Falls back to the theme.
  ///
  /// Submit only appears when [onSubmit] is set, and it replaces Done there:
  /// on the last field, submitting is the primary action.
  final String? submitText;

  /// Called when Submit is pressed. Required for Submit to appear.
  ///
  /// Use this for the form action ("send", "search", "log in"). For a hook that
  /// runs on every dismissal, use [onDismissed].
  final VoidCallback? onSubmit;

  /// Called whenever the keyboard closes, whichever way it closed.
  ///
  /// Fires for Done and for a dismissing tap outside, so read it as "the user
  /// finished with this field". For "the Done button of *this* field was
  /// tapped", use [KeyboardField.onDone], which runs first.
  ///
  /// Does not fire for Submit, which has its own [onSubmit].
  final ValueChanged<FocusNode>? onDismissed;

  /// Appearance overrides for this instance only.
  ///
  /// Values set here win over [KeyboardActionsTheme] and over any
  /// `ThemeData.extensions` entry. For app-wide styling, prefer wrapping your
  /// app in [KeyboardActionsTheme].
  final KeyboardActionsThemeData? theme;

  /// Whether the bar is active.
  ///
  /// - `null` (default): only on iOS and Android, where a soft keyboard needs it
  /// - `true`: always, including desktop and web
  /// - `false`: never (child still builds normally)
  ///
  /// For a custom platform set, compute it at the call site:
  /// `enabled: defaultTargetPlatform == TargetPlatform.iOS`.
  final bool? enabled;

  const KeyboardActions({
    super.key,
    required this.child,
    this.navigation = KeyboardNavigation.auto,
    this.ensureVisible = true,
    this.ensureVisibleAlignment = 0.15,
    this.dismissOnTapOutside = true,
    this.doneText,
    this.submitText,
    this.onSubmit,
    this.onDismissed,
    this.theme,
    this.enabled,
  });

  /// Done-only shortcut (no Prev/Next).
  const KeyboardActions.done({
    super.key,
    required this.child,
    this.ensureVisible = true,
    this.ensureVisibleAlignment = 0.15,
    this.dismissOnTapOutside = true,
    this.doneText,
    this.onDismissed,
    this.theme,
    this.enabled,
  })  : navigation = KeyboardNavigation.none,
        submitText = null,
        onSubmit = null;

  @override
  State<KeyboardActions> createState() => KeyboardActionsState();
}

class KeyboardActionsState extends State<KeyboardActions>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// Override platform gating in tests.
  @visibleForTesting
  static bool? debugForceAvailable;

  /// Matches a soft-keyboard dismiss closely enough to feel native.
  static const _panelAnimDuration = Duration(milliseconds: 250);

  final KeyboardActionsController _controller = KeyboardActionsController();

  OverlayEntry? _overlay;
  KeyboardActionsThemeData? _theme;
  FocusNode? _current;

  /// Outside-tap tracking, used to ignore scrolls and field-to-field taps.
  int? _tapOutsidePointer;
  Offset? _tapOutsideOrigin;
  FocusNode? _tapOutsideFocusBefore;
  PreferredSizeWidget? _footer;
  bool _showing = false;
  double _extraInset = 0;

  /// Drives the slide of the overlay panel (and the reserved inset with it).
  late final AnimationController _panelController;
  late final Animation<double> _panelVisibility;

  /// True while Prev/Next (or an explicit field transfer) is in progress.
  /// Distinguishes "move to another TextField" from "dismiss the keyboard".
  bool _navigating = false;

  Timer? _navUnlockTimer;

  /// Debounces the visibility check until keyboard metrics stop changing.
  Timer? _ensureVisibleTimer;

  /// Bumps when focus changes; cancels stale hide timers from focus gaps.
  int _focusEpoch = 0;

  /// Locked toolbar inset for the current keyboard session (avoids MediaQuery
  /// thrashing when moving between fields).
  double? _sessionInset;

  /// Last non-zero system-keyboard height while the bar is up. Used only when
  /// iOS briefly reports `viewInsets == 0` during field handoff. We do NOT
  /// keep a peak forever (that left the bar floating above shorter keyboards).
  double _sessionKeyboardHeight = 0;

  /// Tallest keyboard measured so far, kept across sessions to predict where
  /// the keyboard will land before its insets finish animating in.
  double _knownKeyboardHeight = 0;

  /// Route hosting this widget, watched so the bar leaves with its page.
  ModalRoute<dynamic>? _route;

  @visibleForTesting
  bool get debugIsShowing => _showing;

  @visibleForTesting
  List<FocusNode> get debugNodes => _orderedNodes();

  bool get _available {
    // Explicit enabled wins over the test override, so `enabled: false` still
    // disables the bar under debugForceAvailable.
    final enabled = widget.enabled;
    if (enabled != null) return enabled;
    if (debugForceAvailable != null) return debugForceAvailable!;
    return PlatformCheck.isIOS || PlatformCheck.isAndroid;
  }

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: _panelAnimDuration,
    );
    _panelVisibility = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _panelController.addListener(_onPanelTick);
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_handleFocusChange);
    _controller.addListener(_handleRegistryChange);
  }

  void _onPanelTick() {
    // Overlay lives outside this subtree; reserved space lives inside it.
    _overlay?.markNeedsBuild();
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == _route) return;
    _detachRoute();
    _route = route;
    route?.animation?.addListener(_handleRouteTransition);
    route?.secondaryAnimation?.addListener(_handleRouteTransition);
  }

  @override
  void dispose() {
    _detachRoute();
    _navUnlockTimer?.cancel();
    _ensureVisibleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_handleFocusChange);
    _controller.removeListener(_handleRegistryChange);
    _panelController.removeListener(_onPanelTick);
    _panelController.dispose();
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _noteSessionKeyboardHeight(_realKeyboardHeight(context));
    // Overlay uses the session-locked height, so rebuilds stay put when iOS
    // briefly dips viewInsets during focus handoff.
    _syncOverlay();
    _recomputeInset();
    _scheduleEnsureVisible();
  }

  /// Check visibility a couple of frames after focus / keyboard changes.
  ///
  /// Just enough delay for layout and the focus handoff to settle;
  /// [_expectedKeyboardHeight] covers the insets that have not arrived yet, so
  /// there is no need to wait for the keyboard animation to finish.
  ///
  /// Pending checks are never postponed by later calls. Otherwise a keyboard
  /// that animates or flickers keeps pushing the correction back.
  void _scheduleEnsureVisible() {
    if (!widget.ensureVisible) return;
    if (_ensureVisibleTimer?.isActive ?? false) return;

    _ensureVisibleTimer = Timer(
      const Duration(milliseconds: 32),
      _ensureVisibleNow,
    );
  }

  /// Lift the focused field above the bar, re-checking after each correction.
  ///
  /// [EditableText] reveals its caret using the viewport bottom, which sits
  /// under our floating bar, so it can scroll the field back down right after
  /// us. Verifying again, a bounded number of times, settles that race.
  Future<void> _ensureVisibleNow([int attempt = 0]) async {
    if (!mounted || !_showing) return;

    final node = _current;
    if (node == null || !_isObscured(node)) return;

    await _scrollTo(node);

    if (!mounted || attempt >= 2) return;
    _ensureVisibleTimer?.cancel();
    _ensureVisibleTimer = Timer(
      const Duration(milliseconds: 150),
      () => _ensureVisibleNow(attempt + 1),
    );
  }

  void _detachRoute() {
    _route?.animation?.removeListener(_handleRouteTransition);
    _route?.secondaryAnimation?.removeListener(_handleRouteTransition);
    _route = null;
  }

  void _handleRouteTransition() {
    // The overlay lives in the Navigator's Overlay, above every route, so it
    // cannot be animated by the page transition; repaint it ourselves.
    _overlay?.markNeedsBuild();
  }

  /// 1 while the page is settled, falling to 0 as it leaves or gets covered.
  double get _routeVisibility {
    final route = _route;
    if (route == null) return 1;
    final leaving = route.animation?.value ?? 1;
    final covered = route.secondaryAnimation?.value ?? 0;
    return (leaving * (1 - covered)).clamp(0.0, 1.0);
  }

  void _handleRegistryChange() {
    if (_current != null) {
      _syncOverlay();
      _recomputeInset();
    }
  }

  void _handleFocusChange() {
    if (!_available || !mounted) return;
    _focusEpoch++;

    final focused = _focusedManagedNode();
    if (focused != null) {
      // During arrow navigation the overlay stays up; only refresh arrows.
      if (_navigating) {
        _current = focused;
        _footer = _fieldFor(focused)?.footerOf(context);
        _syncOverlay();
        return;
      }
      if (identical(_current, focused) && _showing) {
        _syncOverlay();
        return;
      }
      // Tap / focus move between managed fields: treat as a field transfer so
      // we do not tear down the bar / keyboard session.
      if (_showing && _current != null) {
        _beginFieldTransfer();
        _current = focused;
        _footer = _fieldFor(focused)?.footerOf(context);
        _showing =
            (_fieldFor(focused)?.widget.showBar ?? true) || _footer != null;
        _syncOverlay();
        _recomputeInset();
        _keepKeyboardAlive(focused);
        _navUnlockTimer?.cancel();
        _navUnlockTimer = Timer(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          _navigating = false;
        });
        if (widget.ensureVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_isObscured(focused)) _scrollTo(focused);
          });
        }
        return;
      }
      _showFor(focused);
      return;
    }

    // No managed text field focused. During Prev/Next, ignore the gap.
    if (_navigating || !_showing) return;

    // Focus handoff briefly reports null. Wait before tearing down so the
    // keyboard/bar do not bounce when jumping between TextFields. Custom
    // panels have no OS keyboard to cover the gap — hide almost immediately
    // so Done / unfocus can start the slide without a visible pause.
    final epoch = _focusEpoch;
    final delay = _footer != null
        ? const Duration(milliseconds: 50)
        : const Duration(milliseconds: 280);
    Future<void>.delayed(delay, () {
      if (!mounted || _navigating || epoch != _focusEpoch) return;
      if (_focusedManagedNode() == null) _hide();
    });
  }

  /// Records where an outside tap started, so [_onTapOutsideUp] can tell a tap
  /// from a scroll.
  void _onTapOutsideDown(PointerDownEvent event) {
    if (!widget.dismissOnTapOutside || _navigating || !_showing) return;
    _tapOutsidePointer = event.pointer;
    _tapOutsideOrigin = event.position;
    _tapOutsideFocusBefore = _current;
  }

  /// Dismiss on release, and only for a real tap on neutral space.
  ///
  /// Waiting for pointer-up matters twice over. Dismissing on pointer-down
  /// would close the keyboard as soon as a scroll begins, and taps on a
  /// TextField's decoration count as "outside" the EditableText region, so
  /// focus needs a frame to settle on the field the user actually aimed at.
  void _onTapOutsideUp(PointerUpEvent event) {
    final origin = _tapOutsideOrigin;
    final pointer = _tapOutsidePointer;
    final focusBefore = _tapOutsideFocusBefore;
    _tapOutsideOrigin = null;
    _tapOutsidePointer = null;
    _tapOutsideFocusBefore = null;

    if (!widget.dismissOnTapOutside || !_showing) return;
    if (origin == null || pointer != event.pointer) return;
    // Moved too far: this was a drag or a scroll, not a tap.
    if ((event.position - origin).distance > kTouchSlop) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _navigating) return;
      // Focus landed on a different managed field: a field-to-field tap.
      final focused = _focusedManagedNode();
      if (focused != null && focused != focusBefore) return;
      _dismiss();
    });
    // A post-frame callback does not request a frame. Tapping inert space
    // rebuilds nothing, so without this the callback would never run.
    WidgetsBinding.instance.scheduleFrame();
  }

  FocusNode? _focusedManagedNode() {
    final nodes = _orderedNodes();
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && nodes.contains(primary)) return primary;
    for (final node in nodes) {
      if (node.hasFocus) return node;
    }
    return null;
  }

  List<FocusNode> _orderedNodes() {
    if (!mounted) return const [];

    final nodes = TextInputFinder.find(context);

    // Include custom inputs registered via KeyboardField (not EditableText).
    for (final field in _controller.fields) {
      final node = field.effectiveFocusNode;
      if (node != null && node.canRequestFocus && !nodes.contains(node)) {
        nodes.add(node);
      }
    }

    // Visual top-to-bottom order, reliable inside ListView / sheets.
    nodes.sort((a, b) => _nodeOffset(a).compareTo(_nodeOffset(b)));
    return nodes;
  }

  double _nodeOffset(FocusNode node) {
    final box = node.context?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return double.infinity;
    return box.localToGlobal(Offset.zero).dy;
  }

  KeyboardFieldState? _fieldFor(FocusNode node) => _controller.fieldFor(node);

  void _showFor(FocusNode node) {
    final field = _fieldFor(node);
    _current = node;
    _footer = field?.footerOf(context);
    _showing = (field?.widget.showBar ?? true) || _footer != null;

    // A KeyboardCustomInput is focusable but has no EditableText connection.
    // Explicitly close any system keyboard left by the previous field/page.
    if (_editableStateFor(node) == null) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }

    final inserted = _overlay == null;
    if (inserted) {
      _overlay = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context).insert(_overlay!);
    } else {
      _overlay!.markNeedsBuild();
    }

    // Only touch MediaQuery when the inset actually changes. Recreating
    // MediaQuery on every field change makes the iOS keyboard bounce.
    _recomputeInset();

    // Custom panels slide up like a soft keyboard. The system-keyboard bar
    // snaps on: it rides viewInsets as the OS keyboard rises.
    // Field-to-field transfers keep the panel parked at full visibility.
    if (_showing &&
        (inserted ||
            _panelController.isDismissed ||
            _panelController.status == AnimationStatus.reverse)) {
      if (_footer != null) {
        _panelController.forward();
      } else {
        _panelController.value = 1;
      }
    }

    // Scroll if the field will end up covered once the keyboard is fully up.
    _scheduleEnsureVisible();
  }

  void _hide() {
    if (!_showing && _panelController.isDismissed) return;

    final animate = _footer != null;
    _showing = false;
    _current = null;
    _sessionInset = null;
    _sessionKeyboardHeight = 0;
    // Keep [_footer] until the slide finishes so the panel still paints.

    if (_overlay == null || _panelController.isDismissed || !animate) {
      _finishHide();
      return;
    }

    _panelController.reverse().whenComplete(() {
      if (!mounted || _showing) return;
      _finishHide();
    });
  }

  void _finishHide() {
    _footer = null;
    _extraInset = 0;
    _removeOverlay();
    if (_panelController.value != 0) {
      _panelController.value = 0;
    }
    if (mounted) setState(() {});
  }

  void _noteSessionKeyboardHeight(double live) {
    if (live > _knownKeyboardHeight) _knownKeyboardHeight = live;
    if (!_showing) return;
    // Follow the real keyboard whenever it is visible (email ↔ phone, etc.).
    // Only freeze on transient 0 so the bar does not dive behind the keyboard.
    if (live > 0) {
      _sessionKeyboardHeight = live;
    }
  }

  /// Keyboard height to scroll against, including the one still animating in.
  ///
  /// `viewInsets` grows frame by frame while the keyboard rises, so scrolling
  /// against the live value lands short and needs several corrections. Reusing
  /// the height measured earlier lets the field move in a single motion.
  double _expectedKeyboardHeight() {
    final live = _overlayKeyboardHeight(context);
    if (live > 0) return live;

    final node = _current;
    final systemKeyboardExpected =
        node != null && _editableStateFor(node) != null;
    return systemKeyboardExpected ? _knownKeyboardHeight : 0;
  }

  /// Keyboard height used to park the overlay.
  double _overlayKeyboardHeight(BuildContext overlayContext) {
    final live = _realKeyboardHeight(overlayContext);
    _noteSessionKeyboardHeight(live);
    if (live > 0) return live;
    if (_showing && _sessionKeyboardHeight > 0) return _sessionKeyboardHeight;
    return 0;
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _syncOverlay() => _overlay?.markNeedsBuild();

  /// Ambient theme (inherited widget + `ThemeData` extension) with
  /// [KeyboardActions.theme] layered on top.
  ///
  /// Resolved during [build] so the inherited dependency is registered and the
  /// overlay, which lives outside this subtree, can be refreshed on change.
  KeyboardActionsThemeData? _resolveTheme(BuildContext context) {
    final ambient = KeyboardActionsTheme.maybeOf(context);
    if (ambient == null) return widget.theme;
    return ambient.merge(widget.theme);
  }

  /// Caches the resolved theme and refreshes the overlay when it changes.
  ///
  /// The bar lives in an [Overlay], so it is not rebuilt by our own rebuild.
  /// A new bar height also changes the inset we add to `viewInsets`.
  void _syncTheme(BuildContext context) {
    final resolved = _resolveTheme(context);
    if (resolved == _theme) return;
    _theme = resolved;
    if (!_showing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _recomputeInset();
      _syncOverlay();
    });
  }

  double _barBlockHeight({
    required bool keyboardShowing,
    double safeBottom = 0,
  }) {
    final field = _current != null ? _fieldFor(_current!) : null;
    final showBar = field?.widget.showBar ?? true;
    final style = KeyboardBarStyle.resolve(
      context,
      theme: _theme,
      keyboardShowing: keyboardShowing,
    );

    var extra = 0.0;
    if (showBar) extra += style.height + style.keyboardGap;
    if (_footer != null) {
      extra += _footer!.preferredSize.height;
      // Custom panels sit on the bottom edge; pad for home indicator.
      if (!keyboardShowing) extra += safeBottom;
    }
    return extra;
  }

  void _recomputeInset() {
    if (!mounted) return;

    if (!_showing) {
      // During the dismiss slide, keep [_extraInset] so reserved space can
      // shrink with [_panelVisibility] instead of jumping to zero.
      if (_panelController.isDismissed && _extraInset != 0) {
        setState(() => _extraInset = 0);
      }
      return;
    }

    // Treat keyboard as showing if live insets exist, or we are holding the
    // last height across a transient 0 during focus handoff.
    final liveKeyboard = MediaQuery.viewInsetsOf(context).bottom;
    _noteSessionKeyboardHeight(liveKeyboard);
    final keyboardShowing = liveKeyboard > 0 || _sessionKeyboardHeight > 0;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    final needed = _barBlockHeight(
      keyboardShowing: keyboardShowing,
      safeBottom: safeBottom,
    );

    // Lock session inset: grow if a taller footer appears, never shrink while
    // moving between fields (prevents Scaffold resize ↔ scroll fights).
    final locked = _sessionInset == null
        ? needed
        : (needed > _sessionInset! ? needed : _sessionInset!);
    _sessionInset = locked;

    if (locked != _extraInset) {
      setState(() => _extraInset = locked);
    }
  }

  /// Whether [node]'s field is covered by the keyboard + action bar.
  bool _isObscured(FocusNode node) {
    final ctx = _scrollTargetContext(node);
    if (ctx == null || !ctx.mounted) return false;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return false;

    final fieldBottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    return fieldBottom > _visibleBottom;
  }

  double get _visibleBottom {
    // Scaffold consumes/removes viewInsets from the MediaQuery it gives its
    // body. Reading MediaQuery here can therefore report keyboard height 0
    // even though the keyboard is visible. Use the root View, matching the
    // overlay positioning logic.
    final view = View.of(context);
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    return screenHeight - _expectedKeyboardHeight() - _extraInset - 12;
  }

  Future<void> _scrollTo(FocusNode node) async {
    final ctx = _scrollTargetContext(node);
    if (ctx == null || !ctx.mounted) return;

    final box = ctx.findRenderObject() as RenderBox?;
    // EditableText owns an internal horizontal Scrollable. Without the axis
    // filter we adjust that one instead of the surrounding ListView.
    final scrollable = Scrollable.maybeOf(ctx, axis: Axis.vertical);
    if (box != null && box.attached && box.hasSize && scrollable != null) {
      final fieldBottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      final overlap = fieldBottom - _visibleBottom;
      if (overlap > 0) {
        final position = scrollable.position;
        final direction = position.axisDirection;
        final delta = direction == AxisDirection.up ? -overlap : overlap;
        final target = (position.pixels + delta)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();

        if (target != position.pixels) {
          await position.animateTo(
            target,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
          return;
        }
      }
    }

    // Fallback for unusual/nested scrollables where direct correction cannot
    // be applied to the nearest vertical position.
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: widget.ensureVisibleAlignment,
      // Move only enough to reveal the field. Explicit alignment causes a
      // large, delayed-looking jump for the last multiline field.
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  /// The focus context belongs to the inner [EditableText], whose render box
  /// can be only one line tall even when the decorated field is multiline.
  /// Measure/scroll the enclosing [InputDecorator] so labels, errors, and the
  /// complete field remain above the keyboard action bar.
  BuildContext? _scrollTargetContext(FocusNode node) {
    final focusContext = node.context;
    if (focusContext == null || !focusContext.mounted) return null;

    Element? decorator;
    (focusContext as Element).visitAncestorElements((element) {
      if (element.widget is InputDecorator) {
        decorator = element;
        return false;
      }
      return true;
    });
    return decorator ?? focusContext;
  }

  double _realKeyboardHeight(BuildContext overlayContext) {
    final view = View.of(overlayContext);
    return EdgeInsets.fromViewPadding(
      view.viewInsets,
      view.devicePixelRatio,
    ).bottom;
  }

  int get _index {
    final node = _current;
    if (node == null) return -1;
    return _orderedNodes().indexOf(node);
  }

  bool get _isLast {
    final nodes = _orderedNodes();
    return nodes.isNotEmpty && _index == nodes.length - 1;
  }

  void _goPrevious() {
    final nodes = _orderedNodes();
    final i = _index;
    if (i > 0) _navigateTo(nodes[i - 1]);
  }

  void _goNext() {
    final nodes = _orderedNodes();
    final i = _index;
    if (i >= 0 && i < nodes.length - 1) _navigateTo(nodes[i + 1]);
  }

  /// Move focus to another managed field without dismissing the keyboard.
  ///
  /// This is the "field transfer" path (vs Done / tap-outside which close it).
  void _navigateTo(FocusNode next) {
    _beginFieldTransfer();
    _current = next;
    _footer = _fieldFor(next)?.footerOf(context);
    _showing = (_fieldFor(next)?.widget.showBar ?? true) || _footer != null;
    _overlay?.markNeedsBuild();
    // Keep MediaQuery stable; avoid setState unless the bar block grows.
    _recomputeInset();

    // Prefer scope requestFocus so Flutter treats it as a focus move, not a
    // blur+focus that tears down the platform text input connection.
    final focusContext = next.context ?? context;
    FocusScope.of(focusContext).requestFocus(next);
    _keepKeyboardAlive(next);

    // Scroll as part of the transfer instead of waiting for the navigation
    // guard or for keyboard metrics to settle (both feel sluggish).
    _scheduleEnsureVisible();

    // Hold the transfer flag long enough for iOS to swap keyboard types
    // without our overlay/hide logic treating it as a dismiss.
    _navUnlockTimer?.cancel();
    _navUnlockTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _navigating = false;
      final focused = _focusedManagedNode() ?? next;
      _current = focused;
      _footer = _fieldFor(focused)?.footerOf(context);
      _overlay?.markNeedsBuild();
    });
  }

  void _beginFieldTransfer() {
    _navigating = true;
    _focusEpoch++; // cancel any pending hide from a focus gap
  }

  /// Ask the platform to keep / restore the soft keyboard during a transfer.
  void _keepKeyboardAlive(FocusNode node) {
    final editable = _editableStateFor(node);
    if (editable == null) {
      // Custom input: its footer is the keyboard. Never resurrect the last
      // system keyboard while transferring focus with Prev/Next.
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      return;
    }

    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !editable.mounted) return;
      editable.requestKeyboard();
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  EditableTextState? _editableStateFor(FocusNode node) {
    final ctx = node.context;
    if (ctx == null) return null;
    return ctx.findAncestorStateOfType<EditableTextState>();
  }

  void _dismiss() {
    // Done is an explicit dismiss; cancel any in-flight field transfer.
    _navUnlockTimer?.cancel();
    _navigating = false;
    final node = _current;
    // Custom panels have no OS keyboard to ride; slide them out now.
    // System-keyboard bars keep following viewInsets — the focus listener
    // tears the overlay down after the focus-gap debounce.
    final customPanel = _footer != null;
    if (node != null) {
      _fieldFor(node)?.widget.onDone?.call();
      widget.onDismissed?.call(node);
      node.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (customPanel) _hide();
  }

  void _onSubmit() {
    final customPanel = _footer != null;
    widget.onSubmit?.call();
    _current?.unfocus();
    if (customPanel) _hide();
  }

  Widget _buildOverlay(BuildContext context) {
    final routeVisibility = _routeVisibility;
    final panelVisibility = _panelVisibility.value;
    if (routeVisibility == 0 || panelVisibility == 0) {
      return const SizedBox.shrink();
    }

    final keyboardHeight = _overlayKeyboardHeight(context);
    final keyboardShowing = keyboardHeight > 0;
    final safeBottom =
        keyboardShowing ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;
    final field = _current != null ? _fieldFor(_current!) : null;
    final showBar = field?.widget.showBar ?? true;
    final nodes = _orderedNodes();
    final index = _index;

    // Resolve against the KeyboardActions context, not the overlay context:
    // the overlay lives above any KeyboardActionsTheme the user wrapped.
    final themeData = _theme;
    final style = KeyboardBarStyle.resolve(
      this.context,
      theme: themeData,
      keyboardShowing: keyboardShowing,
    );

    final showNav = widget.navigation == KeyboardNavigation.auto &&
        nodes.length > 1 &&
        (field?.widget.showArrows ?? true);

    final bottom = keyboardHeight + (showBar ? style.keyboardGap : 0);

    // Submit is the primary action on the last field, so it takes Done's place
    // instead of sitting next to it.
    final showSubmit = _isLast && widget.onSubmit != null;

    final panel = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBar)
          KeyboardBar(
            style: style,
            showNavigation: showNav,
            canGoPrevious: index > 0,
            canGoNext: index >= 0 && index < nodes.length - 1,
            showDone: (field?.widget.showDone ?? true) && !showSubmit,
            showSubmit: showSubmit,
            doneText: widget.doneText ?? themeData?.doneText ?? 'Done',
            submitText: widget.submitText ?? themeData?.submitText ?? 'Submit',
            trailingButtons: field?.widget.toolbarButtons,
            focusNode: _current,
            onPrevious: _goPrevious,
            onNext: _goNext,
            onDone: _dismiss,
            onSubmit: _onSubmit,
          ),
        if (_footer != null)
          Padding(
            padding: EdgeInsets.only(bottom: safeBottom),
            child: _footer!,
          ),
      ],
    );

    // No opaque full-screen barrier: it steals taps meant for other TextFields
    // (dialogs / forms) and forces a second tap to refocus. TapRegion reports
    // outside taps without blocking hit-testing underneath.
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          // ExcludeFocus: InkWell/buttons must not steal focus from the field
          // (that rebuilds the overlay mid-gesture and drops onTap).
          child: ExcludeFocus(
            child: TextFieldTapRegion(
              onTapOutside:
                  widget.dismissOnTapOutside ? _onTapOutsideDown : null,
              onTapUpOutside:
                  widget.dismissOnTapOutside ? _onTapOutsideUp : null,
              child: TapRegion(
                groupId: KeyboardActionsTapRegion.groupId,
                // Slide like a soft keyboard: panelVisibility for show/hide,
                // routeVisibility so the bar leaves with its page too.
                child: FractionalTranslation(
                  translation: Offset(
                    0,
                    1 - (routeVisibility * panelVisibility),
                  ),
                  child: Opacity(
                    opacity: routeVisibility * panelVisibility,
                    child: panel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncTheme(context);

    // Shrink reserved space with the slide so content rises with the panel.
    final inset =
        _available ? _extraInset * _panelVisibility.value : 0.0;
    final media = MediaQuery.of(context);

    // Always inflate viewInsets so a child Scaffold / Dialog / BottomSheet
    // (resizeToAvoidBottomInset) lifts body + FAB above the Done bar.
    //
    // Also add real Padding when we are *already inside* a Scaffold: that
    // ancestor has typically consumed the system keyboard insets, and
    // ListView pads from MediaQuery.padding — not viewInsets — so without
    // Padding the last field stays behind the bar.
    //
    // Do NOT pad when wrapping a Scaffold: Padding + Scaffold resize would
    // apply the bar height twice and leave a gap above the Done bar (#267).
    final insideScaffold = Scaffold.maybeOf(context) != null;
    Widget child = widget.child;
    // Keep this wrapper in the tree even when [inset] is zero. Adding it only
    // when the bar appears would reparent/remount [child]; TextFields using
    // their internal FocusNode would then lose focus and close the keyboard.
    if (insideScaffold) {
      child = Padding(
        padding: EdgeInsets.only(bottom: inset),
        child: child,
      );
    }

    return KeyboardActionsScope(
      controller: _controller,
      child: MediaQuery(
        data: media.copyWith(
          viewInsets: media.viewInsets.copyWith(
            bottom: media.viewInsets.bottom + inset,
          ),
        ),
        child: child,
      ),
    );
  }
}
