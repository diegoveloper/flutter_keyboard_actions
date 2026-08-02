import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Shows [KeyboardActionsThemeData]: switch presets while the bar is visible.
///
/// In a real app you normally set this once, wrapping `MaterialApp` in a
/// [KeyboardActionsTheme] (or adding the data to `ThemeData.extensions`).
class ThemingPage extends StatefulWidget {
  const ThemingPage({super.key});

  @override
  State<ThemingPage> createState() => _ThemingPageState();
}

class _ThemingPageState extends State<ThemingPage> {
  static const _presets = <_Preset>[
    _Preset(
      'Default',
      null,
      '// No theme: Material 3 colors,\n'
          '// iOS 26 floating pill.',
    ),
    _Preset(
      'Branded',
      KeyboardActionsThemeData(
        barColor: Color(0xFF1B4D3E),
        foregroundColor: Colors.white,
        disabledColor: Colors.white38,
        doneText: 'Listo',
        doneTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      'KeyboardActionsThemeData(\n'
          '  barColor: Color(0xFF1B4D3E),\n'
          '  foregroundColor: Colors.white,\n'
          '  disabledColor: Colors.white38,\n'
          '  doneText: \'Listo\',\n'
          '  doneTextStyle: TextStyle(\n'
          '    fontWeight: FontWeight.w800,\n'
          '    fontSize: 17,\n'
          '  ),\n'
          ')',
    ),
    _Preset(
      'Tall + icons',
      KeyboardActionsThemeData(
        barHeight: 62,
        barColor: Color(0xFFFFF3E0),
        foregroundColor: Color(0xFFE65100),
        previousIcon: Icon(Icons.arrow_back_rounded),
        nextIcon: Icon(Icons.arrow_forward_rounded),
        doneTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      'KeyboardActionsThemeData(\n'
          '  barHeight: 62,\n'
          '  barColor: Color(0xFFFFF3E0),\n'
          '  foregroundColor: Color(0xFFE65100),\n'
          '  previousIcon: Icon(Icons.arrow_back_rounded),\n'
          '  nextIcon: Icon(Icons.arrow_forward_rounded),\n'
          ')',
    ),
    _Preset(
      'Pill',
      KeyboardActionsThemeData(
        barColor: Color(0xFF2C2C2E),
        foregroundColor: Color(0xFF7DD3A0),
        borderRadius: BorderRadius.all(Radius.circular(26)),
        keyboardGap: 10,
        padding: EdgeInsets.symmetric(horizontal: 10),
        elevation: 6,
      ),
      'KeyboardActionsThemeData(\n'
          '  barColor: Color(0xFF2C2C2E),\n'
          '  foregroundColor: Color(0xFF7DD3A0),\n'
          '  borderRadius: BorderRadius.circular(26),\n'
          '  keyboardGap: 10,\n'
          '  elevation: 6,\n'
          ')',
    ),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Theming')),
      body: KeyboardActions(
        submitText: 'Send',
        onSubmit: () => FocusManager.instance.primaryFocus?.unfocus(),
        theme: preset.data,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Pick a preset, then focus a field. The bar restyles live.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _presets.length; i++)
                  ChoiceChip(
                    label: Text(_presets[i].name),
                    selected: _index == i,
                    onSelected: (_) => setState(() => _index = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  preset.code,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }
}

class _Preset {
  final String name;
  final KeyboardActionsThemeData? data;
  final String code;
  const _Preset(this.name, this.data, this.code);
}
