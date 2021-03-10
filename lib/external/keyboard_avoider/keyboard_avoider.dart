import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'bottom_area_avoider.dart';

/// A widget that re-sizes its [child] to avoid the system keyboard.
///
/// Unlike a [Scaffold], it only insets by the actual amount obscured by the keyboard.
///
/// Watches for media query changes via [didChangeMetrics], and adjusts a [BottomAreaAvoider] accordingly.
class KeyboardAvoider extends StatefulWidget {
  /// See [BottomAreaAvoider.child]
  final Widget child;

  /// See [BottomAreaAvoider.duration]
  final Duration duration;

  /// See [BottomAreaAvoider.curve]
  final Curve curve;

  /// See [BottomAreaAvoider.autoScroll]
  final bool autoScroll;

  /// See [BottomAreaAvoider.overscroll]
  final double overscroll;

  /// See [BottomAreaAvoider.physics]
  final ScrollPhysics? physics;

  KeyboardAvoider({
    Key? key,
    required this.child,
    this.physics,
    this.duration = BottomAreaAvoider.defaultDuration,
    this.curve = BottomAreaAvoider.defaultCurve,
    this.autoScroll = BottomAreaAvoider.defaultAutoScroll,
    this.overscroll = BottomAreaAvoider.defaultOverscroll,
  })  : assert(child is ScrollView ? child.controller != null : true),
        super(key: key);

  _KeyboardAvoiderState createState() => _KeyboardAvoiderState();
}

class _KeyboardAvoiderState extends State<KeyboardAvoider>
    with WidgetsBindingObserver {
  /// The current amount of keyboard overlap.
  double _keyboardOverlap = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAreaAvoider(
      child: widget.child,
      areaToAvoid: _keyboardOverlap,
      autoScroll: widget.autoScroll,
      curve: widget.curve,
      duration: widget.duration,
      overscroll: widget.overscroll,
      physics: widget.physics,
    );
  }

  /// WidgetsBindingObserver

  @override
  void didChangeMetrics() {
    // Need to wait a frame to get the new size
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _resize();
    });
  }

  /// Re-calculates the amount of overlap, based on the current [MediaQueryData.viewInsets].
  void _resize() {
    if (!mounted) {
      return;
    }

    // Calculate Rect of widget on screen
    final object = context.findRenderObject()!;
    final box = object as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      box.size.width,
      box.size.height,
    );

    // Calculate top of keyboard
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenInsets = mediaQuery.viewInsets;
    final keyboardTop = screenSize.height - screenInsets.bottom;

    // If widget is entirely covered by keyboard, do nothing
    if (widgetRect.top > keyboardTop) {
      return;
    }

    // If widget is partially obscured by the keyboard, adjust bottom padding to fully expose it
    final overlap = max(0.0, widgetRect.bottom - keyboardTop);
    if (overlap != _keyboardOverlap) {
      setState(() {
        _keyboardOverlap = overlap;
      });
    }
  }
}
