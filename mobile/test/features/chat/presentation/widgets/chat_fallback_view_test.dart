import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_fallback_view.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: const Scaffold(
          body: ChatFallbackView(),
        ),
      ),
    );
  }

  testWidgets('ChatFallbackView renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.byIcon(CupertinoIcons.tortoise), findsOneWidget);
    expect(
        find.text(
            'Chat is temporarily unavailable — but your exercises and Crisis line still work.'),
        findsOneWidget);
    expect(find.text('Go to Exercises'), findsOneWidget);
  });

  testWidgets('Tapping Go to Exercises navigates to /exercises', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.text('Go to Exercises'));
    await tester.pumpAndSettle();

    verify(() => mockGoRouter.go('/exercises')).called(1);
  });
}
