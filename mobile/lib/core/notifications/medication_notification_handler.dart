import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import '../../features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import '../../features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import 'local_alarm_scheduler.dart';
import 'notification_payload.dart';

@lazySingleton
class MedicationNotificationHandler {
  final MedicationLocalDataSource _localDataSource;
  final LocalAlarmScheduler _alarmScheduler;
  final HandleSnoozeUseCase _handleSnoozeUseCase;

  const MedicationNotificationHandler(
    this._localDataSource,
    this._alarmScheduler,
    this._handleSnoozeUseCase,
  );

  Future<void> handleNotificationResponse(
    NotificationResponse response, {
    DateTime? now,
  }) async {
    try {
      final payloadStr = response.payload;
      if (payloadStr == null || payloadStr.isEmpty) {
        return;
      }

      final Map<String, dynamic> json =
          jsonDecode(payloadStr) as Map<String, dynamic>;
      final payload = NotificationPayload.fromJson(json);

      final doseId = payload.doseId;
      if (payload.type != 'medication' || doseId == null || doseId.isEmpty) {
        return;
      }

      final actionId = response.actionId;
      final currentTime = now ?? DateTime.now();

      if (actionId == 'take') {
        await _handleTakeAction(doseId, currentTime);
      } else if (actionId == 'snooze') {
        await _handleSnoozeAction(doseId);
      } else if (actionId == 'skip') {
        await _handleSkipAction(doseId, currentTime);
      }
    } catch (_) {
      // Safely ignore or handle malformed/corrupted payload without crashing
    }
  }

  Future<void> _handleTakeAction(String doseId, DateTime now) async {
    final model = await _localDataSource.getDoseRecordById(doseId);
    if (model == null || model.status != DoseStatus.pending) {
      return;
    }

    final updatedModel = model.copyWith(
      status: DoseStatus.taken,
      recordedAt: now,
    );
    await _localDataSource.saveDoseRecord(updatedModel);

    final reminderId = doseId.hashCode & 0x7FFFFFFF;
    await _alarmScheduler.cancelReminder(reminderId);
  }

  Future<void> _handleSnoozeAction(String doseId) async {
    await _handleSnoozeUseCase(doseId: doseId);
  }

  Future<void> _handleSkipAction(String doseId, DateTime now) async {
    final model = await _localDataSource.getDoseRecordById(doseId);
    if (model == null || model.status != DoseStatus.pending) {
      return;
    }

    final updatedModel = model.copyWith(
      status: DoseStatus.skipped,
      recordedAt: now,
      skipReason: 'skipped_via_notification',
    );
    await _localDataSource.saveDoseRecord(updatedModel);

    final reminderId = doseId.hashCode & 0x7FFFFFFF;
    await _alarmScheduler.cancelReminder(reminderId);
  }
}
