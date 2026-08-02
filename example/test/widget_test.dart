import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Gallery loads', (tester) async {
    await tester.pumpWidget(const KeyboardActionsGalleryApp());
    expect(find.text('Keyboard Actions 5'), findsOneWidget);
    expect(find.text('Large ListView'), findsOneWidget);
  });
}
