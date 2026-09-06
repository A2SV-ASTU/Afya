class AppKeys {
  AppKeys._();

  // Secure Storage Keys
  static const String refreshTokenKey = 'afya_refresh_token';

  static const String userSessionKey = 'afya_user_session';

  static const String userIdKey = 'afya_user_id';

  // Hive Box Keys
  static const String vitalsOutboxBox = 'vitals_outbox_box';

  static const String doctorVitalsCacheBox = 'doctor_vitals_cache_box';

  static const String medicationScheduleBox = 'medication_schedule_box';

  static const String adherenceHistoryBox = 'adherence_history_box';

  static const String clinicalHistoryCacheBox =
      'clinical_history_cache_box';

  // Chat
  static const String chatHistoryBox = 'chat_history_box';

  // Profile
  static const String profileBox = 'profile_box';

  static const String profileImagePathKey = 'profile_image_path';

  // Notification Preferences
  static const String appointmentRemindersKey = 'appointment_reminders';

  static const String testResultsKey = 'test_results';

  static const String healthTipsKey = 'health_tips';
}