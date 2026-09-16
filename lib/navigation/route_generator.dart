import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../models/service_model.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_auto_assign_screen.dart';
import '../screens/admin/admin_complaints_screen.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/admin/departments_oversight_screen.dart';
import '../screens/admin/manage_officers_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/citizen/ai/ai_assistant_home_screen.dart';
import '../screens/citizen/ai/ai_chat_triage_screen.dart';
import '../screens/citizen/ai/ai_conversation_history_screen.dart';
import '../screens/citizen/ai/ai_document_guidance_screen.dart';
import '../screens/citizen/ai/ai_guided_complaint_screen.dart';
import '../screens/citizen/ai/ai_image_analysis_screen.dart';
import '../screens/citizen/ai/ai_voice_assistant_screen.dart';
import '../screens/citizen/ai/civic_safety_alerts_screen.dart';
import '../screens/citizen/citizen_main_screen.dart';
import '../screens/citizen/complaints/complaint_details_form_screen.dart';
import '../screens/citizen/complaints/complaint_success_screen.dart';
import '../screens/citizen/complaints/complaints_list_screen.dart';
import '../screens/citizen/complaints/review_complaint_screen.dart';
import '../screens/citizen/complaints/select_category_screen.dart';
import '../screens/citizen/complaints/upload_evidence_screen.dart';
import '../screens/citizen/notification_settings_screen.dart';
import '../screens/citizen/notifications_screen.dart';
import '../screens/citizen/personal_information_screen.dart';
import '../screens/citizen/services/eligibility_check_screen.dart';
import '../screens/citizen/services/eligibility_result_screen.dart';
import '../screens/citizen/services/government_services_screen.dart';
import '../providers/services_provider.dart';
import '../screens/citizen/services/my_documents_screen.dart';
import '../screens/citizen/services/service_details_screen.dart';
import '../screens/citizen/services/service_eligibility_screen.dart';
import '../screens/officer/officer_complaint_details_screen.dart';
import '../screens/officer/officer_main_screen.dart';
import '../screens/officer/status_update_confirmed_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static GovernmentServiceModel _resolveService(Object? args) {
    if (args is GovernmentServiceModel) {
      return args;
    }
    if (args is String && args.trim().isNotEmpty) {
      final found = ServicesProvider.findServiceByIdOrTitle(args);
      if (found != null) return found;
    }
    if (args is Map) {
      final raw = args['service'] ?? args['serviceModel'];
      if (raw is GovernmentServiceModel) return raw;
      final idOrTitle = args['id'] ?? args['serviceId'] ?? args['title'];
      if (idOrTitle is String && idOrTitle.trim().isNotEmpty) {
        final found = ServicesProvider.findServiceByIdOrTitle(idOrTitle);
        if (found != null) return found;
      }
    }
    return ServicesProvider.fallbackService;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _buildRoute(const RegistrationScreen(), settings);

      case AppRoutes.otpVerification:
        String phone = '+1 (555) 019-2834';
        String? userName;
        if (args is Map) {
          phone = args['phone']?.toString() ?? phone;
          userName = args['userName']?.toString();
        }
        return _buildRoute(
          OtpVerificationScreen(phone: phone, userName: userName),
          settings,
        );

      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // Citizen Experience
      case AppRoutes.home:
        int initialTab = 0;
        if (args is int) {
          initialTab = args;
        }
        return _buildRoute(
          CitizenMainScreen(initialTab: initialTab),
          settings,
        );

      case AppRoutes.notifications:
        return _buildRoute(const NotificationsScreen(), settings);

      case AppRoutes.notificationSettings:
        return _buildRoute(const NotificationSettingsScreen(), settings);

      case AppRoutes.personalInfo:
        return _buildRoute(const PersonalInformationScreen(), settings);

      // Complaint Submission Flow (Phase 3)
      case AppRoutes.selectCategory:
        return _buildRoute(const SelectCategoryScreen(), settings);

      case AppRoutes.complaintDetails:
        return _buildRoute(const ComplaintDetailsFormScreen(), settings);

      case AppRoutes.uploadEvidence:
        return _buildRoute(const UploadEvidenceScreen(), settings);

      case AppRoutes.reviewComplaint:
        return _buildRoute(const ReviewComplaintScreen(), settings);

      case AppRoutes.complaintSuccess:
        ComplaintModel? submitted;
        if (args is ComplaintModel) {
          submitted = args;
        }
        return _buildRoute(
          ComplaintSuccessScreen(complaint: submitted),
          settings,
        );

      case AppRoutes.complaintsList:
        return _buildRoute(const ComplaintsListScreen(), settings);

      // Officer Workflow (Phase 4)
      case AppRoutes.officerDashboard:
        int initialTab = 0;
        if (args is int) {
          initialTab = args;
        }
        return _buildRoute(
          OfficerMainScreen(initialTab: initialTab),
          settings,
        );

      case AppRoutes.officerComplaintDetails:
        final complaintId = args?.toString() ?? '#CMP-8492';
        return _buildRoute(
          OfficerComplaintDetailsScreen(complaintId: complaintId),
          settings,
        );

      case AppRoutes.statusUpdateConfirmed:
        String compId = '#CMP-8492';
        String status = 'In Progress';
        if (args is Map) {
          compId = args['complaintId']?.toString() ?? compId;
          status = args['status']?.toString() ?? status;
        }
        return _buildRoute(
          StatusUpdateConfirmedScreen(
            complaintId: compId,
            status: status,
          ),
          settings,
        );

      case AppRoutes.adminDashboard:
        int initialTab = 0;
        if (args is int) {
          initialTab = args;
        }
        return _buildRoute(
          AdminMainScreen(initialTab: initialTab),
          settings,
        );

      // Government Services & Schemes (Phase 5)
      case AppRoutes.governmentServices:
        return _buildRoute(const GovernmentServicesScreen(), settings);

      case AppRoutes.serviceDetails:
        final service = _resolveService(args);
        return _buildRoute(ServiceDetailsScreen(service: service), settings);

      case AppRoutes.serviceEligibility:
        final service = _resolveService(args);
        return _buildRoute(ServiceEligibilityScreen(service: service), settings);

      case AppRoutes.eligibilityCheck:
        final service = _resolveService(args);
        return _buildRoute(
          EligibilityCheckScreen(service: service),
          settings,
        );

      case AppRoutes.eligibilityResult:
        EligibilityResult? res;
        GovernmentServiceModel? srv;
        if (args is Map) {
          res = args['result'] as EligibilityResult?;
          if (args['service'] != null) {
            srv = _resolveService(args['service']);
          }
        } else if (args is EligibilityResult) {
          res = args;
        }
        srv ??= ServicesProvider.fallbackService;
        final fallbackResult = EligibilityResult(
          isEligible: true,
          matchPercentage: 92,
          serviceTitle: srv.title,
          satisfiedCriteria: const [
            'Verified municipal resident',
            'Valid Government Identification',
            'Eligible income bracket',
          ],
          pendingRequirements: const [
            'Proof of Current Residence',
          ],
        );
        return _buildRoute(
          EligibilityResultScreen(
            result: res ?? fallbackResult,
            service: srv,
          ),
          settings,
        );

      case AppRoutes.myDocuments:
        return _buildRoute(const MyDocumentsScreen(), settings);

      // AI Multimodal Civic Assistant Suite (Phase 6)
      case AppRoutes.aiAssistantHome:
        return _buildRoute(const AiAssistantHomeScreen(), settings);

      case AppRoutes.aiChat:
        return _buildRoute(const AiChatTriageScreen(), settings);

      case AppRoutes.aiImageAnalysis:
        return _buildRoute(const AiImageAnalysisScreen(), settings);

      case AppRoutes.aiVoiceAssistant:
        return _buildRoute(const AiVoiceAssistantScreen(), settings);

      // AI Conversational Filing, Document Assistant & Civic Safety Suite (Phase 9)
      case AppRoutes.aiGuidedComplaint:
        return _buildRoute(const AiGuidedComplaintScreen(), settings);

      case AppRoutes.aiConversationHistory:
        return _buildRoute(const AiConversationHistoryScreen(), settings);

      case AppRoutes.aiDocumentGuidance:
        return _buildRoute(const AiDocumentGuidanceScreen(), settings);

      case AppRoutes.civicSafetyAlerts:
        return _buildRoute(const CivicSafetyAlertsScreen(), settings);

      // CivicAdmin Operations & Executive Governance Suite (Phase 7)
      case AppRoutes.adminAutoAssign:
        String? targetCompId;
        if (args is String) {
          targetCompId = args;
        }
        return _buildRoute(
          AdminAutoAssignScreen(complaintId: targetCompId),
          settings,
        );

      case AppRoutes.adminOfficers:
        return _buildRoute(const ManageOfficersScreen(), settings);

      case AppRoutes.adminAnalytics:
        return _buildRoute(const AdminAnalyticsScreen(), settings);

      case AppRoutes.adminDepartments:
        return _buildRoute(const DepartmentsOversightScreen(), settings);

      case AppRoutes.adminComplaints:
        return _buildRoute(const AdminComplaintsScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
