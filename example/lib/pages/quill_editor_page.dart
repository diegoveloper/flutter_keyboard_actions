import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Manual check for [issue #272](https://github.com/diegoveloper/flutter_keyboard_actions/issues/272).
///
/// `flutter_quill`'s editor is a [TextInputClient] behind its own [Focus],
/// not an [EditableText]. The system keyboard should appear on the first tap.
///
/// Run on iOS or Android. The bar is inactive on desktop.
class QuillEditorPage extends StatefulWidget {
  const QuillEditorPage({super.key});

  @override
  State<QuillEditorPage> createState() => _QuillEditorPageState();
}

class _QuillEditorPageState extends State<QuillEditorPage> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quill editor')),
      body: KeyboardActions.done(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Same shape as issue #272: KeyboardActions.done, then '
              'KeyboardField with a toolbar, around an editor that shows '
              'the system keyboard without being an EditableText '
              '(what flutter_quill does).',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the editor once. The toolbar and the system keyboard '
              'both appear.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Text('Quill-like editor'),
            const SizedBox(height: 8),
            KeyboardField(
              focusNode: _focus,
              footerBuilder: (context) => PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Toolbar'),
                      ),
                    ),
                  ),
                ),
              ),
              child: _QuillLikeEditor(focusNode: _focus),
            ),
            const SizedBox(height: 28),
            const Text('TextField, for comparison'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Shows the keyboard on the first tap',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand-in for `QuillRawEditor`: own [Focus] plus [TextInput.attach],
/// with no [EditableText] ancestor for that focus node.
class _QuillLikeEditor extends StatefulWidget {
  final FocusNode focusNode;

  const _QuillLikeEditor({required this.focusNode});

  @override
  State<_QuillLikeEditor> createState() => _QuillLikeEditorState();
}

class _QuillLikeEditorState extends State<_QuillLikeEditor>
    with TextInputClient {
  TextInputConnection? _connection;
  var _value = const TextEditingValue();

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    _connection?.close();
    super.dispose();
  }

  void _onFocus() {
    if (!mounted) return;
    if (widget.focusNode.hasFocus) {
      if (widget.focusNode.consumeKeyboardToken()) _showKeyboard();
    } else {
      _connection?.close();
      _connection = null;
    }
    setState(() {});
  }

  void _onTap() {
    if (widget.focusNode.hasFocus) {
      _showKeyboard();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  void _showKeyboard() {
    final connection = _connection;
    if (connection == null || !connection.attached) {
      _connection = TextInput.attach(
        this,
        const TextInputConfiguration(inputType: TextInputType.multiline),
      )..setEditingState(_value);
    }
    _connection!.show();
  }

  @override
  TextEditingValue? get currentTextEditingValue => _value;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    setState(() => _value = value);
  }

  @override
  void performAction(TextInputAction action) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void connectionClosed() {
    _connection?.connectionClosedReceived();
    _connection = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = widget.focusNode.hasFocus;
    final empty = _value.text.isEmpty;
    return TextFieldTapRegion(
      child: Focus(
        focusNode: widget.focusNode,
        child: GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: focused
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: focused ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  empty ? 'Tap to edit' : _value.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: empty ? theme.hintColor : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
