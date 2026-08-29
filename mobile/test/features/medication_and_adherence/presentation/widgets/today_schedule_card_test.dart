import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/core/widgets/afya_empty_state.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/schedule_item_tile.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/widgets/today_schedule_card.dart';

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

  group('TodayScheduleCard Widget Tests', () {
    testWidgets('renders empty state when there are no scheduled doses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const TodayScheduleCard(
            doses: [],
            emptyMessage: 'No Doses Today',
          ),
        ),
      );

      expect(find.text("Today's Schedule"), findsOneWidget);
      expect(find.byType(AfyaEmptyState), findsOneWidget);
      expect(find.text('No Doses Today'), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
    });

    testWidgets('renders multiple doses in chronological order',
        (WidgetTester tester) async {
      final doseEvening = LocalDoseRecordEntity(
        id: 'dose_evening',
        prescriptionItemId: 'rx_1',
        medicationName: 'Atorvastatin',
        dose: '20mg',
        scheduledTime: DateTime(2026, 8, 29, 20, 0), // 8:00 PM
        status: DoseStatus.pending,
      );

      final doseMorning = LocalDoseRecordEntity(
        id: 'dose_morning',
        prescriptionItemId: 'rx_2',
        medicationName: 'Metformin',
        dose: '500mg',
        scheduledTime: DateTime(2026, 8, 29, 8, 0), // 8:00 AM
        status: DoseStatus.taken,
      );

      final doseMidday = LocalDoseRecordEntity(
        id: 'dose_midday',
        prescriptionItemId: 'rx_3',
        medicationName: 'Amoxicillin',
        dose: '250mg',
        scheduledTime: DateTime(2026, 8, 29, 12, 30), // 12:30 PM
        status: DoseStatus.pending,
      );

      // Supply doses in un-ordered sequence
      await tester.pumpWidget(
        buildTestableWidget(
          TodayScheduleCard(
            doses: [doseEvening, doseMorning, doseMidday],
          ),
        ),
      );

      final tiles = tester.widgetList<ScheduleItemTile>(
        find.byType(ScheduleItemTile),
      ).toList();

      expect(tiles.length, 3);
      expect(tiles[0].doseRecord.id, 'dose_morning');
      expect(tiles[1].doseRecord.id, 'dose_midday');
      expect(tiles[2].doseRecord.id, 'dose_evening');

      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('Atorvastatin'), findsOneWidget);

      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
      expect(find.text('8:00 PM'), findsOneWidget);
    });

    testWidgets('passes resolved routes and instructions to tiles',
        (WidgetTester tester) async {
      final dose = LocalDoseRecordEntity(
        id: 'dose_1',
        prescriptionItemId: 'rx_1',
        medicationName: 'Omeprazole',
        dose: '20mg',
        scheduledTime: DateTime(2026, 8, 29, 7, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          TodayScheduleCard(
            doses: [dose],
            routes: const {'rx_1': 'Oral'},
            instructions: const {'rx_1': 'Take 30 minutes before breakfast'},
          ),
        ),
      );

      expect(find.text('20mg • Oral'), findsOneWidget);
      expect(find.text('Take 30 minutes before breakfast'), findsOneWidget);
    });

    testWidgets('triggers onDoseTap with tapped dose record',
        (WidgetTester tester) async {
      LocalDoseRecordEntity? tappedDose;

      final dose = LocalDoseRecordEntity(
        id: 'dose_tap_card',
        prescriptionItemId: 'rx_1',
        medicationName: 'Cetirizine',
        dose: '10mg',
        scheduledTime: DateTime(2026, 8, 29, 21, 0),
        status: DoseStatus.pending,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          TodayScheduleCard(
            doses: [dose],
            onDoseTap: (d) {
              tappedDose = d;
            },
          ),
        ),
      );

      await tester.tap(find.byType(ScheduleItemTile));
      await tester.pump();

      expect(tappedDose, isNotNull);
      expect(tappedDose!.id, 'dose_tap_card');
      expect(tappedDose!.medicationName, 'Cetirizine');
    });
  });
}
