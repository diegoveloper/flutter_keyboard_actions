import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class Sample2 extends StatelessWidget {
  final _focusSample = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample 2"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Center(
          child: KeyboardActions(
            tapOutsideToDismiss: true,
            config: KeyboardActionsConfig(
              keyboardSeparatorColor: Colors.purple,
              actions: [
                KeyboardAction(
                  focusNode: _focusSample,
                  displayArrows: false,
                  displayActionBar: false,
                  footerBuilder: (context) {
                    return MyCustomBarWidget(node: _focusSample);
                  },
                ),
              ],
            ),
            child: ListView(
              children: [
                TextField(
                  focusNode: _focusSample,
                  keyboardType: TextInputType.phone,
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

class MyCustomBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final FocusNode node;

  const MyCustomBarWidget({Key key, this.node}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: Icon(Icons.access_alarm),
            onPressed: () => print('hello world 1')),
        IconButton(
            icon: Icon(Icons.accessible),
            onPressed: () => print('hello world 2')),
        Spacer(),
        IconButton(icon: Icon(Icons.close), onPressed: () => node.unfocus()),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
