import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/chat/presentation/widgets/exercise_confirm_modal.dart';

void main() {
  Widget buildWidget({required VoidCallback onConfirm}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ExerciseConfirmModal(
                    exerciseName: 'Sleep',
                    onConfirm: onConfirm,
                  ),
                );
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('ExerciseConfirmModal renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget(onConfirm: () {}));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Mark Sleep exercise as started?'), findsOneWidget);
    expect(find.text('We\'ll save this to help you continue later.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('Tapping Confirm calls onConfirm and closes dialog', (tester) async {
    bool confirmCalled = false;
    await tester.pumpWidget(buildWidget(onConfirm: () {
      confirmCalled = true;
    }));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(confirmCalled, isTrue);
    expect(find.text('Mark Sleep exercise as started?'), findsNothing);
  });

  testWidgets('Tapping Cancel closes dialog without calling onConfirm', (tester) async {
    bool confirmCalled = false;
    await tester.pumpWidget(buildWidget(onConfirm: () {
      confirmCalled = true;
    }));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmCalled, isFalse);
    expect(find.text('Mark Sleep exercise as started?'), findsNothing);
  });
}
