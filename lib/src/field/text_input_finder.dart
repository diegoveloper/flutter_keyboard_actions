import 'package:flutter/material.dart';

/// Finds focusable text-input nodes under [context] in tree order.
abstract final class TextInputFinder {
  static List<FocusNode> find(BuildContext context) {
    final nodes = <FocusNode>[];

    void visit(Element element) {
      final widget = element.widget;
      if (widget is EditableText) {
        final node = widget.focusNode;
        if (node.canRequestFocus && !widget.readOnly && !nodes.contains(node)) {
          nodes.add(node);
        }
      }
      element.visitChildren(visit);
    }

    visit(context as Element);
    return nodes;
  }
}
