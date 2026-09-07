import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../app/router/app_router.dart';
import '../../features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import '../../features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import '../../features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import '../../features/medication_and_adherence/presentation/widgets/dose_reminder_dialog.dart';
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
        await _handleSkipActionWithReason(
          doseId,
          'skipped_via_notification',
          currentTime,
        );
      } else {
        await _showDoseReminderUI(doseId);
      }
    } catch (_) {
      // Safely ignore or handle malformed/corrupted payload without crashing
    }
  }

  Future<void> _showDoseReminderUI(String doseId) async {
    for (var i = 0; i < 10; i++) {
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null) {
        final model = await _localDataSource.getDoseRecordById(doseId);
        if (model != null && model.status == DoseStatus.pending) {
          if (context.mounted) {
            await DoseReminderDialog.show(
              context,
              doseRecord: model.toEntity(),
              onTaken: (dose) => _handleTakeAction(dose.id, DateTime.now()),
              onSnooze: (dose) => _handleSnoozeAction(dose.id),
              onSkip: (dose, reason) =>
                  _handleSkipActionWithReason(dose.id, reason, DateTime.now()),
            );
          }
        }
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
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

  Future<void> _handleSkipActionWithReason(
    String doseId,
    String reason,
    DateTime now,
  ) async {
    final model = await _localDataSource.getDoseRecordById(doseId);
    if (model == null || model.status != DoseStatus.pending) {
      return;
    }

    final updatedModel = model.copyWith(
      status: DoseStatus.skipped,
      recordedAt: now,
      skipReason: reason,
    );
    await _localDataSource.saveDoseRecord(updatedModel);

    final reminderId = doseId.hashCode & 0x7FFFFFFF;
    await _alarmScheduler.cancelReminder(reminderId);
  }
}
