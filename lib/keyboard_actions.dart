import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kBarSize = 45.0;

enum KeyboardActionsPlatform {
  ANDROID,
  IOS,
  ALL,
}

class KeyboardAction {
  ///This is the Focus object to know if the textfield has or lost the focus
  final FocusNode focusNode;

  ///Optional callback to know if the button for this specific textfield was tapped
  final VoidCallback onTapAction;

  ///Optional widget to display to the right of the bar
  final Widget closeWidget;

  ///false if you don't want to display a closeWidget
  final bool displayCloseWidget;

  KeyboardAction({
    @required this.focusNode,
    this.onTapAction,
    this.closeWidget,
    this.displayCloseWidget = true,
  });
}

class FormKeyboardActions extends StatefulWidget {
  /// You can pass any widget, ideally it should content a textfield
  final Widget child;

  /// Keyboard Action for specific platform
  /// KeyboardActionsPlatform : ANDROID , IOS , ALL
  final KeyboardActionsPlatform keyboardActionsPlatform;

  ///true if you want to display arrows to move through your inputs
  final bool nextFocus;

  ///KeyboardAction for each textfield you want to have actions
  final List<KeyboardAction> actions;

  ///Color for the background of the Custom keyboard buttons
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

class _FormKeyboardActionsState extends State<FormKeyboardActions> {
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
      _shouldGoToNextFocus(currentAction, nextIndex);
    }
  }

  _onTapDown() {
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _map.length) {
      final currentAction = _map[nextIndex];
      _shouldGoToNextFocus(currentAction, nextIndex);
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
  void dispose() {
    _dismissListeningFocus();
    super.dispose();
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
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: _isKeyboardVisible ? _kBarSize : 0.0),
          child: widget.child,
        ),
        widget.keyboardActionsPlatform == KeyboardActionsPlatform.ALL ||
                (widget.keyboardActionsPlatform ==
                        KeyboardActionsPlatform.IOS &&
                    defaultTargetPlatform == TargetPlatform.iOS) ||
                (widget.keyboardActionsPlatform ==
                        KeyboardActionsPlatform.ANDROID &&
                    defaultTargetPlatform == TargetPlatform.android)
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
                  secondChild: SizedBox(
                    height: 0.0,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }
}
