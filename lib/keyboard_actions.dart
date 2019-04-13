import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  KeyboardAction({
    @required this.focusNode,
    this.onTapAction,
    this.closeWidget,
    this.enabled = true,
    this.displayCloseWidget = true,
  });
}

class FormKeyboardActions extends StatefulWidget {
  /// Pass any widget, ideally it should content a textfield
  final Widget child;

  /// Keyboard Action for specific platform
  /// KeyboardActionsPlatform : ANDROID , IOS , ALL
  final KeyboardActionsPlatform keyboardActionsPlatform;

  /// true to display arrows prev/next to move focus between inputs
  final bool nextFocus;

  /// KeyboardAction for each textfield
  final List<KeyboardAction> actions;

  /// Color of the background to the Custom keyboard buttons
  final Color keyboardBarColor;

  FormKeyboardActions(
      {this.child,
      this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
      this.nextFocus = true,
      this.actions,
      this.keyboardBarColor})
      : assert(child != null);

  @override
  _FormKeyboardActionsState createState() => _FormKeyboardActionsState();
}

class _FormKeyboardActionsState extends State<FormKeyboardActions>
    with WidgetsBindingObserver {
  Map<int, KeyboardAction> _map = Map();
  bool _isKeyboardVisible = false;
  KeyboardAction _currentAction;
  int _currentIndex = 0;

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
    _shouldRefresh(hasFocusFound);
  }

  _shouldGoToNextFocus(KeyboardAction action, int nextIndex) {
    if (action.focusNode != null) {
      _currentAction = action;
      _currentIndex = nextIndex;
      FocusScope.of(context).requestFocus(_currentAction.focusNode);
      _shouldRefresh(true);
    }
  }

  _onTapUp() {
    final nextIndex = _currentIndex - 1;
    if (nextIndex >= 0) {
      final currentAction = _map[nextIndex];
      if (currentAction.enabled) {
        _shouldGoToNextFocus(currentAction, nextIndex);
      } else if (currentAction != null) {
        _currentIndex = nextIndex;
        _onTapUp();
      }
    }
  }

  _onTapDown() {
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _map.length) {
      final currentAction = _map[nextIndex];
      if (currentAction.enabled) {
        _shouldGoToNextFocus(currentAction, nextIndex);
      } else {
        _currentIndex = nextIndex;
        _onTapDown();
      }
    }
  }

  _shouldRefresh(bool newValue) {
    setState(() {
      _isKeyboardVisible = newValue;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (state == AppLifecycleState.paused) {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _isKeyboardVisible = false;
        });
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _dismissListeningFocus();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isNotEmpty) {
      _clearAllFocusNode();
      for (int i = 0; i < widget.actions.length; i++) {
        _addAction(i, widget.actions[i]);
      }
      _dismissListeningFocus();
      _startListeningFocus();
    }
    bool isAvailable = widget.keyboardActionsPlatform ==
            KeyboardActionsPlatform.ALL ||
        (widget.keyboardActionsPlatform == KeyboardActionsPlatform.IOS &&
            defaultTargetPlatform == TargetPlatform.iOS) ||
        (widget.keyboardActionsPlatform == KeyboardActionsPlatform.ANDROID &&
            defaultTargetPlatform == TargetPlatform.android);
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: _isKeyboardVisible && isAvailable ? _kBarSize : 0.0),
          child: widget.child,
        ),
        isAvailable
            ? Positioned(
                bottom: 0.0,
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 180),
                  crossFadeState: _isKeyboardVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(
                    height: _kBarSize,
                    color: widget.keyboardBarColor ?? Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        widget.nextFocus
                            ? IconButton(
                                icon: Icon(Icons.keyboard_arrow_up),
                                onPressed: _onTapUp,
                              )
                            : SizedBox(),
                        widget.nextFocus
                            ? IconButton(
                                icon: Icon(Icons.keyboard_arrow_down),
                                onPressed: _onTapDown,
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
                  secondChild: Container(
                    height: 0.0,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              )
            : SizedBox(
                height: 0.0,
              )
      ],
    );
  }
}
