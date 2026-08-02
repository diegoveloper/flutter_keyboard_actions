import 'package:flutter/material.dart';

import 'keyboard_field.dart';

/// Shared controller between [KeyboardActions] and [KeyboardField]s.
class KeyboardActionsController extends ChangeNotifier {
  final Set<KeyboardFieldState> _fields = {};
  bool _scheduled = false;
  bool _disposed = false;

  List<KeyboardFieldState> get fields => _fields.toList(growable: false);

  void register(KeyboardFieldState field) {
    if (_disposed) return;
    if (_fields.add(field)) _scheduleNotify();
  }

  void unregister(KeyboardFieldState field) {
    if (_disposed) return;
    if (_fields.remove(field)) _scheduleNotify();
  }

  void _scheduleNotify() {
    if (_scheduled || _disposed) return;
    _scheduled = true;
    // Defer registration; it often happens during build/didChangeDependencies.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  KeyboardFieldState? fieldFor(FocusNode node) {
    for (final field in _fields) {
      if (identical(field.effectiveFocusNode, node)) return field;
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    _fields.clear();
    super.dispose();
  }
}

class KeyboardActionsScope
    extends InheritedNotifier<KeyboardActionsController> {
  const KeyboardActionsScope({
    super.key,
    required KeyboardActionsController controller,
    required super.child,
  }) : super(notifier: controller);

  static KeyboardActionsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<KeyboardActionsScope>()
        ?.notifier;
  }

  static KeyboardActionsController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(
      controller != null,
      'KeyboardField requires an ancestor KeyboardActions.',
    );
    return controller!;
  }
}
