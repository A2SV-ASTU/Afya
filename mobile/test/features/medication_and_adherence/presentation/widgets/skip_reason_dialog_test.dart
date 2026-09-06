import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/core/widgets/afya_button.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/skip_reason_dialog.dart';

void main() {
  Widget buildTestableWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('SkipReasonDialog Widget Tests', () {
    testWidgets('renders dialog title, message, and text field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const SkipReasonDialog(),
        ),
      );

      expect(find.text('Skip this dose?'), findsOneWidget);
      expect(
        find.text('Why are you skipping this dose?'),
        findsOneWidget,
      );
      expect(find.text('Reason for skipping'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm Skip'), findsOneWidget);
    });

    testWidgets('confirm button is disabled initially with empty input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const SkipReasonDialog(),
        ),
      );

      final confirmButton = tester.widget<AfyaButton>(
        find.widgetWithText(AfyaButton, 'Confirm Skip'),
      );
      expect(confirmButton.onPressed, isNull);
    });

    testWidgets('whitespace-only reason keeps confirm button disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const SkipReasonDialog(),
        ),
      );

      await tester.enterText(find.byType(TextField), '     ');
      await tester.pump();

      final confirmButton = tester.widget<AfyaButton>(
        find.widgetWithText(AfyaButton, 'Confirm Skip'),
      );
      expect(confirmButton.onPressed, isNull);
    });

    testWidgets('valid non-empty reason enables confirm button and returns trimmed string',
        (WidgetTester tester) async {
      String? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await SkipReasonDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(SkipReasonDialog), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        '  Experiencing mild nausea  ',
      );
      await tester.pump();

      final confirmButton = tester.widget<AfyaButton>(
        find.widgetWithText(AfyaButton, 'Confirm Skip'),
      );
      expect(confirmButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(AfyaButton, 'Confirm Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(SkipReasonDialog), findsNothing);
      expect(dialogResult, 'Experiencing mild nausea');
    });

    testWidgets('cancel button closes dialog and returns null',
        (WidgetTester tester) async {
      String? dialogResult = 'initial_value';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await SkipReasonDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(SkipReasonDialog), findsOneWidget);

      await tester.tap(find.widgetWithText(AfyaButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(SkipReasonDialog), findsNothing);
      expect(dialogResult, isNull);
    });
  });
}
