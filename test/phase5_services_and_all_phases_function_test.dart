import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/service_model.dart';
import 'package:citizen_connect/models/user_model.dart';
import 'package:citizen_connect/providers/ai_assistant_provider.dart';
import 'package:citizen_connect/providers/admin_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/notification_provider.dart';
import 'package:citizen_connect/providers/services_provider.dart';
import 'package:citizen_connect/screens/citizen/notification_settings_screen.dart';
import 'package:citizen_connect/screens/citizen/personal_information_screen.dart';
import 'package:citizen_connect/screens/citizen/services/eligibility_check_screen.dart';
import 'package:citizen_connect/screens/citizen/services/eligibility_result_screen.dart';
import 'package:citizen_connect/screens/citizen/services/government_services_screen.dart';
import 'package:citizen_connect/screens/citizen/services/my_documents_screen.dart';
import 'package:citizen_connect/screens/citizen/services/service_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationProvider Unit Tests (Phase 2)', () {
    test('Initializes with default settings and unread count', () async {
      final provider = NotificationProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.settings['push'], true);
      expect(provider.settings['email'], true);
      expect(provider.settings['sms'], false);
      expect(provider.settings['schemes'], true);
      expect(provider.unreadCount >= 0, true);
    });

    test('updateSetting toggles values reactively', () async {
      final provider = NotificationProvider();
      await provider.updateSetting('sms', true);
      expect(provider.settings['sms'], true);

      await provider.updateSetting('push', false);
      expect(provider.settings['push'], false);
    });

    test('markAllAsRead clears unread count', () async {
      final provider = NotificationProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      await provider.markAllAsRead();
      expect(provider.unreadCount, 0);
      for (final n in provider.notifications) {
        expect(n.isRead, true);
      }
    });
  });

  group('ServicesProvider Unit Tests (Phase 5)', () {
    late ServicesProvider provider;

    setUp(() {
      provider = ServicesProvider();
    });

    test('Initializes with services and digital vault documents', () {
      expect(provider.allServices.isNotEmpty, true);
      expect(provider.filteredServices.length, provider.allServices.length);
      expect(provider.filteredDocuments.isNotEmpty, true);
      expect(provider.bookmarkedServices.isNotEmpty, true);
    });

    test('Filter services by category', () {
      provider.setSelectedCategory('Health');
      expect(provider.selectedCategory, 'Health');
      for (final s in provider.filteredServices) {
        expect(s.category, 'Health');
      }

      provider.setSelectedCategory('All');
      expect(provider.filteredServices.length, provider.allServices.length);
    });

    test('Filter services by search query', () {
      provider.setSearchQuery('solar');
      expect(provider.filteredServices.isNotEmpty, true);
      expect(provider.filteredServices.first.title.toLowerCase().contains('solar'), true);

      provider.setSearchQuery('');
      expect(provider.filteredServices.length, provider.allServices.length);
    });

    test('toggleBookmark toggles state on target service', () {
      final target = provider.allServices.first;
      final initialBookmark = target.isBookmarked;

      provider.toggleBookmark(target.id);
      final updated = provider.allServices.firstWhere((s) => s.id == target.id);
      expect(updated.isBookmarked, !initialBookmark);

      provider.toggleBookmark(target.id);
      final restored = provider.allServices.firstWhere((s) => s.id == target.id);
      expect(restored.isBookmarked, initialBookmark);
    });

    test('Filter documents by document type', () {
      provider.setDocFilter('Certificates');
      for (final doc in provider.filteredDocuments) {
        expect(doc.type, 'Certificate');
      }

      provider.setDocFilter('All');
      expect(provider.filteredDocuments.length >= 4, true);
    });

    test('requestNewDocument adds document to vault', () {
      final initialCount = provider.filteredDocuments.length;
      provider.requestNewDocument(
        title: 'New Water Card',
        type: 'Certificate',
        issuingAuthority: 'Municipal Water Board',
      );
      expect(provider.filteredDocuments.length, initialCount + 1);
      expect(provider.filteredDocuments.first.title, 'New Water Card');
      expect(provider.filteredDocuments.first.status, 'Active');
    });

    test('Interactive Eligibility Quiz scoring and evaluation', () {
      final service = provider.allServices.first;
      provider.startEligibilityQuiz(service);

      expect(provider.currentQuizService?.id, service.id);
      expect(provider.quizState.isResident, true);

      // Customize quiz state for high eligibility
      provider.updateQuizResidency(true);
      provider.updateQuizAge('18_59');
      provider.updateQuizIncome('tier1');
      provider.updateQuizHouseholdSize(4);
      provider.updateQuizEmployment('Employed');
      provider.updateQuizExistingAid(false);
      provider.toggleQuizDocument(service.requiredDocuments.first);

      final result = provider.evaluateQuiz();
      expect(result.matchPercentage >= 50, true);
      expect(provider.lastResult, isNotNull);

      provider.resetQuiz();
      expect(provider.lastResult, isNull);
    });
  });

  group('UI Screens Widget Tests (Phase 2 & Phase 5)', () {
    testWidgets('NotificationSettingsScreen renders toggles and headings',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('SMS Alerts'), findsOneWidget);
      expect(find.text('Government Scheme Announcements'), findsOneWidget);
    });

    testWidgets('PersonalInformationScreen renders profile fields and save button',
        (tester) async {
      final authProvider = AuthProvider();
      authProvider.switchPersona(UserRole.citizen);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            home: PersonalInformationScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('City / Region'), findsOneWidget);
      expect(find.byTooltip('Edit Profile'), findsOneWidget);
    });

    testWidgets('GovernmentServicesScreen renders search bar, categories, and service cards',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ServicesProvider(),
          child: const MaterialApp(
            home: GovernmentServicesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Government Services'), findsOneWidget);
      expect(find.text('Search for Health, Housing, Subsidies...'), findsOneWidget);
      expect(find.text('All Schemes'), findsWidgets);
      expect(find.text('Universal Healthcare Access'), findsOneWidget);
      expect(find.text('Clean Energy Solar Subsidy'), findsOneWidget);
      expect(find.text('Commercial Trade Permit Express'), findsOneWidget);
    });

    testWidgets('ServiceDetailsScreen renders benefits and check eligibility button',
        (tester) async {
      final serviceProvider = ServicesProvider();
      final targetService = serviceProvider.allServices.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: serviceProvider,
          child: MaterialApp(
            home: ServiceDetailsScreen(service: targetService),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Scheme Details'), findsOneWidget);
      expect(find.text(targetService.title), findsOneWidget);
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('Eligibility Requirements'), findsOneWidget);
      expect(find.text('Required Documents'), findsOneWidget);
      expect(find.text('Check Your Eligibility'), findsOneWidget);
    });

    testWidgets('EligibilityCheckScreen renders steps and quiz options',
        (tester) async {
      final serviceProvider = ServicesProvider();
      final targetService = serviceProvider.allServices.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: serviceProvider,
          child: MaterialApp(
            home: EligibilityCheckScreen(service: targetService),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Eligibility Checker'), findsOneWidget);
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Are you currently a resident of the municipality?'), findsOneWidget);
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('No'), findsWidgets);
      expect(find.text('Next Step'), findsOneWidget);
    });

    testWidgets('EligibilityResultScreen renders score and status banner',
        (tester) async {
      final serviceProvider = ServicesProvider();
      final targetService = serviceProvider.allServices.first;
      const result = EligibilityResult(
        isEligible: true,
        matchPercentage: 92,
        serviceTitle: 'Universal Healthcare Access',
        satisfiedCriteria: ['Verified municipal resident', 'Household income within criteria'],
        pendingRequirements: ['Proof of Address'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EligibilityResultScreen(
            result: result,
            service: targetService,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Assessment Outcome'), findsOneWidget);
      expect(find.text('You are Eligible! 🎉'), findsOneWidget);
      expect(find.text('92% Qualification Score'), findsOneWidget);
      expect(find.text('Qualification Summary'), findsOneWidget);
      expect(find.text('Proceed to Formal Application'), findsOneWidget);
    });

    testWidgets('MyDocumentsScreen renders vault tabs and document cards',
        (tester) async {
      final authProvider = AuthProvider();
      final servicesProvider = ServicesProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: servicesProvider),
          ],
          child: const MaterialApp(
            home: MyDocumentsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Digital Document Vault'), findsOneWidget);
      expect(find.text('National Identity Card'), findsOneWidget);
      expect(find.text('Resident Certificate'), findsOneWidget);
      expect(find.text('Property Tax Receipt 2023'), findsOneWidget);
      expect(find.text('Municipal Water Connection'), findsOneWidget);
    });
  });

  group('Cross-Phase All-Function End-to-End Simulation Tests', () {
    test('Full Civic Lifecycle: Citizen -> AI -> Officer -> Admin dispatch', () async {
      // 1. Citizen reports issue assisted by AI
      final aiProvider = AiAssistantProvider();
      await aiProvider.sendMessage('Huge pothole on Station road near hospital');
      expect(aiProvider.messages.length >= 2, true);
      expect(aiProvider.messages.last.insightCard?.category, 'Roads');

      // 2. Pre-fill into Complaint draft
      final complaintProvider = ComplaintProvider();
      aiProvider.applyPreFilledComplaint(complaintProvider);
      expect(complaintProvider.draftCategory, 'Roads');
      expect(complaintProvider.draftTitle.isNotEmpty, true);

      // 3. Submit complaint
      complaintProvider.addDraftAttachment('https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=600');
      final submitted = complaintProvider.submitComplaint(citizenName: 'Purvesh Patel');
      expect(submitted.status, 'Submitted');
      expect(complaintProvider.activeCount >= 1, true);

      // 4. Admin auto-assign triage
      final adminProvider = AdminProvider();
      final recommendation = adminProvider.getAutoAssignRecommendation(submitted.id);
      expect(recommendation.recommendedOfficer.name.isNotEmpty, true);

      // 5. Admin executes assignment to Officer
      adminProvider.assignComplaint(recommendation.complaintId, recommendation.recommendedOfficer.id);
      final assignedOfficer = adminProvider.officers.firstWhere((o) => o.id == recommendation.recommendedOfficer.id);
      expect(assignedOfficer.activeTasks >= 1, true);

      // 6. Officer updates status to In Progress and Resolved
      complaintProvider.updateComplaintStatus(id: submitted.id, newStatus: 'In Progress');
      expect(complaintProvider.getComplaintById(submitted.id)?.status, 'In Progress');

      complaintProvider.updateComplaintStatus(id: submitted.id, newStatus: 'Resolved');
      expect(complaintProvider.getComplaintById(submitted.id)?.status, 'Resolved');
    });
  });
}
