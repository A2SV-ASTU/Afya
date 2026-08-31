import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/schedule_item_tile.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  group('ScheduleItemTile Widget Tests', () {
    testWidgets('renders medication name, dosage, route, time, and instructions',
        (WidgetTester tester) async {
      final scheduledTime = DateTime(2026, 8, 29, 8, 30);
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_1',
        prescriptionItemId: 'rx_1',
        medicationName: 'Amoxicillin',
        dose: '500mg',
        scheduledTime: scheduledTime,
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(
            doseRecord: doseRecord,
            route: 'Oral',
            instructions: 'Take with food after meals',
          ),
        ),
      );

      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('500mg • Oral'), findsOneWidget);
      expect(find.text('8:30 AM'), findsOneWidget);
      expect(find.text('Take with food after meals'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('renders Pending status correctly',
        (WidgetTester tester) async {
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_pending',
        prescriptionItemId: 'rx_1',
        medicationName: 'Metformin',
        dose: '850mg',
        scheduledTime: DateTime(2026, 8, 29, 9, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(doseRecord: doseRecord),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('renders Taken status correctly',
        (WidgetTester tester) async {
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_taken',
        prescriptionItemId: 'rx_1',
        medicationName: 'Metformin',
        dose: '850mg',
        scheduledTime: DateTime(2026, 8, 29, 9, 0),
        status: DoseStatus.taken,
        recordedAt: DateTime(2026, 8, 29, 9, 5),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(doseRecord: doseRecord),
        ),
      );

      expect(find.text('TAKEN'), findsOneWidget);
    });

    testWidgets('renders Skipped status correctly',
        (WidgetTester tester) async {
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_skipped',
        prescriptionItemId: 'rx_1',
        medicationName: 'Ibuprofen',
        dose: '400mg',
        scheduledTime: DateTime(2026, 8, 29, 14, 0),
        status: DoseStatus.skipped,
        skipReason: 'Nausea',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(doseRecord: doseRecord),
        ),
      );

      expect(find.text('SKIPPED'), findsOneWidget);
    });

    testWidgets('renders Missed status correctly',
        (WidgetTester tester) async {
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_missed',
        prescriptionItemId: 'rx_1',
        medicationName: 'Lisinopril',
        dose: '10mg',
        scheduledTime: DateTime(2026, 8, 29, 7, 0),
        status: DoseStatus.missed,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(doseRecord: doseRecord),
        ),
      );

      expect(find.text('MISSED'), findsOneWidget);
    });

    testWidgets('displays snoozed until time when present',
        (WidgetTester tester) async {
      final scheduledTime = DateTime(2026, 8, 29, 8, 0);
      final snoozedUntil = DateTime(2026, 8, 29, 8, 30);
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_snoozed',
        prescriptionItemId: 'rx_1',
        medicationName: 'Atorvastatin',
        dose: '20mg',
        scheduledTime: scheduledTime,
        snoozedUntil: snoozedUntil,
        snoozeCount: 1,
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(doseRecord: doseRecord),
        ),
      );

      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('(Snoozed until 8:30 AM)'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped',
        (WidgetTester tester) async {
      var wasTapped = false;
      final doseRecord = LocalDoseRecordEntity(
        id: 'dose_tap',
        prescriptionItemId: 'rx_1',
        medicationName: 'Paracetamol',
        dose: '500mg',
        scheduledTime: DateTime(2026, 8, 29, 12, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleItemTile(
            doseRecord: doseRecord,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(ScheduleItemTile));
      await tester.pump();

      expect(wasTapped, isTrue);
    });
  });
}
