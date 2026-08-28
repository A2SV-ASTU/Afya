import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/widgets/encounter_timeline_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tEncounter = EncounterEntity(
    id: 'enc-1',
    clinicId: 'clinic-1',
    clinicName: 'Grace Medical Center',
    openedByDoctorId: 'doc-1',
    doctorName: 'Adam Smith',
    patientId: 'p-100',
    status: EncounterStatus.closed,
    startedAt: DateTime(2026, 3, 15),
  );

  Widget createWidgetUnderTest(VoidCallback onTap) {
    return MaterialApp(
      home: Scaffold(
        body: EncounterTimelineCard(
          encounter: tEncounter,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('renders clinic name, doctor name, and status badge correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(() {}));

    expect(find.text('Grace Medical Center'), findsOneWidget);
    expect(find.text('Dr. Adam Smith'), findsOneWidget);
    expect(find.text('CLOSED'), findsOneWidget);
  });

  testWidgets('triggers onTap callback when card is tapped',
      (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(createWidgetUnderTest(() {
      tapped = true;
    }));

    await tester.tap(find.byType(EncounterTimelineCard));
    expect(tapped, isTrue);
  });
}
