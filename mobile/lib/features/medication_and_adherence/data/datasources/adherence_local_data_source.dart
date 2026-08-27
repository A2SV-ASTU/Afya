import 'package:afyamind_mobile/core/constants/app_keys.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/storage/local_database_service.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/local_dose_schedule_entity.dart';
import '../../domain/entities/prescription_item_entity.dart';
import '../models/local_dose_schedule_model.dart';
import '../models/prescription_item_model.dart';

abstract class AdherenceLocalDataSource {
  /// Saves or updates a list of prescription items in the medication schedule box.
  Future<void> savePrescriptionItems(List<PrescriptionItemModel> items);

  /// Retrieves cached prescription items, optionally filtering by clinical encounter ID.
  Future<List<PrescriptionItemModel>> getPrescriptionItems(
      {String? encounterId});

  /// Retrieves a single prescription item by its unique ID.
  Future<PrescriptionItemModel?> getPrescriptionItemById(String id);

  /// Updates the lifecycle status of a local prescription item (active, completed, deactivated).
  Future<void> updatePrescriptionStatus(
      String id, PrescriptionItemStatus status);

  /// Saves or updates local scheduled dose records in the adherence history box.
  Future<void> saveDoseSchedules(List<LocalDoseScheduleModel> doses);

  /// Retrieves local scheduled doses, optionally filtering by prescription item ID.
  Future<List<LocalDoseScheduleModel>> getDoseSchedules(
      {String? prescriptionItemId});

  /// Retrieves a single local scheduled dose by its unique ID.
  Future<LocalDoseScheduleModel?> getDoseScheduleById(String id);

  /// Records an adherence outcome for a specific dose (taken, missed, skipped) with timestamp.
  Future<void> updateDoseOutcome(String doseId, DoseOutcome outcome,
      {DateTime? loggedAt});

  /// Updates snooze information (snoozeUntil timestamp, incremented snoozeCount) for a scheduled dose.
  Future<void> updateDoseSnooze(String doseId, DateTime snoozeUntil,
      {int? snoozeCount});
}

@LazySingleton(as: AdherenceLocalDataSource)
class AdherenceLocalDataSourceImpl implements AdherenceLocalDataSource {
  final LocalDatabaseService _databaseService;

  AdherenceLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> savePrescriptionItems(List<PrescriptionItemModel> items) async {
    try {
      final box = _databaseService.getBox(AppKeys.medicationScheduleBox);
      final Map<String, dynamic> entries = {
        for (final item in items) item.id: item.toJson(),
      };
      await box.putAll(entries);
    } catch (e) {
      throw CacheException('Failed to save prescription items locally: $e');
    }
  }

  @override
  Future<List<PrescriptionItemModel>> getPrescriptionItems(
      {String? encounterId}) async {
    try {
      final box = _databaseService.getBox(AppKeys.medicationScheduleBox);
      final List<PrescriptionItemModel> items = [];

      for (final dynamic raw in box.values) {
        if (raw is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
          final item = PrescriptionItemModel.fromJson(map);
          if (encounterId == null || item.encounterId == encounterId) {
            items.add(item);
          }
        }
      }

      return items;
    } catch (e) {
      throw CacheException(
          'Failed to retrieve prescription items from local cache: $e');
    }
  }

  @override
  Future<PrescriptionItemModel?> getPrescriptionItemById(String id) async {
    try {
      final box = _databaseService.getBox(AppKeys.medicationScheduleBox);
      final dynamic raw = box.get(id);
      if (raw == null) return null;

      if (raw is Map) {
        return PrescriptionItemModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (e) {
      throw CacheException(
          'Failed to retrieve prescription item by id $id: $e');
    }
  }

  @override
  Future<void> updatePrescriptionStatus(
      String id, PrescriptionItemStatus status) async {
    try {
      final box = _databaseService.getBox(AppKeys.medicationScheduleBox);
      final dynamic raw = box.get(id);
      if (raw == null) {
        throw CacheException(
            'Prescription item $id not found for status update');
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(raw as Map);
      final currentModel = PrescriptionItemModel.fromJson(map);
      final updatedModel = currentModel.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await box.put(id, updatedModel.toJson());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update prescription status for $id: $e');
    }
  }

  @override
  Future<void> saveDoseSchedules(List<LocalDoseScheduleModel> doses) async {
    try {
      final box = _databaseService.getBox(AppKeys.adherenceHistoryBox);
      final Map<String, dynamic> entries = {
        for (final dose in doses) dose.id: dose.toJson(),
      };
      await box.putAll(entries);
    } catch (e) {
      throw CacheException('Failed to save dose schedules locally: $e');
    }
  }

  @override
  Future<List<LocalDoseScheduleModel>> getDoseSchedules(
      {String? prescriptionItemId}) async {
    try {
      final box = _databaseService.getBox(AppKeys.adherenceHistoryBox);
      final List<LocalDoseScheduleModel> doses = [];

      for (final dynamic raw in box.values) {
        if (raw is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
          final dose = LocalDoseScheduleModel.fromJson(map);
          if (prescriptionItemId == null ||
              dose.prescriptionItemId == prescriptionItemId) {
            doses.add(dose);
          }
        }
      }

      // Sort chronological by scheduledTime
      doses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return doses;
    } catch (e) {
      throw CacheException(
          'Failed to retrieve dose schedules from local storage: $e');
    }
  }

  @override
  Future<LocalDoseScheduleModel?> getDoseScheduleById(String id) async {
    try {
      final box = _databaseService.getBox(AppKeys.adherenceHistoryBox);
      final dynamic raw = box.get(id);
      if (raw == null) return null;

      if (raw is Map) {
        return LocalDoseScheduleModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve dose schedule by id $id: $e');
    }
  }

  @override
  Future<void> updateDoseOutcome(String doseId, DoseOutcome outcome,
      {DateTime? loggedAt}) async {
    try {
      final box = _databaseService.getBox(AppKeys.adherenceHistoryBox);
      final dynamic raw = box.get(doseId);
      if (raw == null) {
        throw CacheException(
            'Dose schedule $doseId not found for outcome update');
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(raw as Map);
      final currentModel = LocalDoseScheduleModel.fromJson(map);
      final updatedModel = currentModel.copyWith(
        outcome: outcome,
        loggedAt: loggedAt ?? DateTime.now(),
      );

      await box.put(doseId, updatedModel.toJson());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update dose outcome for $doseId: $e');
    }
  }

  @override
  Future<void> updateDoseSnooze(String doseId, DateTime snoozeUntil,
      {int? snoozeCount}) async {
    try {
      final box = _databaseService.getBox(AppKeys.adherenceHistoryBox);
      final dynamic raw = box.get(doseId);
      if (raw == null) {
        throw CacheException(
            'Dose schedule $doseId not found for snooze update');
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(raw as Map);
      final currentModel = LocalDoseScheduleModel.fromJson(map);
      final updatedModel = currentModel.copyWith(
        snoozeUntil: snoozeUntil,
        snoozeCount: snoozeCount ?? (currentModel.snoozeCount + 1),
      );

      await box.put(doseId, updatedModel.toJson());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update snooze for dose $doseId: $e');
    }
  }
}
