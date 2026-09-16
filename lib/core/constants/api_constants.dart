/// Centralized API configuration and endpoints.
/// Easily configurable for staging, production, or local mock servers.
class ApiConstants {
  ApiConstants._();

  // Base URL - can be swapped easily via environment or runtime config
  static const String baseUrl = 'https://api.citizenconnect.gov.in/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // User Profile
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // Complaints
  static const String complaints = '/complaints';
  static const String createComplaint = '/complaints/create';
  static const String complaintDetails = '/complaints'; // + /{id}
  static const String updateComplaintStatus = '/complaints/status';

  // AI Assistant
  static const String aiAnalyze = '/ai/analyze';
  static const String aiTriage = '/ai/triage';

  // Government Services
  static const String services = '/services';
  static const String schemes = '/schemes';

  // Officer & Admin
  static const String officerTasks = '/officer/tasks';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminOfficers = '/admin/officers';
  static const String adminDepartments = '/admin/departments';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
