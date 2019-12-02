import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
//https://github.com/hackiftekhar/IQKeyboardManager

class Sample extends StatelessWidget {
  final _focusNodeName = FocusNode();
  final _focusNodeQuantity = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("KeyboardActions"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Center(
          child: KeyboardActions(
            tapOutsideToDismiss: true,
            config: KeyboardActionsConfig(
              actions: [
                KeyboardAction(
                  focusNode: _focusNodeQuantity,
                ),
              ],
            ),
            child: ListView(
              children: [
                SizedBox(
                  height: size.height / 4,
                  child: FlutterLogo(),
                ),
                TextField(
                  focusNode: _focusNodeName,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                  ),
                ),
                TextField(
                  focusNode: _focusNodeQuantity,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Quantity",
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
