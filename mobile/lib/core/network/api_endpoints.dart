abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.afyamind.app/v1';

  // Auth & Accounts
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userMe = '/users/me';
  static const String userDisclaimer = '/users/me/disclaimer';

  // Moods
  static const String moods = '/moods';
  static const String moodEntries = '/mood-entries';
  static const String moodHistory = '/mood-entries/history';

  // Exercises
  static const String exercises = '/exercises';
  static const String exerciseCompletionsHistory =
      '/exercise-completions/history';

  // Chat
  static const String chats = '/chats';

  // Crisis
  static const String crisisResources = '/crisis-resources';
  static const String crisisEvents = '/crisis-events';
}
