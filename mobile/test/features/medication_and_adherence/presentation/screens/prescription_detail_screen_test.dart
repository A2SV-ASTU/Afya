import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/core/widgets/afya_empty_state.dart';
import 'package:afyamind_mobile/core/widgets/afya_status_badge.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/presentation/screens/prescription_detail_screen.dart';

void main() {
  final tActivePrescription = EncounterPrescriptionItemEntity(
    id: 'rx_101',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    route: 'Oral',
    frequency: 'Take 1 capsule every 8 hours',
    duration: '7 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take with full glass of water after meals',
    startedAt: DateTime(2026, 8, 29),
  );

  final tCompletedPrescription = EncounterPrescriptionItemEntity(
    id: 'rx_102',
    medicationName: 'Azithromycin',
    dose: '250mg',
    route: 'Oral',
    frequency: 'Once daily',
    duration: '3 days',
    status: EncounterPrescriptionStatus.completed,
    instructions: 'Complete entire course',
    startedAt: DateTime(2026, 8, 20),
  );

  final tDeactivatedPrescription = EncounterPrescriptionItemEntity(
    id: 'rx_103',
    medicationName: 'Ibuprofen',
    dose: '400mg',
    route: 'Oral',
    frequency: 'As needed for pain',
    duration: '5 days',
    status: EncounterPrescriptionStatus.deactivated,
    instructions: 'Discontinued due to mild stomach discomfort',
    startedAt: DateTime(2026, 8, 25),
  );

  final tEncounter = EncounterEntity(
    id: 'enc_001',
    patientId: 'patient_1',
    clinicId: 'clinic_1',
    openedByDoctorId: 'doc_1',
    doctorName: 'Sarah Jenkins',
    clinicName: 'Afya Main Clinic, Nairobi',
    status: EncounterStatus.closed,
    startedAt: DateTime(2026, 8, 29),
  );

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('PrescriptionDetailScreen Widget Tests - Part 1 & Part 2', () {
    testWidgets('1-3. renders medication name, dose, and route correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tActivePrescription),
        ),
      );

      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Amoxicillin'), findsOneWidget);

      expect(find.text('Dose'), findsOneWidget);
      expect(find.text('500mg'), findsOneWidget);

      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Oral'), findsWidgets);
    });

    testWidgets(
        '4-6. renders frequency, duration, and instructions from entity',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tActivePrescription),
        ),
      );

      // Frequency
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Take 1 capsule every 8 hours'), findsOneWidget);

      // Duration
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);

      // Instructions
      expect(find.text('Instructions'), findsOneWidget);
      expect(
        find.text('Take with full glass of water after meals'),
        findsOneWidget,
      );
    });

    testWidgets('7. renders authoring doctor and clinic source when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(
            prescription: tActivePrescription,
            doctorName: 'Sarah Jenkins',
            clinicName: 'Afya Main Clinic, Nairobi',
          ),
        ),
      );

      expect(find.text('PRESCRIBER'), findsOneWidget);
      expect(find.text('Authoring Doctor'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Clinic / Facility'), findsOneWidget);
      expect(find.text('Afya Main Clinic, Nairobi'), findsOneWidget);
    });

    testWidgets('7b. renders authoring doctor from encounter object',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(
            prescription: tActivePrescription,
            encounter: tEncounter,
          ),
        ),
      );

      expect(find.text('PRESCRIBER'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Afya Main Clinic, Nairobi'), findsOneWidget);
    });

    testWidgets('8. renders Active status badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tActivePrescription),
        ),
      );

      final badgeFinder = find.byType(AfyaStatusBadge);
      expect(badgeFinder, findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      final badgeWidget = tester.widget<AfyaStatusBadge>(badgeFinder);
      expect(badgeWidget.type, equals(BadgeType.active));
      expect(badgeWidget.label, equals('Active'));
    });

    testWidgets('9. renders Completed status badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tCompletedPrescription),
        ),
      );

      final badgeFinder = find.byType(AfyaStatusBadge);
      expect(badgeFinder, findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);

      final badgeWidget = tester.widget<AfyaStatusBadge>(badgeFinder);
      expect(badgeWidget.type, equals(BadgeType.completed));
      expect(badgeWidget.label, equals('Completed'));
    });

    testWidgets('10. renders Deactivated status badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tDeactivatedPrescription),
        ),
      );

      final badgeFinder = find.byType(AfyaStatusBadge);
      expect(badgeFinder, findsOneWidget);
      expect(find.text('DEACTIVATED'), findsOneWidget);

      final badgeWidget = tester.widget<AfyaStatusBadge>(badgeFinder);
      expect(badgeWidget.type, equals(BadgeType.deactivated));
      expect(badgeWidget.label, equals('Deactivated'));
    });

    testWidgets('11. renders read-only informational notice banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(prescription: tActivePrescription),
        ),
      );

      expect(
        find.text(
          'This prescription cannot be edited — contact your clinic for changes.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('12. strictly read-only: no edit, delete, or save controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(
            prescription: tActivePrescription,
            doctorName: 'Sarah Jenkins',
          ),
        ),
      );

      // Verify no input fields exist
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(EditableText), findsNothing);

      // Verify no action buttons for modifying prescription exist
      expect(find.text('Edit'), findsNothing);
      expect(find.text('EDIT'), findsNothing);
      expect(find.text('Save'), findsNothing);
      expect(find.text('SAVE'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(find.text('DELETE'), findsNothing);

      // Verify no edit/delete icons exist
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('13. renders back button in app bar and pops on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PrescriptionDetailScreen(
                        prescription: tActivePrescription,
                      ),
                    ),
                  );
                },
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(PrescriptionDetailScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(PrescriptionDetailScreen), findsNothing);
      expect(find.text('Open Detail'), findsOneWidget);
    });
  });

  group('PrescriptionDetailScreen Widget Tests - Part 3 Empty State', () {
    testWidgets('Test 1 — Empty State displays title and supporting message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrescriptionDetailScreen(prescription: null),
        ),
      );

      expect(find.text('No prescriptions'), findsOneWidget);
      expect(
        find.text("You don't have any prescriptions at the moment."),
        findsOneWidget,
      );
    });

    testWidgets(
        'Test 2 — No prescription data is rendered when prescription is absent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrescriptionDetailScreen(prescription: null),
        ),
      );

      // Verify specific prescription data is absent
      expect(find.text('Medication'), findsNothing);
      expect(find.text('Amoxicillin'), findsNothing);
      expect(find.text('Dose'), findsNothing);
      expect(find.text('500mg'), findsNothing);
      expect(find.text('Route'), findsNothing);
      expect(find.text('Oral'), findsNothing);
      expect(find.text('Frequency'), findsNothing);
      expect(find.text('Duration'), findsNothing);
      expect(find.text('Instructions'), findsNothing);
      expect(find.text('PRESCRIPTION DETAILS'), findsNothing);
      expect(find.text('PRESCRIBER'), findsNothing);

      // Status badges should be absent
      expect(find.byType(AfyaStatusBadge), findsNothing);
      expect(find.text('ACTIVE'), findsNothing);
      expect(find.text('COMPLETED'), findsNothing);
      expect(find.text('DEACTIVATED'), findsNothing);

      // Notice banner should be absent
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets(
        'Test 3 — Empty State layout renders AfyaEmptyState with medication icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PrescriptionDetailScreen(prescription: null),
        ),
      );

      final emptyStateFinder = find.byType(AfyaEmptyState);
      expect(emptyStateFinder, findsOneWidget);

      final emptyStateWidget = tester.widget<AfyaEmptyState>(emptyStateFinder);
      expect(emptyStateWidget.title, equals('No prescriptions'));
      expect(
        emptyStateWidget.subtitle,
        equals("You don't have any prescriptions at the moment."),
      );
      expect(emptyStateWidget.icon, equals(Icons.medication_outlined));
    });

    testWidgets('Test 4 — Back Navigation works from empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const PrescriptionDetailScreen(prescription: null),
                    ),
                  );
                },
                child: const Text('Open Empty Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Empty Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(PrescriptionDetailScreen), findsOneWidget);
      expect(find.text('No prescriptions'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(PrescriptionDetailScreen), findsNothing);
      expect(find.text('Open Empty Detail'), findsOneWidget);
    });

    testWidgets('Test 5 — Existing populated prescription regression check',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PrescriptionDetailScreen(
            prescription: tActivePrescription,
            doctorName: 'Sarah Jenkins',
          ),
        ),
      );

      // Verify empty state is NOT shown
      expect(find.byType(AfyaEmptyState), findsNothing);
      expect(find.text('No prescriptions'), findsNothing);

      // Verify populated data IS shown
      expect(find.text('Amoxicillin 500mg'), findsOneWidget);
      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('500mg'), findsOneWidget);
      expect(find.text('Oral'), findsWidgets);
      expect(find.text('Take 1 capsule every 8 hours'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(
        find.text('Take with full glass of water after meals'),
        findsOneWidget,
      );
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });
  });
}
