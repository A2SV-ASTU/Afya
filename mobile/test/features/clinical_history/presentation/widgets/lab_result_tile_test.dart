import 'package:afyamind_mobile/features/clinical_history/domain/entities/lab_result_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/presentation/widgets/lab_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tLabResult = LabResultEntity(
    id: 'lab-1',
    testName: 'Complete Blood Count (CBC)',
    category: LabResultCategory.laboratory,
    summaryNotes: 'Hemoglobin slightly low',
    measurements: const {'Hemoglobin': '11.5 g/dL', 'WBC': '6.5 x10^3/uL'},
    flag: LabResultFlag.abnormal,
    createdAt: DateTime(2026, 3, 15),
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: LabResultTile(labResult: tLabResult),
      ),
    );
  }

  testWidgets('renders test name, flag badge, and measurements correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Complete Blood Count (CBC)'), findsOneWidget);
    expect(find.text('Abnormal'), findsOneWidget);
    expect(find.text('Hemoglobin'), findsOneWidget);
    expect(find.text('11.5 g/dL'), findsOneWidget);
    expect(find.text('Hemoglobin slightly low'), findsOneWidget);
  });
}
