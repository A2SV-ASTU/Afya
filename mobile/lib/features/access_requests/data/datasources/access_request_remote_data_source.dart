import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../models/access_request_model.dart';
import '../models/clinic_grant_model.dart';
import 'access_request_mock_data.dart';

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
  // ignore: unused_field
  final ApiClient _apiClient;

  // In-memory mutable state seeded from AccessRequestMockData.
  late final List<ClinicGrantModel> _mockGrants =
      List.of(AccessRequestMockData.sampleClinicGrants);

  AccessRequestRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AccessRequestModel>> getPendingAccessRequests() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [];
  }

  @override
  Future<void> approveAccessRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> denyAccessRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<ClinicGrantModel>> getActiveGrants() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockGrants);
  }

  @override
  Future<void> revokeClinicGrant(String clinicId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockGrants.removeWhere((grant) => grant.clinicId == clinicId);
  }
}
