# Keyboard Actions

[![pub package](https://img.shields.io/pub/v/keyboard_actions.svg)](https://pub.dartlang.org/packages/keyboard_actions)

Add features to the Android / iOS keyboard in a simple way.

Because the keyboard that Android / iOS offers us specifically when we are in numeric mode, does not bring the button to hide the keyboard.
This causes a lot of inconvenience for users, so this package allows adding functionality to the existing keyboard.


<p align="center">
  <img width="300" height="600" src="https://media.giphy.com/media/fR4Hum4osoRJaLn25V/giphy.gif">
</p>

## Features

- Done button for the keyboard ( You can customize the button).
- Move up/down between your Textfields.
- Keyboard Bar customization 
- You can use it for Android, iOS or both platforms.

## Getting started

You should ensure that you add the router as a dependency in your flutter project.
```yaml
dependencies:
  keyboard_actions: "^1.0.2"
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is an example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Usage

```dart
import  'package:flutter/material.dart';
import  'package:keyboard_actions/keyboard_actions.dart';

 //...
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
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL, //optional
        keyboardBarColor: Colors.grey[200], //optional
        nextFocus: true, //optional
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
```

You can follow me on twitter [@diegoveloper](https://www.twitter.com/diegoveloper)
