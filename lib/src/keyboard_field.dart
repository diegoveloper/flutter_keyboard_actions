import 'package:flutter/material.dart';

import 'bar/keyboard_bar.dart';
import 'keyboard_scope.dart';

/// Local per-field configuration.
///
/// Wrap any text field (or [KeyboardCustomInput]) to customize the bar / add
/// a custom keyboard panel, without maintaining a global FocusNode list.
///
/// Requires a [KeyboardActions] ancestor, which may wrap this field alone:
/// `KeyboardActions.done(child: KeyboardField(footer: pad, child: ...))`.
///
/// ```dart
/// KeyboardField(
///   footer: NumericPad(...),
///   child: TextField(...),
/// )
/// ```
class KeyboardField extends StatefulWidget {
  final Widget child;

  /// Custom panel below the bar (or replacing it when [showBar] is false).
  final PreferredSizeWidget Function(BuildContext context)? footerBuilder;

  /// Shortcut for a static [footerBuilder] widget.
  final PreferredSizeWidget? footer;

  /// Custom trailing toolbar buttons (replaces Done when non-empty).
  final List<KeyboardBarButtonBuilder>? toolbarButtons;

  /// Show the action bar for this field. Defaults to true.
  final bool showBar;

  /// Show prev/next for this field when navigation is enabled.
  final bool showArrows;

  /// Show the default Done button.
  ///
  /// Ignored on the last field when `KeyboardActions.onSubmit` is set, since
  /// Submit takes Done's place there.
  final bool showDone;

  /// Called when this field's Done button dismisses the keyboard.
  ///
  /// A dismissing tap outside counts too. Runs before
  /// `KeyboardActions.onDismissed`.
  final VoidCallback? onDone;

  /// Optional explicit focus node. If null, discovered from [child].
  final FocusNode? focusNode;

  const KeyboardField({
    super.key,
    required this.child,
    this.footerBuilder,
    this.footer,
    this.toolbarButtons,
    this.showBar = true,
    this.showArrows = true,
    this.showDone = true,
    this.onDone,
    this.focusNode,
  });

  @override
  State<KeyboardField> createState() => KeyboardFieldState();
}

class KeyboardFieldState extends State<KeyboardField> {
  FocusNode? _discoveredNode;
  KeyboardActionsController? _controller;

  FocusNode? get effectiveFocusNode => widget.focusNode ?? _discoveredNode;

  PreferredSizeWidget? footerOf(BuildContext context) {
    if (widget.footerBuilder != null) return widget.footerBuilder!(context);
    return widget.footer;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = KeyboardActionsScope.maybeOf(context);
    if (!identical(controller, _controller)) {
      _controller?.unregister(this);
      _controller = controller;
      _controller?.register(this);
    }
  }

  @override
  void dispose() {
    _controller?.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FocusDiscovery(
      explicitNode: widget.focusNode,
      onNodeFound: (node) {
        if (_discoveredNode != node) {
          _discoveredNode = node;
          _controller?.register(this);
        }
      },
      child: widget.child,
    );
  }
}

/// Walks the child subtree after layout to discover an [EditableText] node.
class _FocusDiscovery extends StatefulWidget {
  final Widget child;
  final FocusNode? explicitNode;
  final ValueChanged<FocusNode?> onNodeFound;

  const _FocusDiscovery({
    required this.child,
    required this.onNodeFound,
    this.explicitNode,
  });

  @override
  State<_FocusDiscovery> createState() => _FocusDiscoveryState();
}

class _FocusDiscoveryState extends State<_FocusDiscovery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _discover());
  }

  @override
  void didUpdateWidget(covariant _FocusDiscovery oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _discover());
  }

  void _discover() {
    if (!mounted) return;
    if (widget.explicitNode != null) {
      widget.onNodeFound(widget.explicitNode);
      return;
    }

    FocusNode? found;
    void visit(Element element) {
      if (found != null) return;
      final w = element.widget;
      if (w is EditableText) {
        found = w.focusNode;
        return;
      }
      // KeyboardCustomInput uses Focus directly.
      if (w is Focus && w.focusNode != null) {
        found = w.focusNode;
        return;
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    widget.onNodeFound(found);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
