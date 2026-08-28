import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/appointment_model.dart';
import '../models/clinical_evaluation_model.dart';
import '../models/encounter_detail_model.dart';
import '../models/encounter_model.dart';
import '../models/medical_history_summary_model.dart';

class CachedEncounterDetail {
  final EncounterDetailModel detail;
  final ClinicalEvaluationModel? clinicalEvaluation;

  const CachedEncounterDetail({
    required this.detail,
    this.clinicalEvaluation,
  });

  Map<String, dynamic> toJson() {
    return {
      'detail': detail.toJson(),
      if (clinicalEvaluation != null)
        'clinical_evaluation': clinicalEvaluation!.toJson(),
    };
  }

  factory CachedEncounterDetail.fromJson(Map<String, dynamic> json) {
    return CachedEncounterDetail(
      detail: EncounterDetailModel.fromJson(
        Map<String, dynamic>.from(json['detail'] as Map),
      ),
      clinicalEvaluation: json['clinical_evaluation'] != null
          ? ClinicalEvaluationModel.fromJson(
              Map<String, dynamic>.from(
                json['clinical_evaluation'] as Map,
              ),
            )
          : null,
    );
  }
}

abstract class ClinicalHistoryLocalDataSource {
  Future<void> cacheEncounters(
    String patientId,
    List<EncounterModel> encounters,
  );

  Future<List<EncounterModel>> getCachedEncounters(
    String patientId,
  );

  Future<void> cacheMedicalHistory(
    MedicalHistorySummaryModel summary,
  );

  Future<MedicalHistorySummaryModel> getCachedMedicalHistory(
    String encounterId,
  );

  Future<void> cacheEncounterDetail(
    String encounterId,
    EncounterDetailModel detail,
    ClinicalEvaluationModel? clinicalEvaluation,
  );

  Future<CachedEncounterDetail> getCachedEncounterDetail(
    String encounterId,
  );

  Future<void> cacheAppointments(
    String patientId,
    List<AppointmentModel> appointments,
  );

  Future<List<AppointmentModel>> getCachedAppointments(
    String patientId,
  );
}

@LazySingleton(as: ClinicalHistoryLocalDataSource)
class ClinicalHistoryLocalDataSourceImpl
    implements ClinicalHistoryLocalDataSource {
  final Box? _customBox;

  ClinicalHistoryLocalDataSourceImpl() : _customBox = null;

  ClinicalHistoryLocalDataSourceImpl.withBox(Box box) : _customBox = box;

  Box get _box => _customBox ?? Hive.box(AppKeys.clinicalHistoryCacheBox);

  @override
  Future<void> cacheEncounters(
    String patientId,
    List<EncounterModel> encounters,
  ) async {
    try {
      final jsonList = encounters.map((e) => e.toJson()).toList();
      await _box.put('encounters_$patientId', jsonList);
    } catch (e) {
      throw CacheException('Failed to cache encounters: $e');
    }
  }

  @override
  Future<List<EncounterModel>> getCachedEncounters(
    String patientId,
  ) async {
    try {
      final raw = _box.get('encounters_$patientId');
      if (raw == null || raw is! List) {
        throw const CacheException('No cached encounters found');
      }
      return raw
          .map((item) => EncounterModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached encounters: $e');
    }
  }

  @override
  Future<void> cacheMedicalHistory(
    MedicalHistorySummaryModel summary,
  ) async {
    try {
      await _box.put('summary_${summary.encounterId}', summary.toJson());
    } catch (e) {
      throw CacheException('Failed to cache medical history: $e');
    }
  }

  @override
  Future<MedicalHistorySummaryModel> getCachedMedicalHistory(
    String encounterId,
  ) async {
    try {
      final raw = _box.get('summary_$encounterId');
      if (raw == null || raw is! Map) {
        throw const CacheException('No cached medical history found');
      }
      return MedicalHistorySummaryModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached medical history: $e');
    }
  }

  @override
  Future<void> cacheEncounterDetail(
    String encounterId,
    EncounterDetailModel detail,
    ClinicalEvaluationModel? clinicalEvaluation,
  ) async {
    try {
      final cached = CachedEncounterDetail(
        detail: detail,
        clinicalEvaluation: clinicalEvaluation,
      );
      await _box.put('detail_$encounterId', cached.toJson());
    } catch (e) {
      throw CacheException('Failed to cache encounter detail: $e');
    }
  }

  @override
  Future<CachedEncounterDetail> getCachedEncounterDetail(
    String encounterId,
  ) async {
    try {
      final raw = _box.get('detail_$encounterId');
      if (raw == null || raw is! Map) {
        throw const CacheException('No cached encounter detail found');
      }
      return CachedEncounterDetail.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached encounter detail: $e');
    }
  }

  @override
  Future<void> cacheAppointments(
    String patientId,
    List<AppointmentModel> appointments,
  ) async {
    try {
      final jsonList = appointments.map((a) => a.toJson()).toList();
      await _box.put('appointments_$patientId', jsonList);
    } catch (e) {
      throw CacheException('Failed to cache appointments: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getCachedAppointments(
    String patientId,
  ) async {
    try {
      final raw = _box.get('appointments_$patientId');
      if (raw == null || raw is! List) {
        throw const CacheException('No cached appointments found');
      }
      return raw
          .map((item) => AppointmentModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read cached appointments: $e');
    }
  }
}
