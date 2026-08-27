import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/app.dart';
import 'package:afyamind_mobile/core/di/injection_container.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
  });

  testWidgets('AfyaMind App initial render smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AfyaMindApp());
    await tester.pumpAndSettle();

    // Verify root dashboard renders successfully
    expect(find.text('Dashboard'), findsWidgets);
  });
}
