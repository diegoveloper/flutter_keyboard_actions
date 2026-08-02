import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Shows [KeyboardActionsThemeData.integratedBar]: toolbar flush with the
/// system keyboard.
class IntegratedBarPage extends StatelessWidget {
  const IntegratedBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrated bar')),
      body: KeyboardActions(
        theme: const KeyboardActionsThemeData(integratedBar: true),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'integratedBar: true',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'The toolbar sits flush against the system keyboard, with no gap, '
              'no rounded “pill” on iOS 26+. Classic accessory-view look.\n\n'
              'Other demos use the default (floating bar with gap on iOS 26+).',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'KeyboardActions(\n'
                  '  theme: KeyboardActionsThemeData(\n'
                  '    integratedBar: true,\n'
                  '  ),\n'
                  '  child: ...,\n'
                  ')',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const TextField(
              decoration: InputDecoration(
                labelText: 'First name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Last name',
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
            const SizedBox(height: 24),
            FilledButton(onPressed: () {}, child: const Text('Send')),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }
}
