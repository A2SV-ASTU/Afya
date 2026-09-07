import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/access_request_dto.dart';
import '../models/clinic_grant_dto.dart';

abstract class AccessRequestRemoteDataSource {
  Future<List<AccessRequestDto>> getPendingAccessRequests();
  Future<void> approveAccessRequest(String requestId);
  Future<void> denyAccessRequest(String requestId);
  Future<List<ClinicGrantDto>> getActiveGrants();
  Future<void> revokeClinicGrant(String clinicId);
}

@LazySingleton(as: AccessRequestRemoteDataSource)
class AccessRequestRemoteDataSourceImpl implements AccessRequestRemoteDataSource {
  final ApiClient _apiClient;

  // In-memory mock state for demo / local dev / offline mode when backend is unreachable
  final List<ClinicGrantDto> _mockGrants = [
    ClinicGrantDto(
      grantId: 'grant-1',
      clinicId: 'clinic-1',
      clinicName: 'Afya Specialised Hospital',
      // Granted 2 minutes ago, 3 minutes remaining in 5-minute session
      grantedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ClinicGrantDto(
      grantId: 'grant-2',
      clinicId: 'clinic-2',
      clinicName: 'Addis Ababa Medical Center',
      // Granted 1 minute ago, 4 minutes remaining
      grantedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  final List<AccessRequestDto> _mockRequests = [
    AccessRequestDto(
      id: 'req-1',
      clinicId: 'clinic-3',
      clinicName: 'St. Paul Hospital Millennium Medical College',
      doctorName: 'Dr. Jane Smith',
      reason: 'Urgent emergency consultation and review of psychiatric history.',
      status: 'pending',
      // Created 1 minute ago, expires in 4 minutes (5-minute emergency timer)
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      expiresAt: DateTime.now().add(const Duration(minutes: 4)),
    ),
    AccessRequestDto(
      id: 'req-2',
      clinicId: 'clinic-4',
      clinicName: 'Tikur Anbessa Specialized Hospital',
      doctorName: 'Dr. Abebe Bekele',
      reason: 'Specialist psychiatric evaluation and dosage adjustment review.',
      status: 'pending',
      // Created 45 seconds ago, expires in 4 minutes 15 seconds
      createdAt: DateTime.now().subtract(const Duration(seconds: 45)),
      expiresAt: DateTime.now().add(const Duration(minutes: 4, seconds: 15)),
    ),
  ];

  AccessRequestRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AccessRequestDto>> getPendingAccessRequests() async {
    try {
      final response = await _apiClient.dio.get('/access-requests?status=pending');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => AccessRequestDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load pending requests',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? data['message'] ?? 'Server error' : 'Server error';
        throw ServerException(msg.toString(), code: e.response?.statusCode?.toString());
      }
      // Connection timeout or network error — fallback to mock requests so app functions
      return List.from(_mockRequests);
    } catch (e) {
      if (e is ServerException) rethrow;
      return List.from(_mockRequests);
    }
  }

  @override
  Future<void> approveAccessRequest(String requestId) async {
    try {
      final response = await _apiClient.dio.patch(
        '/access-requests/$requestId/decision',
        data: {'decision': 'approve'},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          response.data['message'] ?? 'Failed to approve request',
          code: response.statusCode?.toString(),
        );
      }
      _handleLocalApprove(requestId);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? data['message'] ?? 'Server error' : 'Server error';
        throw ServerException(msg.toString(), code: e.response?.statusCode?.toString());
      }
      _handleLocalApprove(requestId);
    } catch (e) {
      if (e is ServerException) rethrow;
      _handleLocalApprove(requestId);
    }
  }

  @override
  Future<void> denyAccessRequest(String requestId) async {
    try {
      final response = await _apiClient.dio.patch(
        '/access-requests/$requestId/decision',
        data: {'decision': 'deny'},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          response.data['message'] ?? 'Failed to deny request',
          code: response.statusCode?.toString(),
        );
      }
      _mockRequests.removeWhere((req) => req.id == requestId);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? data['message'] ?? 'Server error' : 'Server error';
        throw ServerException(msg.toString(), code: e.response?.statusCode?.toString());
      }
      _mockRequests.removeWhere((req) => req.id == requestId);
    } catch (e) {
      if (e is ServerException) rethrow;
      _mockRequests.removeWhere((req) => req.id == requestId);
    }
  }

  @override
  Future<List<ClinicGrantDto>> getActiveGrants() async {
    try {
      final response = await _apiClient.dio.get('/clinic-grants');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ClinicGrantDto.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load active grants',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? data['message'] ?? 'Server error' : 'Server error';
        throw ServerException(msg.toString(), code: e.response?.statusCode?.toString());
      }
      return List.from(_mockGrants);
    } catch (e) {
      if (e is ServerException) rethrow;
      return List.from(_mockGrants);
    }
  }

  @override
  Future<void> revokeClinicGrant(String clinicId) async {
    try {
      final response = await _apiClient.dio.delete('/clinic-grants/$clinicId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          response.data['message'] ?? 'Failed to revoke grant',
          code: response.statusCode?.toString(),
        );
      }
      _mockGrants.removeWhere((grant) => grant.clinicId == clinicId);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? data['message'] ?? 'Server error' : 'Server error';
        throw ServerException(msg.toString(), code: e.response?.statusCode?.toString());
      }
      _mockGrants.removeWhere((grant) => grant.clinicId == clinicId);
    } catch (e) {
      if (e is ServerException) rethrow;
      _mockGrants.removeWhere((grant) => grant.clinicId == clinicId);
    }
  }

  void _handleLocalApprove(String requestId) {
    final idx = _mockRequests.indexWhere((req) => req.id == requestId);
    if (idx != -1) {
      final req = _mockRequests.removeAt(idx);
      _mockGrants.insert(
        0,
        ClinicGrantDto(
          grantId: 'grant-${DateTime.now().millisecondsSinceEpoch}',
          clinicId: req.clinicId,
          clinicName: req.clinicName,
          grantedAt: DateTime.now(),
        ),
      );
    }
  }
}
