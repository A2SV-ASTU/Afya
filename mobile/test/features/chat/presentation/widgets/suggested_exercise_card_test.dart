import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/presentation/widgets/suggested_exercise_card.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: SuggestedExerciseCard(
          exerciseId: 'sleep_123',
        ),
      ),
    );
  }

  testWidgets('SuggestedExerciseCard renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text('Try the Sleep exercise?'), findsOneWidget);
    expect(find.text('It can help you relax and prepare for better rest.'), findsOneWidget);
    expect(find.text('Yes, let\'s try'), findsOneWidget);
    expect(find.text('No, thanks'), findsOneWidget);
  });

  testWidgets('Tapping Yes opens ExerciseConfirmModal', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.text('Yes, let\'s try'));
    await tester.pumpAndSettle();

    expect(find.text('Mark Sleep exercise as started?'), findsOneWidget);
  });
}
