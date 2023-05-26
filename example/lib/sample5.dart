import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Sample [Widget] demonstrating the usage of [KeyboardActionsConfig.defaultDoneWidget],
/// [KeyboardActionsItem.toolbarButtons] and other customizations.
class Sample5 extends StatelessWidget {
  final _focusNodes = Iterable<int>.generate(7).map((_) => FocusNode()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample 5"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              flex: 2,
              child: Center(
                child: KeyboardActions(
                  tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
                  config: KeyboardActionsConfig(
                    defaultBarHeight: 70,
                    defaultDoneWidget: _buildMyDoneWidget,
                    // Define ``defaultDoneWidget`` only once in the config
                    defaultPreviousWidget: (defaultPrevious) => _buildMyPreviousWidget(defaultPrevious),
                    defaultNextWidget: (defaultNext) => _buildMyNextWidget(defaultNext),
                    actions: _focusNodes.map((focusNode) {
                      //For the last field, we want different arrows as well, different from the default we built
                      if (_focusNodes.indexOf(focusNode) == 0) {
                        return KeyboardActionsItem(
                          focusNode: focusNode,
                          displayArrows: false,
                          displayDoneButton: false,
                          toolbarAlignment: MainAxisAlignment.center,
                          toolbarButtons: (node, closeAction, previousAction, nextAction) => [
                            SizedBox(
                              width: 80,
                              child: IconButton(
                                icon: Icon(Icons.keyboard_arrow_up),
                                tooltip: 'Custom Previous',
                                iconSize: 38,
                                color: Colors.orange,
                                disabledColor: Colors.red.shade900,
                                onPressed: previousAction,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: IconButton(
                                icon: Icon(Icons.keyboard_arrow_down),
                                tooltip: 'Custom Previous',
                                iconSize: 38,
                                color: Colors.red,
                                disabledColor: Colors.red.shade900,
                                onPressed: nextAction,
                              ),
                            ),
                          ],
                        );
                      }
                      return KeyboardActionsItem(focusNode: focusNode);
                    }).toList(),
                  ),
                  child: ListView.separated(
                    itemBuilder: (ctx, idx) => TextField(
                      focusNode: _focusNodes[idx],
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.red,
                        filled: true,
                        labelText: "Field ${idx + 1}",
                      ),
                    ),
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 10.0),
                    itemCount: _focusNodes.length,
                  ),
                ),
              )),
          Expanded(
              flex: 1,
              child: Container(
                  color: Colors.green,
                  child: Center(
                      child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'I take up space below the KeyboardActions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ))))
        ]),
      ),
    );
  }

  /// Returns the custom [Widget] to be rendered as the *"Done"* button.
  Widget _buildMyDoneWidget(void Function() closeAction) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: closeAction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Done Widget'),
            const SizedBox(width: 10.0),
            Icon(Icons.arrow_drop_down, size: 20.0),
          ],
        ),
      ),
    );
  }

  /// Returns the custom [Widget] to be rendered as the *"Previous"* button.
  Widget _buildMyPreviousWidget(void Function() previousAction) {
    return IconButton(
      icon: Icon(Icons.arrow_upward),
      tooltip: 'New Default Previous',
      iconSize: 24,
      color: Colors.green,
      disabledColor: Colors.blueGrey,
      onPressed: previousAction, //You're able to do other things here before calling default Previous
    );
  }

  /// Returns the custom [Widget] to be rendered as the *"Next"* button.
  Widget _buildMyNextWidget(void Function() nextAction) {
    return IconButton(
      icon: Icon(Icons.arrow_downward),
      tooltip: 'New Default Next',
      iconSize: 24,
      color: Colors.green,
      disabledColor: Colors.blueGrey,
      onPressed: nextAction,
    );
  }
}
