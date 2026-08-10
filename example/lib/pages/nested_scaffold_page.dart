import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Shows [KeyboardActions] wrapping a Scaffold that is nested under another
/// Scaffold.
class NestedScaffoldPage extends StatelessWidget {
  const NestedScaffoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Scaffold')),
      body: KeyboardActions.done(
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'KeyboardActions wraps the inner Scaffold so its body and '
                'floating action button both clear the Done bar without '
                'adding a second toolbar-height gap.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 500),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Bottom field',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
