import 'package:afyamind_mobile/core/constants/api_endpoints.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/prescription_item_model.dart';

abstract class PrescriptionRemoteDataSource {
  /// Fetches prescription items associated with the given clinical encounter ID.
  Future<List<PrescriptionItemModel>> getPrescriptionsForEncounter(
      String encounterId);

  /// Triggers full prescription completion on the backend. No request body is sent.
  Future<void> completePrescription(String id);
}

@LazySingleton(as: PrescriptionRemoteDataSource)
class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final ApiClient _apiClient;

  PrescriptionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PrescriptionItemModel>> getPrescriptionsForEncounter(
      String encounterId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.encounterPrescriptions(encounterId),
      );

      final dynamic responseData = response.data;
      final List<dynamic> itemsList;

      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        final data = responseData['data'];
        if (data is List) {
          itemsList = data;
        } else if (data is Map<String, dynamic> &&
            data['items'] != null &&
            data['items'] is List) {
          itemsList = data['items'] as List;
        } else if (data is Map<String, dynamic>) {
          itemsList = [data];
        } else {
          itemsList = [];
        }
      } else if (responseData is List) {
        itemsList = responseData;
      } else {
        itemsList = [];
      }

      return itemsList
          .map((item) =>
              PrescriptionItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on ExpiredException {
      rethrow;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error']?['message'] as String? ??
              e.message ??
              'Server error')
          : (e.message ?? 'Server error');
      throw ServerException(message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> completePrescription(String id) async {
    try {
      await _apiClient.dio.patch(
        ApiEndpoints.completePrescription(id),
        data: null, // PATCH has no request body
      );
    } on ServerException {
      rethrow;
    } on ExpiredException {
      rethrow;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error']?['message'] as String? ??
              e.message ??
              'Server error')
          : (e.message ?? 'Server error');
      throw ServerException(message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
