import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Classic Material 2 look (`useMaterial3: false`): underline fields, elevated
/// buttons, and the pre-M3 AppBar / keyboard bar styling.
class Material2Page extends StatelessWidget {
  const Material2Page({super.key});

  static ThemeData _material2Theme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: false,
      brightness: brightness,
      primarySwatch: Colors.teal,
      appBarTheme: const AppBarTheme(elevation: 4),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(secondary: Colors.tealAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Theme(
      data: _material2Theme(brightness),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Material 2')),
          body: KeyboardActions(
            theme: const KeyboardActionsThemeData(integratedBar: true),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                Text(
                  'Same KeyboardActions API, classic Material 2 chrome. '
                  'The theme keeps the toolbar flush with the keyboard.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    icon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Company',
                    icon: Icon(Icons.business_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    icon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('SAVE'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
