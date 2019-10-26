import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
//https://github.com/hackiftekhar/IQKeyboardManager

class Sample extends StatelessWidget {
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
          child: ListView(
            children: [
              SizedBox(
                height: size.height / 4,
                child: FlutterLogo(),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Product Name",
                ),
              ),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Quantity",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//final _focusNodeName = FocusNode();
//final _focusNodeQuantity = FocusNode();
