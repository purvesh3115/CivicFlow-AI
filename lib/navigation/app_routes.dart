class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';

  // Citizen Main & Sub-screens
  static const String home = '/home'; // Citizen Main Screen (with Bottom Nav)
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';
  static const String personalInfo = '/personal-info';

  // Complaint Submission Flow (Phase 3)
  static const String selectCategory = '/select-category';
  static const String complaintDetails = '/complaint-details';
  static const String uploadEvidence = '/upload-evidence';
  static const String reviewComplaint = '/review-complaint';
  static const String complaintSuccess = '/complaint-success';
  static const String complaintsList = '/complaints-list';

  // Officer & Admin roles
  static const String officerDashboard = '/officer-dashboard';
  static const String officerComplaintDetails = '/officer/complaint-details';
  static const String statusUpdateConfirmed = '/officer/status-confirmed';
  static const String adminDashboard = '/admin-dashboard';

  // Government Services & Schemes (Phase 5)
  static const String governmentServices = '/services';
  static const String serviceDetails = '/services/details';
  static const String serviceEligibility = '/services/eligibility';
  static const String eligibilityCheck = '/services/eligibility-check';
  static const String eligibilityResult = '/services/eligibility-result';
  static const String myDocuments = '/my-documents';

  // AI Multimodal Civic Assistant Suite (Phase 6)
  static const String aiAssistantHome = '/ai/home';
  static const String aiChat = '/ai/chat';
  static const String aiImageAnalysis = '/ai/image-analysis';
  static const String aiVoiceAssistant = '/ai/voice-assistant';

  // CivicAdmin Operations & Executive Governance Suite (Phase 7)
  static const String adminAutoAssign = '/admin/auto-assign';
  static const String adminOfficers = '/admin/officers';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminDepartments = '/admin/departments';
  static const String adminComplaints = '/admin/complaints';

  // AI Conversational Filing, Document Assistant & Civic Safety (Phase 9)
  static const String aiGuidedComplaint = '/ai/guided-complaint';
  static const String aiConversationHistory = '/ai/history';
  static const String aiDocumentGuidance = '/ai/document-guidance';
  static const String civicSafetyAlerts = '/safety-alerts';
}
