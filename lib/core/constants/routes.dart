class Routes {
  static const String home = '/';
  static const String homeAlias = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String connections = '/connections';
  static const String contactDetailBase = '/connections/contact';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String onboardingProfile = '/onboarding/profile';
  static const String contactNew = '/contacts/new';
  static String contactEdit(String contactId) => '/contacts/$contactId/edit';
  static const String scanner = '/scanner';
  static const String settings = '/settings';
}
