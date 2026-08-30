import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/core/notifications/medication_notification_handler.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

class MockHandleSnoozeUseCase extends Mock implements HandleSnoozeUseCase {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late MockHandleSnoozeUseCase mockHandleSnoozeUseCase;
  late MedicationNotificationHandler handler;

  setUpAll(() {
    registerFallbackValue(
      LocalDoseRecordModel(
        id: 'fb_id',
        prescriptionItemId: 'fb_rx',
        medicationName: 'fb_med',
        dose: '100mg',
        scheduledTime: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    mockHandleSnoozeUseCase = MockHandleSnoozeUseCase();
    handler = MedicationNotificationHandler(
      mockLocalDataSource,
      mockAlarmScheduler,
      mockHandleSnoozeUseCase,
    );
  });

  const testDoseId = 'rx_1_1787904000000';
  final scheduledTime = DateTime(2026, 8, 28, 8, 0);
  final fixedNow = DateTime(2026, 8, 28, 8, 5);

  LocalDoseRecordModel createModel({
    String id = testDoseId,
    DoseStatus status = DoseStatus.pending,
  }) {
    return LocalDoseRecordModel(
      id: id,
      prescriptionItemId: 'rx_1',
      medicationName: 'Amoxicillin',
      dose: '500mg',
      scheduledTime: scheduledTime,
      status: status,
    );
  }

  String createPayloadJson({
    String doseId = testDoseId,
    String type = 'medication',
  }) {
    return jsonEncode({
      'id': doseId,
      'type': type,
      'title': 'Medication Reminder',
      'body': 'Take 500mg Amoxicillin',
      'data': {
        'dose_id': doseId,
        'prescription_item_id': 'rx_1',
      },
    });
  }

  group('MedicationNotificationHandler - Action Handling', () {
    test(
        'take action updates dose to taken, sets recordedAt, and cancels reminder',
        () async {
      final model = createModel(status: DoseStatus.pending);

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: createPayloadJson(),
      );

      await handler.handleNotificationResponse(response, now: fixedNow);

      final captured = verify(
        () => mockLocalDataSource.saveDoseRecord(captureAny()),
      ).captured.first as LocalDoseRecordModel;

      expect(captured.status, DoseStatus.taken);
      expect(captured.recordedAt, fixedNow);

      final reminderId = testDoseId.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId)).called(1);
    });

    test('snooze action delegates directly to HandleSnoozeUseCase', () async {
      when(() => mockHandleSnoozeUseCase(
            doseId: testDoseId,
          )).thenAnswer((_) async => Right(createModel().toEntity()));

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'snooze',
        payload: createPayloadJson(),
      );

      await handler.handleNotificationResponse(response, now: fixedNow);

      verify(() => mockHandleSnoozeUseCase(doseId: testDoseId)).called(1);
    });

    test(
        'skip action updates dose to skipped, sets skipReason, and cancels reminder',
        () async {
      final model = createModel(status: DoseStatus.pending);

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'skip',
        payload: createPayloadJson(),
      );

      await handler.handleNotificationResponse(response, now: fixedNow);

      final captured = verify(
        () => mockLocalDataSource.saveDoseRecord(captureAny()),
      ).captured.first as LocalDoseRecordModel;

      expect(captured.status, DoseStatus.skipped);
      expect(captured.recordedAt, fixedNow);
      expect(captured.skipReason, 'skipped_via_notification');

      final reminderId = testDoseId.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId)).called(1);
    });

    test('action on non-pending dose does not modify or overwrite record',
        () async {
      final model = createModel(status: DoseStatus.taken);

      when(() => mockLocalDataSource.getDoseRecordById(testDoseId))
          .thenAnswer((_) async => model);

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: createPayloadJson(),
      );

      await handler.handleNotificationResponse(response, now: fixedNow);

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('malformed payload json or null payload does not throw or crash',
        () async {
      const responseNull = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: null,
      );

      const responseMalformed = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: 'not-a-valid-json',
      );

      await handler.handleNotificationResponse(responseNull);
      await handler.handleNotificationResponse(responseMalformed);

      verifyNever(() => mockLocalDataSource.getDoseRecordById(any()));
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });
  });
}
