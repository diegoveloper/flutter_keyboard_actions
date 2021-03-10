import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'custom_input.dart';

//This could be StatelessWidget but it won't work on Dialogs for now until this issue is fixed: https://github.com/flutter/flutter/issues/45839
class Content extends StatefulWidget {
  final bool isDialog;

  const Content({Key key, this.isDialog = false}) : super(key: key);

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

  final FocusNode _nodeText8 = FocusNode();

  final FocusNode _nodeText9 = FocusNode();

  final FocusNode _nodeText10 = FocusNode();

  final custom1Notifier = ValueNotifier<String>("0");

  final custom2Notifier = ValueNotifier<Color>(Colors.blue);

  final custom3Notifier = ValueNotifier<String>("");

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(focusNode: _nodeText2, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(
          focusNode: _nodeText3,
          onTapAction: () async {
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("Custom Action"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                });
          },
        ),
        KeyboardActionsItem(
          focusNode: _nodeText4,
          displayDoneButton: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText5,
          toolbarButtons: [
            //button 1
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
            //button 2
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  color: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "DONE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          ],
        ),
        KeyboardActionsItem(
          focusNode: _nodeText6,
          footerBuilder: (_) => PreferredSize(
              child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Custom Footer'),
                  )),
              preferredSize: Size.fromHeight(40)),
        ),
        KeyboardActionsItem(
          focusNode: _nodeText7,
          displayActionBar: false,
          footerBuilder: (_) => PreferredSize(
              child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Custom Footer'),
                  )),
              preferredSize: Size.fromHeight(40)),
        ),
        KeyboardActionsItem(
          focusNode: _nodeText8,
          footerBuilder: (_) => CounterKeyboard(
            notifier: custom1Notifier,
          ),
        ),
        KeyboardActionsItem(
          focusNode: _nodeText9,
          footerBuilder: (_) => ColorPickerKeyboard(
            notifier: custom2Notifier,
          ),
        ),
        KeyboardActionsItem(
          focusNode: _nodeText10,
          displayActionBar: false,
          footerBuilder: (_) => NumericKeyboard(
            focusNode: _nodeText10,
            notifier: custom3Notifier,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      isDialog: widget.isDialog,
      config: _buildConfig(context),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
                  hintText: "Input Text with Custom Done Widget",
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
                  hintText: "Input Text without Done Button",
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                focusNode: _nodeText5,
                decoration: InputDecoration(
                  hintText: "Input Number with Toolbar Buttons",
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                focusNode: _nodeText6,
                decoration: InputDecoration(
                  hintText: "Input Number with Custom Footer",
                ),
              ),
              TextField(
                focusNode: _nodeText7,
                decoration: InputDecoration(
                  hintText: "Input Number with Custom Footer without Bar",
                ),
              ),
              KeyboardCustomInput<String>(
                focusNode: _nodeText8,
                height: 65,
                notifier: custom1Notifier,
                builder: (context, val, hasFocus) {
                  return Container(
                    alignment: Alignment.center,
                    color: hasFocus ? Colors.grey[300] : Colors.white,
                    child: Text(
                      val,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              KeyboardCustomInput<Color>(
                focusNode: _nodeText9,
                height: 65,
                notifier: custom2Notifier,
                builder: (context, val, hasFocus) {
                  return Container(
                    width: double.maxFinite,
                    color: val ?? Colors.transparent,
                  );
                },
              ),
              KeyboardCustomInput<String>(
                focusNode: _nodeText10,
                height: 65,
                notifier: custom3Notifier,
                builder: (context, val, hasFocus) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      val.isEmpty ? "Tap Here" : val,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
