import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Sample [Widget] demonstrating the usage of [KeyboardActionsItem.toolbarAlignment].
class Sample4 extends StatelessWidget {
  final _focusSample = FocusNode();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample 4"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Center(
          child: KeyboardActions(
            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            config: KeyboardActionsConfig(
              actions: [
                KeyboardActionsItem(
                  toolbarAlignment: MainAxisAlignment.spaceAround,
                  focusNode: _focusSample,
                  displayArrows: false,
                  toolbarButtons: (_, __, ___, ____) => [
                    IconButton(
                      icon: Icon(Icons.format_bold),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.format_italic),
                      onPressed: () {},
                    ),
                    IconButton(
                        icon: Icon(Icons.format_underline),
                        onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.format_strikethrough),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            child: ListView(
              children: [
                TextField(
                  controller: _textController,
                  focusNode: _focusSample,
                  decoration: InputDecoration(
                    labelText: "Sample Input",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
