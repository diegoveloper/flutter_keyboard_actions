import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class NestedScrollPage extends StatelessWidget {
  const NestedScrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardActions(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Nested scroll'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  Text(
                    'CustomScrollView + slivers. KeyboardActions reserves the '
                    'toolbar height, so no custom scroll wrapper is needed.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  for (var i = 1; i <= 12; i++) ...[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Sliver field $i',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
