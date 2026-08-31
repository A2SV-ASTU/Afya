class ApiEndpoints {
  ApiEndpoints._();

static const String baseUrl = 'https://api.afyamind.com/api/v1';
  // Auth
  static const String signup = '/auth/signup';
  static const String register = '/auth/signup';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Users & Profile
  static const String userMe = '/users/me';
  static const String userPassword = '/users/me/password';

  // Prescriptions
  static String encounterPrescriptions(String encounterId) =>
      '/encounters/$encounterId/prescriptions';

  static String completePrescription(String id) =>
      '/prescriptions/$id/complete';

  // Vitals Sync
  
  static const String vitalsSync =
      '/patients/me/vitals/sync';

  static const String vitalsDoctorSync =
      '/patients/me/vitals/doctor-sync';

  static const String vitalsDoctorSyncAck =
      '/patients/me/vitals/doctor-sync/ack';

  static const String vitalsHistory =
      '/patients/me/vitals';

  static String patientVitals(String patientId) =>
      '/patients/$patientId/vitals';

  // Access Requests
  static String approveAccessRequest(String id) =>
      '/access-requests/$id/approve';

  static String denyAccessRequest(String id) =>
      '/access-requests/$id/deny';

  // Clinical Encounters & Appointments
  static String patientEncounters(String patientId) =>
      '/patients/$patientId/encounters';

  static String encounterDetail(String id) =>
      '/encounters/$id';

  static String condensedMedicalHistory(String encounterId) =>
      '/encounters/$encounterId/medical-history';

  static String clinicalEvaluation(String encounterId) =>
      '/encounters/$encounterId/clinical-evaluation';

  static String patientAppointments(String patientId) =>
      '/patients/$patientId/appointments';
}
