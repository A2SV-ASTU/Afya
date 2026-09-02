import 'package:dio/dio.dart';

import '../models/access_request_model.dart';
import '../models/clinic_grant_model.dart';

abstract class AccessRequestRemoteDataSource {
  Future<List<AccessRequestModel>> getPendingAccessRequests();
  Future<void> approveAccessRequest(String requestId);
  Future<void> denyAccessRequest(String requestId);
  Future<List<ClinicGrantModel>> getActiveGrants();
  Future<void> revokeClinicGrant(String clinicId);
}

class AccessRequestRemoteDataSourceImpl
    implements AccessRequestRemoteDataSource {
  final Dio dio;

  const AccessRequestRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AccessRequestModel>> getPendingAccessRequests() async {
    final response = await dio.get('/patient/access-requests/active');
    final data = response.data as List;
    return data
        .map((json) => AccessRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveAccessRequest(String requestId) async {
    await dio.post('/patient/access-requests/$requestId/approve');
  }

  @override
  Future<void> denyAccessRequest(String requestId) async {
    await dio.post('/patient/access-requests/$requestId/deny');
  }

  @override
  Future<List<ClinicGrantModel>> getActiveGrants() async {
    final response = await dio.get('/patient/grants');
    final data = response.data as List;
    return data
        .map((json) => ClinicGrantModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeClinicGrant(String clinicId) async {
    await dio.post('/patient/grants/$clinicId/revoke');
  }
}
