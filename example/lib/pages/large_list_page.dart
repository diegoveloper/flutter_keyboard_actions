import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Stress-test: many fields inside a ListView. No scroll wrapper hacks.
class LargeListPage extends StatelessWidget {
  const LargeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Large ListView')),
      body: KeyboardActions(
        child: ListView.builder(
          // Keep nearby rows alive so Prev/Next does not rebuild/dispose the
          // EditableText mid-transfer (helps keyboard stay put).
          cacheExtent: 1200,
          padding: const EdgeInsets.all(16),
          itemCount: 40,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Field ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            );
          },
        ),
      ),
    );
  }
}
