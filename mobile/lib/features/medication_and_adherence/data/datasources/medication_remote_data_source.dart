import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../clinical_history/data/models/encounter_detail_model.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';

abstract class MedicationRemoteDataSource {
  Future<List<EncounterPrescriptionItemModel>> getPrescriptionsByEncounter({
    required String encounterId,
  });

  Future<EncounterPrescriptionItemModel> completePrescription({
    required String prescriptionItemId,
  });
}

@LazySingleton(as: MedicationRemoteDataSource)
class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final ApiClient apiClient;

  MedicationRemoteDataSourceImpl(this.apiClient);

  Dio get _dio => apiClient.dio;

  @override
  Future<List<EncounterPrescriptionItemModel>> getPrescriptionsByEncounter({
    required String encounterId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.encounterPrescriptions(encounterId),
      );

      final data = response.data;
      final List<dynamic> items;

      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          items = data['data'] as List<dynamic>;
        } else if (data['prescriptions'] is List) {
          // If aggregated encounter/prescription headers with nested items
          final prescriptions = data['prescriptions'] as List<dynamic>;
          final flattened = <dynamic>[];
          for (final rx in prescriptions) {
            if (rx is Map<String, dynamic> && rx['items'] is List) {
              flattened.addAll(rx['items'] as List<dynamic>);
            }
          }
          items = flattened;
        } else if (data['items'] is List) {
          items = data['items'] as List<dynamic>;
        } else {
          throw const FormatException(
              'Unexpected prescriptions response structure');
        }
      } else {
        throw const FormatException('Unexpected prescriptions response type');
      }

      return items
          .map(
            (item) => EncounterPrescriptionItemModel.fromJson(
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
        'Invalid prescriptions response: ${error.message}',
        code: 'invalid_response',
      );
    }
  }

  @override
  Future<EncounterPrescriptionItemModel> completePrescription({
    required String prescriptionItemId,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.completePrescription(prescriptionItemId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        if (payload.containsKey('medication_name')) {
          return EncounterPrescriptionItemModel.fromJson(
            Map<String, dynamic>.from(payload),
          );
        }
      }

      // If backend returns a message or 200/204 without full item body, return synthetic updated model
      return EncounterPrescriptionItemModel(
        id: prescriptionItemId,
        medicationName: '',
        dose: '',
        route: '',
        frequency: '',
        duration: '',
        status: EncounterPrescriptionStatus.completed,
        startedAt: DateTime.now(),
      );
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ServerException(
        'Invalid completion response: ${error.message}',
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
