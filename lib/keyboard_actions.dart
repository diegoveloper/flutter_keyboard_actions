import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

const double _kBarSize = 45.0;

enum KeyboardActionsPlatform {
  ANDROID,
  IOS,
  ALL,
}

class KeyboardAction {
  /// The Focus object coupled to TextField, listening for got/lost focus events
  final FocusNode focusNode;

  /// Optional callback if the button for TextField was tapped
  final VoidCallback onTapAction;

  /// Optional widget to display to the right of the bar
  final Widget closeWidget;

  /// true [default] to display a closeWidget
  final bool displayCloseWidget;

  /// true [default] if the TextField is enabled
  final bool enabled;

  const KeyboardAction({
    @required this.focusNode,
    this.onTapAction,
    this.closeWidget,
    this.enabled = true,
    this.displayCloseWidget = true,
  });
}

/// Wrapper for a single configuration of the keyboard actions bar.
class KeyboardActionsConfig {
  /// Keyboard Action for specific platform
  /// KeyboardActionsPlatform : ANDROID , IOS , ALL
  final KeyboardActionsPlatform keyboardActionsPlatform;

  /// true to display arrows prev/next to move focus between inputs
  final bool nextFocus;

  /// KeyboardAction for each input
  final List<KeyboardAction> actions;

  /// Color of the background to the Custom keyboard buttons
  final Color keyboardBarColor;

  const KeyboardActionsConfig({
    this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
    this.nextFocus = true,
    this.actions,
    this.keyboardBarColor});
}

/// A widget that shows a bar of actions above the keyboard, to help customize input.
///
/// To use this class, add it somewhere higher up in your widget hierarchy. Then, from any child
/// widgets, call [FormKeyboardActions.setKeyboardActions] to configure it with the [KeyboardAction]s you'd
/// like to use. These will be displayed whenever the wrapped focus nodes are selected.
///
/// This widget wraps a [KeyboardAvoider], which takes over functionality from [Scaffold]: when the
/// keyboard appears, this class re-sizes [child] to still be visible, and scrolls to the focused node.
/// **As such, set [Scaffold.resizeToAvoidBottomInset] to _false_ when using this Widget.**
///
/// We manage resizing ourselves so that:
///
///   1. using scaffold is not required
///   2. content is only shrunk as needed (a problem with scaffold)
///   3. we shrink an additional [_kBarSize] so the keyboard action bar doesn't cover content either.
class FormKeyboardActions extends StatefulWidget {

  /// Any content you want to resize/scroll when the keyboard comes up
  final Widget child;

  // If you want the content to auto-scroll when focused; see [KeyboardAvoider.autoScroll]
  final bool autoScroll;

  const FormKeyboardActions({this.child, this.autoScroll = true})
      : assert(child != null);

  /// Configure the nearest [FormKeyboardActions]. Call in [State.initState], or any time.
  static void setKeyboardActions(BuildContext context, KeyboardActionsConfig config) {
    final _FormKeyboardActionsState state = context.ancestorStateOfType(const TypeMatcher<_FormKeyboardActionsState>());

    if (state == null) {
      throw FlutterError(
          'Context does not contain a FormKeyboardActions ancestor: see Scaffold.of for reference.');
    }
    state.setConfig(config);
  }

  @override
  _FormKeyboardActionsState createState() => _FormKeyboardActionsState();
}

