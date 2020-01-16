import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/bottom_area_avoider.dart';
import 'keyboard_action.dart';
export 'keyboard_action.dart';
import 'keyboard_actions_config.dart';
export 'keyboard_actions_config.dart';
export 'keyboard_custom.dart';

const double _kBarSize = 45.0;
const Duration _timeToDismiss = Duration(milliseconds: 110);

enum KeyboardActionsPlatform {
  ANDROID,
  IOS,
  ALL,
}

/// A widget that shows a bar of actions above the keyboard, to help customize input.
///
/// To use this class, add it somewhere higher up in your widget hierarchy. Then, from any child
/// widgets, add [KeyboardActionsConfig] to configure it with the [KeyboardAction]s you'd
/// like to use. These will be displayed whenever the wrapped focus nodes are selected.
///
/// This widget wraps a [KeyboardAvoider], which takes over functionality from [Scaffold]: when the
/// focus changes, this class re-sizes [child]'s focused object to still be visible, and scrolls to the
/// focused node. **As such, set [Scaffold.resizeToAvoidBottomInset] to _false_ when using this Widget.**
///
/// We manage resizing ourselves so that:
///
///   1. using scaffold is not required
///   2. content is only shrunk as needed (a problem with scaffold)
///   3. we shrink an additional [_kBarSize] so the keyboard action bar doesn't cover content either.
class KeyboardActions extends StatefulWidget {
  /// Any content you want to resize/scroll when the keyboard comes up
  final Widget child;

  /// Keyboard configuration
  final KeyboardActionsConfig config;

  /// If you want the content to auto-scroll when focused; see [KeyboardAvoider.autoScroll]
  final bool autoScroll;

  /// In case you don't want to enable keyboard_action bar (e.g. You are running your app on iPad)
  final bool enable;

  /// If you are using keyboard_actions inside a Dialog it must be true
  final bool isDialog;

  /// Tap outside the keyboard will dismiss this
  final bool tapOutsideToDismiss;

  const KeyboardActions({
    this.child,
    this.enable = true,
    this.autoScroll = true,
    this.isDialog = false,
    this.tapOutsideToDismiss = false,
    @required this.config,
  }) : assert(child != null && config != null);

  @override
  KeyboardActionstate createState() => KeyboardActionstate();
}

