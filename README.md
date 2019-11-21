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
- Keyboard Bar customization.
- Custom footer widget below keyboard bar
- You can use it for Android, iOS or both platforms.
- Compatible with Dialog.

Example of the custom footer: 

<img width="250" alt="Screen Shot 2019-05-22 at 5 46 50 PM" src="https://user-images.githubusercontent.com/3268245/58218221-0409f200-7cbb-11e9-91d8-592f2e99fa8a.png">

For more fun, use that widget as a custom keyboard with your custom input:

<img width="250" alt="Screen Shot 2019-05-22 at 5 46 54 PM" src="https://user-images.githubusercontent.com/3268245/58218234-0ec48700-7cbb-11e9-81b6-e61658f4d200.png">


## Getting started

You should ensure that you add the dependency in your flutter project.
```yaml
dependencies:
  keyboard_actions: "^3.0.0"
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is an example project in the `example` folder where you can get more information. Check it out. Otherwise, keep reading to get up and running.

## Usage

```dart
import  'package:flutter/material.dart';
import  'package:keyboard_actions/keyboard_actions.dart';


class Content extends StatefulWidget {
  const Content({
    Key key,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();
  final FocusNode _nodeText6 = FocusNode();
  final FocusNode _nodeText7 = FocusNode();

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
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
        KeyboardAction(
          focusNode: _nodeText6,
          footerBuilder: (_) => PreferredSize(
              child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Custom Footer'),
                  )),
              preferredSize: Size.fromHeight(40)),
        ),
        KeyboardAction(
          focusNode: _nodeText7,
          footerBuilder: (_) => ColorPickerKeyboard.instance,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormKeyboardActions(
      config: _buildConfig(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
              TextField(
                keyboardType: TextInputType.number,
                focusNode: _nodeText6,
                decoration: InputDecoration(
                  hintText: "Input Number with Custom Footer",
                ),
              ),
              ColorInput(
                focusNode: _nodeText7,
                decoration: InputDecoration(
                  hintText: 'Input Color',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


```

You can follow me on twitter [@diegoveloper](https://www.twitter.com/diegoveloper)
