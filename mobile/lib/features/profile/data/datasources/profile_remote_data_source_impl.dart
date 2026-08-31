import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import 'profile_remote_data_source.dart';

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await apiClient.dio.get('/users/me');

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<ProfileModel> updateDemographics({
    required String firstName,
    required String lastName,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final response = await apiClient.dio.patch(
      '/users/me',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'gender': gender,
        'date_of_birth': dateOfBirth?.toIso8601String(),
      },
    );

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.dio.patch(
      '/users/me/password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> deactivateAccount() async {
    await apiClient.dio.delete('/users/me');
  }

  @override
  Future<void> logout() async {
    await apiClient.dio.post('/auth/logout');
  }
}