import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AfyaMindApp());
    expect(find.text('AfyaMind Initialized'), findsOneWidget);
  });
}
