import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Sample [Widget] demonstrating the usage of [KeyboardActionsConfig.defaultDoneWidget].
class Sample3 extends StatelessWidget {
  final _focusNodes =
      Iterable<int>.generate(7).map((_) => FocusNode()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample 3"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Center(
          child: KeyboardActions(
            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            config: KeyboardActionsConfig(
              // Define ``defaultDoneWidget`` only once in the config
              defaultDoneWidget: _buildMyDoneWidget(),
              actions: _focusNodes
                  .map((focusNode) => KeyboardActionsItem(focusNode: focusNode))
                  .toList(),
            ),
            child: ListView.separated(
              itemBuilder: (ctx, idx) => TextField(
                focusNode: _focusNodes[idx],
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Field ${idx + 1}",
                ),
              ),
              separatorBuilder: (ctx, idx) => const SizedBox(height: 10.0),
              itemCount: _focusNodes.length,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the custom [Widget] to be rendered as the *"Done"* button.
  Widget _buildMyDoneWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text('My Done Widget'),
            const SizedBox(width: 10.0),
            Icon(Icons.arrow_drop_down, size: 20.0),
          ],
        ),
      ),
    );
  }
}
