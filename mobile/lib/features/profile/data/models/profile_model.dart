import '../../domain/entities/patient_profile_entity.dart';



class ProfileModel extends PatientProfileEntity{


const ProfileModel({
required super.id,
required super.firstName,
required super.lastName,
required super.email,
super.phone,
super.dateOfBirth,
super.gender,
});



factory ProfileModel.fromJson(
Map<String,dynamic> json){


return ProfileModel(

id:json['id'] as String,

firstName:
json['first_name'] as String,

lastName:
json['last_name'] as String,

email:
json['email'] as String,

phone:
json['phone'] as String,

gender:
json['gender'] as String,

dateOfBirth:
json['date_of_birth'] != null
?
DateTime.parse(
json['date_of_birth']
)
:null,

);


}



Map<String,dynamic> toJson(){

return {

"id":id,
"first_name":firstName,
"last_name":lastName,
"email":email,
"phone":phone,
"gender":gender,
"date_of_birth":
dateOfBirth?.toIso8601String(),

};

}

}