/// State class for [KeyboardActions].
///
/// Can be accessed statically via [] and [] to update with the latest and greatest [KeyboardActionsConfig].
class KeyboardActionstate extends State<KeyboardActions>
    with WidgetsBindingObserver {
  /// The currently configured keyboard actions
  KeyboardActionsConfig config;

  /// private state
  Map<int, KeyboardAction> _map = Map();
  KeyboardAction _currentAction;
  int _currentIndex = 0;
  OverlayEntry _overlayEntry;
  double _offset = 0;
  PreferredSizeWidget _currentFooter;
  bool _dismissAnimationNeeded = true;
  final _keyParent = GlobalKey();

  /// If the keyboard bar is on for the current platform
  bool get _isAvailable {
    return config.keyboardActionsPlatform == KeyboardActionsPlatform.ALL ||
        (config.keyboardActionsPlatform == KeyboardActionsPlatform.IOS &&
            defaultTargetPlatform == TargetPlatform.iOS) ||
        (config.keyboardActionsPlatform == KeyboardActionsPlatform.ANDROID &&
            defaultTargetPlatform == TargetPlatform.android);
  }

  /// If we are currently showing the keyboard bar
  bool get _isShowing {
    return _overlayEntry != null;
  }

  /// The current previous index, or null.
  int get _previousIndex {
    final nextIndex = _currentIndex - 1;
    return nextIndex >= 0 ? nextIndex : null;
  }

  /// The current next index, or null.
  int get _nextIndex {
    final nextIndex = _currentIndex + 1;
    return nextIndex < _map.length ? nextIndex : null;
  }

  /// Set the config for the keyboard action bar.
  void setConfig(KeyboardActionsConfig newConfig) {
    clearConfig();
    config = newConfig;
    for (int i = 0; i < config.actions.length; i++) {
      _addAction(i, config.actions[i]);
    }
    _startListeningFocus();
  }

  /// Clear any existing configuration. Unsubscribe from focus listeners.
  void clearConfig() {
    _dismissListeningFocus();
    _clearAllFocusNode();
    config = null;
  }

  void _addAction(int index, KeyboardAction action) {
    _map[index] = action;
  }

  void _clearAllFocusNode() {
    _map = Map();
  }

  _clearFocus() {
    _currentAction?.focusNode?.unfocus();
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
    _focusChanged(hasFocusFound);
  }

  _shouldGoToNextFocus(KeyboardAction action, int nextIndex) async {
    _dismissAnimationNeeded = true;
    if (action.focusNode != null) {
      _currentAction = action;
      _currentIndex = nextIndex;
      //remove focus for unselected fields
      _map.keys.forEach((key) {
        final currentAction = _map[key];
        if (currentAction == _currentAction &&
            currentAction.footerBuilder != null) {
          _dismissAnimationNeeded = false;
        }
        if (currentAction.focusNode != null &&
            currentAction != _currentAction) {
          currentAction.focusNode.unfocus();
        }
      });
      //if it is a custom keyboard then wait until the focus was dismissed from the others
      if (_currentAction.footerBuilder != null) {
        await Future.delayed(
          Duration(milliseconds: _timeToDismiss.inMilliseconds),
        );
      }
      FocusScope.of(context).requestFocus(_currentAction.focusNode);
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

  /// Shows or hides the keyboard bar as needed, and re-calculates the overlay offset.
  ///
  /// Called every time the focus changes, and when the app is resumed on Android.
  _focusChanged(bool showBar) {
    if (_isAvailable) {
      if (showBar && !_isShowing) {
        _insertOverlay();
      } else if (!showBar && _isShowing) {
        _removeOverlay();
      } else if (showBar && _isShowing) {
        _overlayEntry.markNeedsBuild();
      }

      if (_currentAction != null && _currentAction.footerBuilder != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOffset();
        });
      }
    }
  }

  @override
  void didChangeMetrics() {
    if (Platform.isAndroid) {
      final value = WidgetsBinding.instance.window.viewInsets.bottom;
      if (value > 0) {
        _onKeyboardChanged(true);
        isKeyboardOpen = true;
      } else {
        isKeyboardOpen = false;
        _onKeyboardChanged(false);
      }
    }
    // Need to wait a frame to get the new size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOffset();
    });
  }

  void _startListeningFocus() {
    _map.values
        .forEach((action) => action.focusNode.addListener(_focusNodeListener));
  }

  void _dismissListeningFocus() {
    _map.values.forEach(
        (action) => action.focusNode.removeListener(_focusNodeListener));
  }

  bool _inserted = false;

  /// Insert the keyboard bar as an Overlay.
  ///
  /// This will be inserted above everything else in the MaterialApp, including dialog modals.
  ///
  /// Position the overlay based on the current [MediaQuery] to land above the keyboard.
  void _insertOverlay() {
    OverlayState os = Overlay.of(context);
    _inserted = true;
    _overlayEntry = OverlayEntry(builder: (context) {
      // Update and build footer, if any
      _currentFooter = (_currentAction.footerBuilder != null)
          ? _currentAction.footerBuilder(context)
          : null;
      final queryData = MediaQuery.of(context);
      return Positioned(
        bottom: queryData.viewInsets.bottom,
        left: 0,
        right: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.tapOutsideToDismiss)
              GestureDetector(
                onTap: _clearFocus,
                child: Container(
                  color: Colors.transparent,
                  height: queryData.size.height,
                ),
              ),
            Material(
              color: config.keyboardBarColor ?? Colors.grey[200],
              elevation: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_currentAction.displayActionBar)
                    _buildBar(_currentAction.displayArrows),
                  if (_currentFooter != null)
                    AnimatedContainer(
                      duration: _timeToDismiss,
                      child: _currentFooter,
                      height:
                          _inserted ? _currentFooter.preferredSize.height : 0,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
    os.insert(_overlayEntry);
  }

  /// Remove the overlay bar. Call when losing focus or being dismissed.
  void _removeOverlay({bool fromDispose = false}) async {
    _inserted = false;
    if (_currentFooter != null && _dismissAnimationNeeded) {
      if (mounted && !fromDispose) {
        _overlayEntry?.markNeedsBuild();
        await Future.delayed(_timeToDismiss);
      }
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentFooter = null;
    if (!fromDispose && _dismissAnimationNeeded) _updateOffset();
    _dismissAnimationNeeded = true;
  }

  void _updateOffset() {
    if (!mounted) {
      return;
    }

    if (!_isShowing || !_isAvailable) {
      setState(() {
        _offset = 0.0;
      });
      return;
    }

    double newOffset = _kBarSize; // offset for the actions bar
    newOffset += MediaQuery.of(context)
        .viewInsets
        .bottom; // + offset for the system keyboard

    if (_currentFooter != null) {
      newOffset +=
          _currentFooter.preferredSize.height; // + offset for the footer
    }
    newOffset = newOffset - _localMargin;
    if (newOffset < 0) newOffset = 0;

    // Update state if changed
    if (_offset != newOffset) {
      setState(() {
        _offset = newOffset;
      });
    }
  }

  double _localMargin = 0.0;

  void _onLayout() {
    if (widget.isDialog) {
      final render = _keyParent.currentContext.findRenderObject() as RenderBox;
      final fullHeight = MediaQuery.of(context).size.height;
      final localHeight = render.size.height;
      _localMargin = (fullHeight - localHeight) / 2;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (state == AppLifecycleState.paused) {
        FocusScope.of(context).requestFocus(FocusNode());
        _focusChanged(false);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didUpdateWidget(KeyboardActions oldWidget) {
    if (widget.enable) setConfig(widget.config);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clearConfig();
    _removeOverlay(fromDispose: true);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (widget.enable) {
      setConfig(widget.config);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onLayout();
        _updateOffset();
      });
    }
    super.initState();
  }

  var isKeyboardOpen = false;

  _onKeyboardChanged(bool isVisible) {
    if (!isVisible) {
      _clearFocus();
    }
  }

  /// Build the keyboard action bar based on the current [config].
  Widget _buildBar(bool displayArrows) {
    return AnimatedCrossFade(
      duration: _timeToDismiss,
      crossFadeState:
          _isShowing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Container(
        height: _kBarSize,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: widget.config.keyboardSeparatorColor,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              config.nextFocus && displayArrows
                  ? IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      tooltip: 'Previous',
                      iconSize: IconTheme.of(context).size,
                      color: IconTheme.of(context).color,
                      disabledColor: Theme.of(context).disabledColor,
                      onPressed: _previousIndex != null ? _onTapUp : null,
                    )
                  : const SizedBox.shrink(),
              config.nextFocus && displayArrows
                  ? IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                      tooltip: 'Next',
                      iconSize: IconTheme.of(context).size,
                      color: IconTheme.of(context).color,
                      disabledColor: Theme.of(context).disabledColor,
                      onPressed: _nextIndex != null ? _onTapDown : null,
                    )
                  : const SizedBox.shrink(),
              Spacer(),
              if (_currentAction?.displayDoneButton != null &&
                  _currentAction.displayDoneButton &&
                  (_currentAction.toolbarButtons == null ||
                      _currentAction.toolbarButtons.isEmpty))
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: () {
                      if (_currentAction?.onTapAction != null) {
                        _currentAction.onTapAction();
                      }
                      _clearFocus();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentAction?.toolbarButtons != null)
                ..._currentAction.toolbarButtons
                    .map((item) => item(_currentAction.focusNode))
                    .toList()
            ],
          ),
        ),
      ),
      secondChild: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return the given child wrapped in a [KeyboardAvoider].
    // We will call [_buildBar] and insert it via overlay on demand.
    // Add [_kBarSize] padding to ensure we scroll past the action bar.

    // We need to add this sized box to support embedding in IntrinsicWidth
    // areas, like AlertDialog. This is because of the LayoutBuilder KeyboardAvoider uses
    // if it has no child ScrollView.
    // If we don't, we get "LayoutBuilder does not support returning intrinsic dimensions".
    // See https://github.com/flutter/flutter/issues/18108.
    // The SizedBox can be removed when thats fixed.
    return widget.enable
        ? Material(
            color: Colors.transparent,
            child: SizedBox(
              width: double.maxFinite,
              key: _keyParent,
              child: BottomAreaAvoider(
                areaToAvoid: _offset,
                duration: Duration(
                    milliseconds:
                        (_timeToDismiss.inMilliseconds * 1.8).toInt()),
                autoScroll: widget.autoScroll,
                child: widget.child,
              ),
            ),
          )
        : widget.child;
  }
}
