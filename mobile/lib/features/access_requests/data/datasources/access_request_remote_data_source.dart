import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../models/access_request_model.dart';
import '../models/clinic_grant_model.dart';

abstract class AccessRequestRemoteDataSource {
  Future<List<AccessRequestModel>> getPendingAccessRequests();
  Future<void> approveAccessRequest(String requestId);
  Future<void> denyAccessRequest(String requestId);
  Future<List<ClinicGrantModel>> getActiveGrants();
  Future<void> revokeClinicGrant(String clinicId);
}

@LazySingleton(as: AccessRequestRemoteDataSource)
class AccessRequestRemoteDataSourceImpl
    implements AccessRequestRemoteDataSource {
  final ApiClient _apiClient;

  const AccessRequestRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AccessRequestModel>> getPendingAccessRequests() async {
    final response = await _apiClient.dio.get('/patient/access-requests/active');
    final data = response.data as List;
    return data
        .map((json) => AccessRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveAccessRequest(String requestId) async {
    await _apiClient.dio.post('/patient/access-requests/$requestId/approve');
  }

  @override
  Future<void> denyAccessRequest(String requestId) async {
    await _apiClient.dio.post('/patient/access-requests/$requestId/deny');
  }

  @override
  Future<List<ClinicGrantModel>> getActiveGrants() async {
    final response = await _apiClient.dio.get('/patient/grants');
    final data = response.data as List;
    return data
        .map((json) => ClinicGrantModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeClinicGrant(String clinicId) async {
    await _apiClient.dio.post('/patient/grants/$clinicId/revoke');
  }
}
