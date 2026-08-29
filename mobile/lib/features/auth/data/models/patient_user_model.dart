import '../../domain/entities/patient_user_entity.dart';

class PatientUserModel extends PatientUserEntity {
  const PatientUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.email,
    super.dateOfBirth = '',
    super.sex = '',
    super.bloodType,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.hasPin = false,
  });

  factory PatientUserModel.fromJson(Map<String, dynamic> json) {
    final payload = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final data = payload.containsKey('user') && payload['user'] is Map<String, dynamic>
        ? payload['user'] as Map<String, dynamic>
        : payload;

    return PatientUserModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      firstName: (data['first_name'] ?? data['firstName'] ?? '').toString(),
      lastName: (data['last_name'] ?? data['lastName'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      dateOfBirth: (data['date_of_birth'] ?? data['dateOfBirth'] ?? '').toString(),
      sex: (data['sex'] ?? '').toString(),
      bloodType: data['blood_type']?.toString() ?? data['bloodType']?.toString(),
      emergencyContactName:
          data['emergency_contact_name']?.toString() ?? data['emergencyContactName']?.toString(),
      emergencyContactPhone:
          data['emergency_contact_phone']?.toString() ?? data['emergencyContactPhone']?.toString(),
      hasPin: data['has_pin'] ?? data['hasPin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'date_of_birth': dateOfBirth,
      'sex': sex,
      'blood_type': bloodType,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'has_pin': hasPin,
    };
  }

  Map<String, dynamic> toRegisterJson(String password, {String role = 'patient'}) {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone': phone,
    };
  }
}
