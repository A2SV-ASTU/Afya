import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/core/widgets/afya_button.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/log_action_sheet.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/skip_reason_dialog.dart';

void main() {
  Widget buildTestableSheet({
    required LocalDoseRecordEntity doseRecord,
    String? route,
    String? instructions,
    ValueChanged<LocalDoseRecordEntity>? onTaken,
    ValueChanged<LocalDoseRecordEntity>? onSnooze,
    void Function(LocalDoseRecordEntity dose, String reason)? onSkip,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LogActionSheet(
          doseRecord: doseRecord,
          route: route,
          instructions: instructions,
          onTaken: onTaken,
          onSnooze: onSnooze,
          onSkip: onSkip,
        ),
      ),
    );
  }

  group('LogActionSheet Widget Tests', () {
    testWidgets(
        'renders medication details, dosage, route, scheduled time, instructions, and status badge',
        (WidgetTester tester) async {
      final scheduledTime = DateTime(2026, 8, 29, 8, 0);
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_1',
        prescriptionItemId: 'rx_1',
        medicationName: 'Amoxicillin',
        dose: '500mg',
        scheduledTime: scheduledTime,
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableSheet(
          doseRecord: doseRecord,
          route: 'Oral',
          instructions: 'Take with food and full glass of water',
        ),
      );

      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('500mg • Oral'), findsOneWidget);
      expect(find.text('Scheduled for 8:00 AM'), findsOneWidget);
      expect(find.text('Take with food and full glass of water'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);

      expect(find.widgetWithText(AfyaButton, 'Mark as Taken'), findsOneWidget);
      expect(find.widgetWithText(AfyaButton, 'Snooze (10 min)'), findsOneWidget);
      expect(find.widgetWithText(AfyaButton, 'Skip Dose'), findsOneWidget);
    });

    testWidgets('tapping Mark as Taken triggers onTaken callback',
        (WidgetTester tester) async {
      LocalDoseRecordEntity? takenDose;

      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_taken_test',
        prescriptionItemId: 'rx_1',
        medicationName: 'Metformin',
        dose: '850mg',
        scheduledTime: DateTime(2026, 8, 29, 9, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LogActionSheet.show(
                  context,
                  doseRecord: doseRecord,
                  onTaken: (d) => takenDose = d,
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(LogActionSheet), findsOneWidget);

      await tester.tap(find.widgetWithText(AfyaButton, 'Mark as Taken'));
      await tester.pumpAndSettle();

      expect(find.byType(LogActionSheet), findsNothing);
      expect(takenDose, isNotNull);
      expect(takenDose!.id, 'dose_taken_test');
    });

    testWidgets('snooze button is enabled when snoozeCount is below 2 and invokes onSnooze',
        (WidgetTester tester) async {
      LocalDoseRecordEntity? snoozedDose;

      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_snooze_test',
        prescriptionItemId: 'rx_1',
        medicationName: 'Lisinopril',
        dose: '10mg',
        scheduledTime: DateTime(2026, 8, 29, 8, 0),
        status: DoseStatus.pending,
        snoozeCount: 1, // 1 snooze used, can snooze once more
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LogActionSheet.show(
                  context,
                  doseRecord: doseRecord,
                  onSnooze: (d) => snoozedDose = d,
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final snoozeButton = tester.widget<AfyaButton>(
        find.widgetWithText(AfyaButton, 'Snooze (10 min)'),
      );
      expect(snoozeButton.onPressed, isNotNull);
      expect(find.text('Maximum 2 snoozes reached'), findsNothing);

      await tester.tap(find.widgetWithText(AfyaButton, 'Snooze (10 min)'));
      await tester.pumpAndSettle();

      expect(find.byType(LogActionSheet), findsNothing);
      expect(snoozedDose, isNotNull);
      expect(snoozedDose!.id, 'dose_snooze_test');
    });

    testWidgets(
        'snooze button is disabled and displays max snooze message when snoozeCount is 2',
        (WidgetTester tester) async {
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_max_snooze',
        prescriptionItemId: 'rx_1',
        medicationName: 'Atorvastatin',
        dose: '20mg',
        scheduledTime: DateTime(2026, 8, 29, 20, 0),
        status: DoseStatus.pending,
        snoozeCount: 2, // Maximum reached
      );

      await tester.pumpWidget(
        buildTestableSheet(doseRecord: doseRecord),
      );

      final snoozeButton = tester.widget<AfyaButton>(
        find.widgetWithText(AfyaButton, 'Snooze (10 min)'),
      );
      expect(snoozeButton.onPressed, isNull);
      expect(find.text('Maximum 2 snoozes reached'), findsOneWidget);
    });

    testWidgets('third snooze cannot be triggered when snooze count is 2 or higher',
        (WidgetTester tester) async {
      var snoozeTriggered = false;

      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_third_snooze',
        prescriptionItemId: 'rx_1',
        medicationName: 'Atorvastatin',
        dose: '20mg',
        scheduledTime: DateTime(2026, 8, 29, 20, 0),
        status: DoseStatus.pending,
        snoozeCount: 2,
      );

      await tester.pumpWidget(
        buildTestableSheet(
          doseRecord: doseRecord,
          onSnooze: (_) => snoozeTriggered = true,
        ),
      );

      final snoozeFinder = find.widgetWithText(AfyaButton, 'Snooze (10 min)');
      final snoozeButton = tester.widget<AfyaButton>(snoozeFinder);
      expect(snoozeButton.onPressed, isNull);

      await tester.tap(snoozeFinder);
      await tester.pump();

      expect(snoozeTriggered, isFalse);
    });

    testWidgets('tapping Skip Dose opens SkipReasonDialog and returns reason to onSkip',
        (WidgetTester tester) async {
      LocalDoseRecordEntity? skippedDose;
      String? recordedReason;

      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_skip_test',
        prescriptionItemId: 'rx_1',
        medicationName: 'Ibuprofen',
        dose: '400mg',
        scheduledTime: DateTime(2026, 8, 29, 14, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LogActionSheet.show(
                  context,
                  doseRecord: doseRecord,
                  onSkip: (d, r) {
                    skippedDose = d;
                    recordedReason = r;
                  },
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(LogActionSheet), findsOneWidget);

      // Tap Skip Dose button
      await tester.tap(find.widgetWithText(AfyaButton, 'Skip Dose'));
      await tester.pumpAndSettle();

      // Verify SkipReasonDialog opened
      expect(find.byType(SkipReasonDialog), findsOneWidget);

      // Enter skip reason
      await tester.enterText(find.byType(TextField), 'Fasting for medical test');
      await tester.pump();

      // Tap Confirm Skip
      await tester.tap(find.widgetWithText(AfyaButton, 'Confirm Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(SkipReasonDialog), findsNothing);
      expect(find.byType(LogActionSheet), findsNothing);
      expect(skippedDose, isNotNull);
      expect(skippedDose!.id, 'dose_skip_test');
      expect(recordedReason, 'Fasting for medical test');
    });
  });
}
