import 'package:afyamind_mobile/app/router/app_router.dart';
import 'package:afyamind_mobile/app.dart';
import 'package:afyamind_mobile/core/di/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_env.dart';

void main() {
  setUpAll(() {
    loadTestEnv();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('AfyaMindApp builds successfully after configureDependencies',
      (tester) async {
    await sl.reset();
    await configureDependencies();

    expect(sl.isRegistered<AppRouter>(), isTrue);
    final appRouter = sl<AppRouter>();
    expect(appRouter, isNotNull);

    await tester.pumpWidget(const AfyaMindApp());
    await tester.pump();

    expect(find.byType(AfyaMindApp), findsOneWidget);
  });
}
