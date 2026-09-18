import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Reproduces a toolbar inside a nested [Navigator].
///
/// ```
/// Scaffold
/// └── body
///     └── Navigator
///         └── Route
///             └── Scaffold
///                 └── KeyboardActions.done
///                     └── TextField
/// ```
///
/// The outer [Scaffold] keeps `resizeToAvoidBottomInset: true`, so it has
/// already lifted the nested overlay above the keyboard. The Done bar must
/// still sit on the keyboard, not a keyboard-height above it.
class NestedNavigatorPage extends StatelessWidget {
  const NestedNavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Navigator')),
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) {
              return Scaffold(
                body: KeyboardActions.done(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'This route lives in a Navigator nested under the '
                        'outer Scaffold. Focus a field: the Done bar should '
                        'sit on the keyboard, not float a keyboard-height '
                        'above it.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
