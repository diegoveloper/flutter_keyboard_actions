import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// Sample [Widget] demonstrating the usage of [KeyboardActions.scrollController].
/// The child of KeyboardActions is not a ScrollView, but it contains a ScrollView internally.
class Sample6 extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  final _focusNodes =
      Iterable<int>.generate(20).map((_) => FocusNode()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardActions(
        scrollController: _scrollController,
        config: KeyboardActionsConfig(
          actions: _focusNodes
              .map((focusNode) => KeyboardActionsItem(focusNode: focusNode))
              .toList(),
        ),
        child: BasePage(
          title: Text("Sample 6"),
          scrollController: _scrollController,
          itemCount: _focusNodes.length,
          itemBuilder: (ctx, idx) => TextField(
            focusNode: _focusNodes[idx],
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              fillColor: Colors.red,
              filled: true,
              labelText: "Field ${idx + 1}",
            ),
          ),
        ),
      ),
    );
  }
}

class BasePage extends StatelessWidget {
  final Widget title;

  final ScrollController? scrollController;

  final int itemCount;

  final NullableIndexedWidgetBuilder itemBuilder;

  final NullableIndexedWidgetBuilder? separatorBuilder;

  const BasePage(
      {required this.title,
      this.scrollController,
      this.itemCount = 0,
      required this.itemBuilder,
      this.separatorBuilder});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          title: title,
          floating: true,
          pinned: true,
        ),
        SliverPadding(
          padding: EdgeInsets.all(15.0).copyWith(
              bottom: mediaQuery.padding.bottom > 0
                  ? mediaQuery.padding.bottom
                  : 15.0),
          sliver: SliverList.separated(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder:
                separatorBuilder ?? (ctx, idx) => const SizedBox(height: 10.0),
          ),
        ),
      ],
    );
  }
}
