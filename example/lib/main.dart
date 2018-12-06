import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  FocusNode _nodeText1 = FocusNode();
  FocusNode _nodeText2 = FocusNode();
  FocusNode _nodeText3 = FocusNode();
  FocusNode _nodeText4 = FocusNode();
  FocusNode _nodeText5 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keyboard Actions Sample"),
      ),
      body: FormKeyboardActions(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardAction(
            focusNode: _nodeText1,
          ),
          KeyboardAction(
            focusNode: _nodeText2,
            closeWidget: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.close),
            ),
          ),
          KeyboardAction(
            focusNode: _nodeText3,
            onTapAction: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text("Custom Action"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    );
                  });
            },
          ),
          KeyboardAction(
            focusNode: _nodeText4,
            displayCloseWidget: false,
          ),
          KeyboardAction(
            focusNode: _nodeText5,
            closeWidget: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text("CLOSE"),
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.number,
                  focusNode: _nodeText1,
                  decoration: InputDecoration(
                    hintText: "Input Number",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  focusNode: _nodeText2,
                  decoration: InputDecoration(
                    hintText: "Input Text with Custom Close Widget",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  focusNode: _nodeText3,
                  decoration: InputDecoration(
                    hintText: "Input Number with Custom Action",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  focusNode: _nodeText4,
                  decoration: InputDecoration(
                    hintText: "Input Text without Close Widget",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  focusNode: _nodeText5,
                  decoration: InputDecoration(
                    hintText: "Input Number with Custom Close Widget",
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
