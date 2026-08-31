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
  // ignore: unused_field
  final ApiClient _apiClient;

  // Mock state for in-memory operations since backend is failing
  final List<ClinicGrantModel> _mockGrants = [
    ClinicGrantModel(
      grantId: 'grant-1',
      clinicId: 'clinic-1',
      clinicName: 'Afya Hospital',
      grantedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ClinicGrantModel(
      grantId: 'grant-2',
      clinicId: 'clinic-2',
      clinicName: 'Addis Ababa Medical Center',
      grantedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<AccessRequestModel> _mockRequests = [
    AccessRequestModel(
      id: 'req-1',
      clinicId: 'clinic-3',
      clinicName: 'St. Paul Hospital',
      doctorName: 'Dr. Jane Smith',
      reason: 'General consultation and review of past medical history.',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 30)),
    )
  ];

  AccessRequestRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AccessRequestModel>> getPendingAccessRequests() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockRequests);
  }

  @override
  Future<void> approveAccessRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockRequests.removeWhere((req) => req.id == requestId);
  }

  @override
  Future<void> denyAccessRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockRequests.removeWhere((req) => req.id == requestId);
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