/// State class for [FormKeyboardActions]. 
/// 
/// Can be accessed statically via [] and [] to update with the latest and greatest [KeyboardActionsConfig].
class _FormKeyboardActionsState extends State<FormKeyboardActions>
    with WidgetsBindingObserver {

  /// The currently configured keyboard actions
  KeyboardActionsConfig config;

  /// private state
  Map<int, KeyboardAction> _map = Map();
  KeyboardAction _currentAction;
  int _currentIndex = 0;
  OverlayEntry _overlayEntry;

  /// If the keyboard bar is on for the current platform
  bool get _isAvailable {
        return config.keyboardActionsPlatform ==
        KeyboardActionsPlatform.ALL ||
        (config.keyboardActionsPlatform == KeyboardActionsPlatform.IOS &&
            defaultTargetPlatform == TargetPlatform.iOS) ||
        (config.keyboardActionsPlatform == KeyboardActionsPlatform.ANDROID &&
            defaultTargetPlatform == TargetPlatform.android);
  }

  /// If we are currently showing the keyboard bar
  bool get _isShowing {
    return _overlayEntry != null;
  }

  /// The current previous index, or null if none.
  int get _previousIndex {
    final nextIndex = _currentIndex - 1;
    return nextIndex >= 0 ? nextIndex : null;
  }

  /// The current next index, or null if none.
  int get _nextIndex {
    final nextIndex = _currentIndex + 1;
    return nextIndex < _map.length ? nextIndex : null;
  }

  /// Set the config for the keyboard action bar. Subscribe to focus listeners.
  setConfig(KeyboardActionsConfig newConfig) {
    clearConfig(); // remove any existing config
    config = newConfig;
    for (int i = 0; i < config.actions.length; i++) {
        _addAction(i, config.actions[i]);
    }
    _startListeningFocus();
  }

  /// Clear any existing configuration. Unsubscribe from focus listeners.
  clearConfig() {
    _dismissListeningFocus();
    _clearAllFocusNode();
    config = null;
  }

  _addAction(int index, KeyboardAction action) {
    _map[index] = action;
  }

  _clearAllFocusNode() {
    _map = Map();
  }

  _clearFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future<Null> _focusNodeListener() async {
    bool hasFocusFound = false;
    _map.keys.forEach((key) {
      final currentAction = _map[key];
      if (currentAction.focusNode != null && currentAction.focusNode.hasFocus) {
        hasFocusFound = true;
        _currentAction = currentAction;
        _currentIndex = key;
        return;
      }
    });
    _showBar(hasFocusFound);
  }

  _shouldGoToNextFocus(KeyboardAction action, int nextIndex) {
    if (action.focusNode != null) {
      _currentAction = action;
      _currentIndex = nextIndex;
      FocusScope.of(context).requestFocus(_currentAction.focusNode);
      _showBar(true);
    }
  }

  _onTapUp() {
    if (_previousIndex != null) {
      final currentAction = _map[_previousIndex];
      if (currentAction.enabled) {
        _shouldGoToNextFocus(currentAction, _previousIndex);
      } else if (currentAction != null) {
        _currentIndex = _previousIndex;
        _onTapUp();
      }
    }
  }

  _onTapDown() {
    if (_nextIndex != null) {
      final currentAction = _map[_nextIndex];
      if (currentAction.enabled) {
        _shouldGoToNextFocus(currentAction, _nextIndex);
      } else {
        _currentIndex = _nextIndex;
        _onTapDown();
      }
    }
  }

  /// Show or hide the keyboard bar. Calls setState to rebuild the UI appropriately.
  _showBar(bool showBar) {
    if (showBar && !_isShowing) {
      _insertOverlay();
    } else if (!showBar && _isShowing) {
      _removeOverlay();
    }

    // Call setState to update [KeyboardAvoider] to use correct padding, and call markNeedsRebuild on the
    // overlay to update it with the most recent state as well.
    setState(() {
      if (_overlayEntry != null) {
        _overlayEntry.markNeedsBuild(); // rebuild the overlay to show correct focus state
      }
    });
  }

  _startListeningFocus() {
    _map.values
        .forEach((action) => action.focusNode.addListener(_focusNodeListener));
  }

  _dismissListeningFocus() {
    _map.values.forEach(
            (action) => action.focusNode.removeListener(_focusNodeListener));
  }

  /// Insert the keyboard bar as an Overlay.
  ///
  /// This will be inserted above everything else in the MaterialApp, including dialog modals.
  ///
  /// Position the overlay based on the current [MediaQuery] to land above the keyboard.
  void _insertOverlay() {
    OverlayState os = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        right: 0,
        height: _kBarSize,
        child: _buildBar(),
      );
    });
    os.insert(_overlayEntry);
  }

  /// Remove the keyboard overlay bar. Call when losing focus or being dismissed.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (state == AppLifecycleState.paused) {
        FocusScope.of(context).requestFocus(FocusNode());
        _showBar(false);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    clearConfig();
    _removeOverlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  /// Build the keyboard action bar based on the current [config].
  Widget _buildBar() {
    return Material(
      child: AnimatedCrossFade(
        duration: Duration(milliseconds: 180),
        crossFadeState: _isShowing
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Container(
          height: _kBarSize,
          color: config.keyboardBarColor ?? Colors.grey[200],
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              config.nextFocus
                  ? IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                onPressed: (_previousIndex != null) ? _onTapUp : null,
              )
                  : SizedBox(),
              config.nextFocus
                  ? IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: (_nextIndex != null) ? _onTapDown : null,
              )
                  : SizedBox(),
              Spacer(),
              _currentAction?.displayCloseWidget != null &&
                  _currentAction.displayCloseWidget
                  ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: InkWell(
                  onTap: () {
                    if (_currentAction?.onTapAction != null) {
                      _currentAction.onTapAction();
                    }
                    _clearFocus();
                  },
                  child: _currentAction?.closeWidget ??
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                ),
              )
                  : SizedBox(),
            ],
          ),
        ),
        secondChild: Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return the given child wrapped in a [KeyboardAvoider].
    // We will call [_buildBar] and insert it via overlay on demand.
    // Add [_kBarSize] padding to ensure we scroll past the action bar.
    // TODO: pass in these params


    // We need to add this sized box to support embedding in IntrinsicWidth
    // areas, like AlertDialog. This is because of the LayoutBuilder KeyboardAvoider uses
    // if it has no child ScrollView.
    // If we don't, we get "LayoutBuilder does not support returning intrinsic dimensions".
    // See https://github.com/flutter/flutter/issues/18108.
    // The SizedBox can be removed when thats fixed.
    return SizedBox(
      width: double.maxFinite,
      child: KeyboardAvoider(
          duration: Duration.zero,
          autoScroll: true,
          focusPadding: 12.0 + (_isShowing && _isAvailable ? _kBarSize : 0),
          child: widget.child),
    );
  }
}
