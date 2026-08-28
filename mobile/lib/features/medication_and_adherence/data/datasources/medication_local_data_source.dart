import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../clinical_history/data/models/encounter_detail_model.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../models/local_dose_record_model.dart';

abstract class MedicationLocalDataSource {
  Future<void> cachePrescriptions(List<EncounterPrescriptionItemModel> items);
  Future<List<EncounterPrescriptionItemModel>> getCachedPrescriptions();
  Future<void> updatePrescriptionStatus(
    String prescriptionItemId,
    EncounterPrescriptionStatus status,
  );

  Future<void> saveDoseRecord(LocalDoseRecordModel record);
  Future<List<LocalDoseRecordModel>> getDoseRecords({
    DateTime? forDate,
    String? prescriptionItemId,
  });
  Future<LocalDoseRecordModel?> getDoseRecordById(String id);
  Future<void> deleteDoseRecord(String id);
  Future<void> clearAdherenceHistory();
}

@LazySingleton(as: MedicationLocalDataSource)
class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final Box? _customScheduleBox;
  final Box? _customAdherenceBox;

  MedicationLocalDataSourceImpl()
      : _customScheduleBox = null,
        _customAdherenceBox = null;

  MedicationLocalDataSourceImpl.withBoxes({
    required Box scheduleBox,
    required Box adherenceBox,
  })  : _customScheduleBox = scheduleBox,
        _customAdherenceBox = adherenceBox;

  Box get _scheduleBox =>
      _customScheduleBox ?? Hive.box(AppKeys.medicationScheduleBox);

  Box get _adherenceBox =>
      _customAdherenceBox ?? Hive.box(AppKeys.adherenceHistoryBox);

  @override
  Future<void> cachePrescriptions(
    List<EncounterPrescriptionItemModel> items,
  ) async {
    try {
      final jsonMap = <String, dynamic>{};
      for (final item in items) {
        jsonMap[item.id] = item.toJson();
      }
      await _scheduleBox.putAll(jsonMap);
    } catch (e) {
      throw CacheException('Failed to cache prescriptions: $e');
    }
  }

  @override
  Future<List<EncounterPrescriptionItemModel>> getCachedPrescriptions() async {
    try {
      final items = <EncounterPrescriptionItemModel>[];
      for (final key in _scheduleBox.keys) {
        final raw = _scheduleBox.get(key);
        if (raw is Map) {
          items.add(
            EncounterPrescriptionItemModel.fromJson(
              Map<String, dynamic>.from(raw),
            ),
          );
        }
      }
      if (items.isEmpty) {
        throw const CacheException('No cached prescriptions found');
      }
      return items;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached prescriptions: $e');
    }
  }

  @override
  Future<void> updatePrescriptionStatus(
    String prescriptionItemId,
    EncounterPrescriptionStatus status,
  ) async {
    try {
      final raw = _scheduleBox.get(prescriptionItemId);
      if (raw != null && raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        map['status'] = status.name;
        await _scheduleBox.put(prescriptionItemId, map);
      }
    } catch (e) {
      throw CacheException('Failed to update prescription status: $e');
    }
  }

  @override
  Future<void> saveDoseRecord(LocalDoseRecordModel record) async {
    try {
      await _adherenceBox.put(record.id, record.toJson());
    } catch (e) {
      throw CacheException('Failed to save dose record: $e');
    }
  }

  @override
  Future<List<LocalDoseRecordModel>> getDoseRecords({
    DateTime? forDate,
    String? prescriptionItemId,
  }) async {
    try {
      final records = <LocalDoseRecordModel>[];
      for (final key in _adherenceBox.keys) {
        final raw = _adherenceBox.get(key);
        if (raw is Map) {
          final model = LocalDoseRecordModel.fromJson(
            Map<String, dynamic>.from(raw),
          );

          var matches = true;

          if (prescriptionItemId != null &&
              model.prescriptionItemId != prescriptionItemId) {
            matches = false;
          }

          if (forDate != null) {
            final st = model.scheduledTime;
            final isSameDay = st.year == forDate.year &&
                st.month == forDate.month &&
                st.day == forDate.day;
            if (!isSameDay) {
              matches = false;
            }
          }

          if (matches) {
            records.add(model);
          }
        }
      }

      records.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return records;
    } catch (e) {
      throw CacheException('Failed to retrieve dose records: $e');
    }
  }

  @override
  Future<LocalDoseRecordModel?> getDoseRecordById(String id) async {
    try {
      final raw = _adherenceBox.get(id);
      if (raw == null || raw is! Map) {
        return null;
      }
      return LocalDoseRecordModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } catch (e) {
      throw CacheException('Failed to get dose record by id: $e');
    }
  }

  @override
  Future<void> deleteDoseRecord(String id) async {
    try {
      await _adherenceBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete dose record: $e');
    }
  }

  @override
  Future<void> clearAdherenceHistory() async {
    try {
      await _adherenceBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear adherence history: $e');
    }
  }
}
