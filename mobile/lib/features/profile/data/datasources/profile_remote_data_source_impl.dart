import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import 'profile_remote_data_source.dart';

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await apiClient.dio.get(ApiEndpoints.userMe);

    final data = response.data['data'] as Map<String, dynamic>;

    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> updateDemographics({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final response = await apiClient.dio.patch(
      ApiEndpoints.userMe,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'sex': gender,
        'date_of_birth': dateOfBirth == null
            ? null
            : DateFormat('yyyy-MM-dd').format(dateOfBirth),

        // Medical / Emergency Information
        'blood_type': bloodType,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;

    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.put(
        ApiEndpoints.userPassword,
        data: {
          'current_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on ServerException {
      rethrow;
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map && data['error'] is Map
          ? (data['error'] as Map)['message']?.toString()
          : null;
      throw ServerException(
        message ?? error.message ?? 'Unable to change password.',
        code: error.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<void> deactivateAccount() async {
    await apiClient.dio.delete('/users/me');
  }

  @override
Future<void> logout() async {
  try {
    await apiClient.dio.post(ApiEndpoints.logout);
  } finally {
    await apiClient.cookieStorageService.clearCookies();
  }
}
}
