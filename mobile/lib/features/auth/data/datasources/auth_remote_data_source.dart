import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/patient_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<PatientUserModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String email,
    String? dateOfBirth,
    String? sex,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String role = 'patient',
  });

  Future<PatientUserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<PatientUserModel?> refreshSession();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Future<PatientUserModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String email,
    String? dateOfBirth,
    String? sex,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String role = 'patient',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          'phone': phone,
          if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
          if (sex != null && sex.isNotEmpty) 'sex': sex,
          if (bloodType != null && bloodType.isNotEmpty) 'blood_type': bloodType,
          if (emergencyContactName != null && emergencyContactName.isNotEmpty)
            'emergency_contact_name': emergencyContactName,
          if (emergencyContactPhone != null && emergencyContactPhone.isNotEmpty)
            'emergency_contact_phone': emergencyContactPhone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return PatientUserModel.fromJson(data);
      } else {
        throw ServerException(
          response.data?['error']?['message'] ?? 'Registration failed',
          code: response.statusCode?.toString(),
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      final errorMessage = e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Registration request failed';
      throw ServerException(
        errorMessage,
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<PatientUserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return PatientUserModel.fromJson(data);
      } else {
        throw ServerException(
          response.data?['error']?['message'] ?? 'Login failed',
          code: response.statusCode?.toString(),
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      final errorMessage = e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Invalid credentials or network error';
      throw ServerException(
        errorMessage,
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          'Logout failed';
      throw ServerException(
        errorMessage,
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<PatientUserModel?> refreshSession() async {
    try {
      final response = await _dio.post(ApiEndpoints.refresh);
      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return PatientUserModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?['message'] ?? 'Session refresh failed',
        code: e.response?.statusCode?.toString(),
      );
    }
  }
}
