class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Shell Tabs
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String profile = '/profile';

  // Deep Link Route
  static const String accessDecision = '/access-requests/:id';
  static String accessDecisionPath(String id) => '/access-requests/$id';
}
