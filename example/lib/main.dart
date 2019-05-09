import 'package:example/content.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

// Application entry-point
void main() => runApp(MyApp()); // Toggle this to test in a dialog

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  _openWidget(BuildContext context, Widget widget) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => widget),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.amber,
        body: Builder(
          builder: (myContext) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RaisedButton(
                        child: Text("Full Screen form"),
                        onPressed: () => _openWidget(
                              myContext,
                              ScaffoldTest(),
                            ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      RaisedButton(
                        child: Text("Dialog form"),
                        onPressed: () => _openWidget(
                              myContext,
                              DialogTest(),
                            ),
                      )
                    ],
                  ),
                ),
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
      ),
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
        body: Builder(builder: (context) {
          return Center(
            child: FlatButton(
              color: Colors.blue,
              child: Text('Launch dialog'),
              onPressed: () => _launchInDialog(context),
            ),
          );
        }));
  }

  _launchInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dialog test'),
          content: FormKeyboardActions(autoScroll: true, child: Content()),
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
