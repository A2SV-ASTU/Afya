import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/profile_model.dart';
import 'profile_local_data_source.dart';

@LazySingleton(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box box;

  ProfileLocalDataSourceImpl()
      : box = Hive.box(AppKeys.profileBox);

  static const String _profileKey = 'cached_profile';

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await box.put(_profileKey, profile.toJson());
  }

  @override
  Future<ProfileModel?> getProfile() async {
    final data = box.get(_profileKey);

    if (data == null) {
      return null;
    }

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<void> clearProfile() async {
    await box.delete(_profileKey);
  }
}