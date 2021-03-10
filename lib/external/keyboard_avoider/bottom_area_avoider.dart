import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Helps [child] stay visible by resizing it to avoid the given [areaToAvoid].
///
/// Wraps the [child] in a [AnimatedContainer] that adjusts its bottom [padding] to accommodate the given area.
///
/// If [autoScroll] is true and the [child] contains a focused widget such as a [TextField],
/// automatically scrolls so that it is just visible above the keyboard, plus any additional [overscroll].
class BottomAreaAvoider extends StatefulWidget {
  static const Duration defaultDuration = Duration(milliseconds: 100);
  static const Curve defaultCurve = Curves.easeIn;
  static const double defaultOverscroll = 12.0;
  static const bool defaultAutoScroll = false;

  /// The child to embed.
  ///
  /// If the [child] is not a [ScrollView], it is automatically embedded in a [SingleChildScrollView].
  /// If the [child] is a [ScrollView], it must have a [ScrollController].
  final Widget? child;

  /// Amount of bottom area to avoid. For example, the height of the currently-showing system keyboard, or
  /// any custom bottom overlays.
  final double areaToAvoid;

  /// Whether to auto-scroll to the focused widget after the keyboard appears. Defaults to false.
  /// Could be expensive because it searches all the child objects in this widget's render tree.
  final bool autoScroll;

  /// Extra amount to scroll past the focused widget. Defaults to [defaultOverscroll].
  /// Useful in case the focused widget is inside a parent widget that you also want to be visible.
  final double overscroll;

  /// Duration of the resize animation. Defaults to [defaultDuration]. To disable, set to [Duration.zero].
  final Duration duration;

  /// Animation curve. Defaults to [defaultCurve]
  final Curve curve;

  /// The [ScrollPhysics] of the [SingleChildScrollView] which contains child
  final ScrollPhysics? physics;

  BottomAreaAvoider(
      {Key? key,
      required this.child,
      required this.areaToAvoid,
      this.autoScroll = false,
      this.duration = defaultDuration,
      this.curve = defaultCurve,
      this.overscroll = defaultOverscroll,
      this.physics})
      : //assert(child is ScrollView ? child.controller != null : true),
        assert(areaToAvoid >= 0, 'Cannot avoid a negative area'),
        super(key: key);

  BottomAreaAvoiderState createState() => BottomAreaAvoiderState();
}

class BottomAreaAvoiderState extends State<BottomAreaAvoider> {
  final _animationKey = new GlobalKey<ImplicitlyAnimatedWidgetState>();
  Function(AnimationStatus)? _animationListener;
  ScrollController? _scrollController;
  late double _previousAreaToAvoid;

  @override
  void didUpdateWidget(BottomAreaAvoider oldWidget) {
    _previousAreaToAvoid = oldWidget.areaToAvoid;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationKey.currentState?.animation
        .removeStatusListener(_animationListener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add a status listener to the animation after the initial build.
    // Wait a frame so that _animationKey.currentState is not null.
    if (_animationListener == null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _animationListener = _paddingAnimationStatusChanged;
        _animationKey.currentState?.animation
            .addStatusListener(_animationListener!);
      });
    }

    // If [child] is a [ScrollView], get its [ScrollController]
    // and embed the [child] directly in an [AnimatedContainer].
    if (widget.child is ScrollView) {
      var scrollView = widget.child as ScrollView;
      _scrollController =
          scrollView.controller ?? PrimaryScrollController.of(context);
      return _buildAnimatedContainer(widget.child);
    }
    // If [child] is not a [ScrollView], and [autoScroll] is true,
    // embed the [child] in a [SingleChildScrollView] to make
    // it possible to scroll to the focused widget.
    if (widget.autoScroll) {
      _scrollController = new ScrollController();
      return _buildAnimatedContainer(
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: widget.physics,
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: widget.child,
              ),
            );
          },
        ),
      );
    }
    // Just embed the [child] directly in an [AnimatedContainer].
    return _buildAnimatedContainer(widget.child);
  }

  Widget _buildAnimatedContainer(Widget? child) {
    return AnimatedContainer(
      key: _animationKey,
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: widget.areaToAvoid),
      duration: widget.duration,
      curve: widget.curve,
      child: child,
    );
  }

  /// Called whenever the status of our padding animation changes.
  ///
  /// If the animation has completed, we added overlap, and scroll is on, scroll to that.
  void _paddingAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return; // Only check when the animation is finishing
    }
    if (!widget.autoScroll) {
      return; // auto scroll is not enabled, do nothing
    }
    if (widget.areaToAvoid <= _previousAreaToAvoid) {
      return; // decreased-- do nothing. We only scroll when area to avoid is added (keyboard shown).
    }
    // Need to wait a frame to get the new size (todo: is this still needed? we dont use mediaquery anymore)
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) {
        return; // context is no longer valid
      }
      scrollToOverscroll();
    });
  }

  void scrollToOverscroll() {
    final focused = findFocusedObject(context.findRenderObject());
    if (focused == null) return;
    scrollToObject(focused, _scrollController!, widget.duration, widget.curve,
        widget.overscroll);
  }
}

/// Utility helper methods

/// Finds the first focused focused child of [root] using a breadth-first search.
RenderObject? findFocusedObject(RenderObject? root) {
  final q = Queue<RenderObject?>();
  q.add(root);
  while (q.isNotEmpty) {
    final node = q.removeFirst()!;
    final config = SemanticsConfiguration();
    //ignore: invalid_use_of_protected_member
    node.describeSemanticsConfiguration(config);
    if (config.isFocused) {
      return node;
    }
    node.visitChildrenForSemantics((child) {
      q.add(child);
    });
  }
  return null;
}

/// Scroll to the given [object], which must be inside [scrollController]s viewport.
scrollToObject(RenderObject object, ScrollController scrollController,
    Duration duration, Curve curve, double overscroll) {
  // Calculate the offset needed to show the object in the [ScrollView]
  // so that its bottom touches the top of the keyboard.
  final viewport = RenderAbstractViewport.of(object)!;
  final offset = viewport.getOffsetToReveal(object, 1.0).offset + overscroll;

  // If the object is covered by the keyboard, scroll to reveal it,
  // and add [focusPadding] between it and top of the keyboard.
  if (offset > scrollController.position.pixels) {
    scrollController.position.moveTo(
      offset,
      duration: duration,
      curve: curve,
    );
  }
}
