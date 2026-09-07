import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/widgets/access_request_card.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/access_request_dto.dart';

void main() {
  testWidgets('Buttons are enabled when request not expired', (WidgetTester tester) async {
    final now = DateTime.now();
    final request = AccessRequestDto(
      id: 'req-1',
      clinicId: 'clinic-1',
      clinicName: 'Test Clinic',
      doctorName: 'Dr. Test',
      reason: 'Test reason',
      status: 'pending',
      expiresAt: now.add(const Duration(hours: 1)),
      createdAt: now.subtract(const Duration(minutes: 5)),
    );

    await tester.pumpWidget(MaterialApp(
      home: AccessRequestCard(
        request: request,
        onApprove: () {},
        onDeny: () {},
      ),
    ));

    // Verify that buttons are enabled (onPressed != null)
    final denyButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Deny'));
    final approveButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Approve'));
    expect(denyButton.onPressed, isNotNull);
    expect(approveButton.onPressed, isNotNull);
  });

  testWidgets('Buttons are disabled when request is expired', (WidgetTester tester) async {
    final now = DateTime.now();
    final request = AccessRequestDto(
      id: 'req-2',
      clinicId: 'clinic-2',
      clinicName: 'Expired Clinic',
      doctorName: 'Dr. Expired',
      reason: 'Expired reason',
      status: 'pending',
      expiresAt: now.subtract(const Duration(minutes: 1)),
      createdAt: now.subtract(const Duration(hours: 2)),
    );

    await tester.pumpWidget(MaterialApp(
      home: AccessRequestCard(
        request: request,
        onApprove: () {},
        onDeny: () {},
      ),
    ));

    final denyButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Deny'));
    final approveButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Approve'));
    expect(denyButton.onPressed, isNull);
    expect(approveButton.onPressed, isNull);
  });
}
