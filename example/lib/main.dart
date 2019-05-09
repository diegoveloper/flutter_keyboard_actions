import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

// Application entry-point
void main() => runApp(MyApp(testDialog: false)); // Toggle this to test in a dialog

class MyApp extends StatelessWidget {

  final bool testDialog;

  const MyApp({Key key, this.testDialog}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: testDialog ? DialogTest() : ScaffoldTest(),
    );
  }
}

final FocusNode _nodeText1 = FocusNode();
final FocusNode _nodeText2 = FocusNode();
final FocusNode _nodeText3 = FocusNode();
final FocusNode _nodeText4 = FocusNode();
final FocusNode _nodeText5 = FocusNode();

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
    ],
  );
}

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    // Configure keyboard actions
    FormKeyboardActions.setKeyboardActions(context, _buildConfig(context));

    return Center(
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
    );  
  }
}


/// Displays our [TextField]s in a [Scaffold] with a [FormKeyboardActions].
class ScaffoldTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Keyboard Actions Sample"),
        ),
        body: FormKeyboardActions(
          child: Content(),
        )
    );
  }
}

/// Displays our [FormKeyboardActions] nested in a [AlertDialog].
class DialogTest extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Keyboard Actions Sample"),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: FlatButton(
                color: Colors.blue,
                child: Text('Launch dialog'),
                onPressed: () => _launchInDialog(context),
              ),
            );
          }
        )
    );
  }

  _launchInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dialog test'),
          content:
              FormKeyboardActions(
                autoScroll: true,
                child: Content()
              ),
          actions: [
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

