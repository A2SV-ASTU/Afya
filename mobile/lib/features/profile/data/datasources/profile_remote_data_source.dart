import '../models/profile_model.dart';


abstract class ProfileRemoteDataSource {


Future<ProfileModel> getProfile();



Future<ProfileModel> updateDemographics({

required String firstName,
required String lastName,
String? phone,
String? gender,
DateTime? dateOfBirth,

});



Future<void> changePassword({

required String oldPassword,
required String newPassword,

});



Future<void> deactivateAccount();


Future<void> logout();


}