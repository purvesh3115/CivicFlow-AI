class AppConstants {
  AppConstants._();

  static const String appName = 'CitizenConnect';
  static const String tagline = 'Your Voice. Your City. Your Connection.';

  // Storage Keys for SharedPreferences
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';

  // Demo / Mock roles
  static const String roleCitizen = 'citizen';
  static const String roleOfficer = 'officer';
  static const String roleAdmin = 'admin';

  // Default timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
