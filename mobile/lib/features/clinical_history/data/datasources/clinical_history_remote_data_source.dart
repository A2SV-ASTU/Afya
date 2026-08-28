import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';
import '../models/clinical_evaluation_model.dart';
import '../models/encounter_detail_model.dart';
import '../models/encounter_model.dart';
import '../models/medical_history_summary_model.dart';

abstract class ClinicalHistoryRemoteDataSource {
  Future<List<EncounterModel>> getEncountersTimeline({
    required String patientId,
    required int page,
    required int limit,
  });

  Future<MedicalHistorySummaryModel> getCondensedMedicalHistory({
    required String encounterId,
  });

  Future<EncounterDetailModel> getEncounterDetail({
    required String encounterId,
  });

  Future<ClinicalEvaluationModel?> getClinicalEvaluation({
    required String encounterId,
  });

  Future<List<AppointmentModel>> getAppointments({
    required String patientId,
    String? status,
  });
}

@LazySingleton(as: ClinicalHistoryRemoteDataSource)
class ClinicalHistoryRemoteDataSourceImpl
    implements ClinicalHistoryRemoteDataSource {
  final ApiClient apiClient;

  ClinicalHistoryRemoteDataSourceImpl(this.apiClient);

  Dio get _dio => apiClient.dio;

  @override
  Future<List<EncounterModel>> getEncountersTimeline({
    required String patientId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/patients/$patientId/encounters',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;

      // Defensive support for either:
      // [ {...}, {...} ]
      //
      // or:
      // {
      //   "data": [ {...}, {...} ],
      //   "page": 1,
      //   "limit": 20,
      //   "total": 2
      // }
      final List<dynamic> items;

      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        items = data['data'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Unexpected encounters response format',
        );
      }

      return items
          .map(
            (item) => EncounterModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid encounters response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  @override
  Future<MedicalHistorySummaryModel> getCondensedMedicalHistory({
    required String encounterId,
  }) async {
    try {
      final response = await _dio.get(
        '/encounters/$encounterId/medical-history',
      );

      return MedicalHistorySummaryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid medical history response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  @override
  Future<EncounterDetailModel> getEncounterDetail({
    required String encounterId,
  }) async {
    try {
      final response = await _dio.get(
        '/encounters/$encounterId',
      );

      return EncounterDetailModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid encounter detail response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  @override
  Future<ClinicalEvaluationModel?> getClinicalEvaluation({
    required String encounterId,
  }) async {
    try {
      final response = await _dio.get(
        '/encounters/$encounterId/clinical-evaluation',
      );

      final body = Map<String, dynamic>.from(
        response.data as Map,
      );

      final evaluation = body['clinical_evaluation'];

      if (evaluation == null) {
        return null;
      }

      return ClinicalEvaluationModel.fromJson(
        Map<String, dynamic>.from(evaluation as Map),
      );
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      // A missing evaluation should not make the entire
      // encounter unusable.
      if (error.response?.statusCode == 404) {
        return null;
      }

      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid clinical evaluation response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointments({
    required String patientId,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/patients/$patientId/appointments',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const FormatException(
          'Unexpected appointments response format',
        );
      }

      return data
          .map(
            (item) => AppointmentModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid appointments response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  ServerException _mapDioException(DioException error) {
    final response = error.response;

    if (response?.data is Map) {
      final body = Map<String, dynamic>.from(
        response!.data as Map,
      );

      final errorBody = body['error'];

      if (errorBody is Map) {
        final mapped = Map<String, dynamic>.from(errorBody);

        return ServerException(
          mapped['message'] as String? ?? 'A server error occurred',
          code: mapped['code'] as String?,
        );
      }
    }

    return ServerException(
      error.message ?? 'Unable to reach the server',
      code: 'network_error',
    );
  }
}
