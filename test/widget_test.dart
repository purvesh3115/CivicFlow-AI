import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/core/utils/validators.dart';
import 'package:citizen_connect/models/complaint_model.dart';
import 'package:citizen_connect/models/user_model.dart';
import 'package:citizen_connect/providers/ai_assistant_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/notification_provider.dart';
import 'package:citizen_connect/providers/services_provider.dart';
import 'package:citizen_connect/screens/auth/login_screen.dart';
import 'package:citizen_connect/screens/auth/registration_screen.dart';
import 'package:citizen_connect/screens/citizen/citizen_main_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaint_details_form_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaint_success_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaints_list_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/review_complaint_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/select_category_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/upload_evidence_screen.dart';
import 'package:citizen_connect/screens/citizen/notifications_screen.dart';
import 'package:citizen_connect/screens/citizen/profile_screen.dart';
import 'package:citizen_connect/screens/officer/officer_complaint_details_screen.dart';
import 'package:citizen_connect/screens/officer/officer_dashboard_screen.dart';
import 'package:citizen_connect/screens/officer/officer_field_map_screen.dart';
import 'package:citizen_connect/screens/officer/officer_main_screen.dart';
import 'package:citizen_connect/screens/officer/status_update_confirmed_screen.dart';
import 'package:citizen_connect/screens/onboarding/onboarding_screen.dart';
import 'package:citizen_connect/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Validators Unit Tests', () {
    test('Mobile number validation', () {
      expect(Validators.validateMobile(''), 'Please enter your mobile number');
      expect(Validators.validateMobile('123'),
          'Enter a valid 10-digit mobile number');
      expect(Validators.validateMobile('+1 (555) 123-4567'), null);
      expect(Validators.validateMobile('9876543210'), null);
    });

    test('Email validation', () {
      expect(Validators.validateEmail(''), 'Please enter your email address');
      expect(Validators.validateEmail('invalid-email'),
          'Enter a valid email address');
      expect(Validators.validateEmail('citizen@gov.in'), null);
    });

    test('Password validation', () {
      expect(Validators.validatePassword(''), 'Please enter your password');
      expect(Validators.validatePassword('123'),
          'Password must be at least 6 characters');
      expect(Validators.validatePassword('secret123'), null);
    });

    test('Confirm password validation', () {
      expect(Validators.validateConfirmPassword('abc', 'def'),
          'Passwords do not match');
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), null);
    });
  });

  group('UserModel Tests', () {
    test('UserRole fromString parsing', () {
      expect(UserRole.fromString('citizen'), UserRole.citizen);
      expect(UserRole.fromString('officer'), UserRole.officer);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('unknown'), UserRole.citizen);
    });

    test('Serialization and Deserialization', () {
      final user = UserModel(
        id: 'u-1',
        name: 'Purvesh Patel',
        email: 'purvesh@example.com',
        phone: '+91 9876543210',
        city: 'Anand, Gujarat',
        role: UserRole.citizen,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.name, 'Purvesh Patel');
      expect(fromJson.email, 'purvesh@example.com');
      expect(fromJson.city, 'Anand, Gujarat');
      expect(fromJson.role, UserRole.citizen);
    });
  });

  group('AuthService Tests', () {
    late AuthService service;

    setUp(() {
      service = AuthService();
    });

    test('Citizen login mock', () async {
      final res = await service.login(
        mobileOrEmail: 'purvesh@example.com',
        password: 'password123',
        requestedRole: UserRole.citizen,
      );
      expect(res.success, true);
      expect(res.user?.role, UserRole.citizen);
      expect(res.token, isNotEmpty);
    });

    test('Officer login mock', () async {
      final res = await service.login(
        mobileOrEmail: 'officer@gov.in',
        password: 'password123',
        requestedRole: UserRole.officer,
      );
      expect(res.success, true);
      expect(res.user?.role, UserRole.officer);
    });

    test('Admin login mock', () async {
      final res = await service.login(
        mobileOrEmail: 'admin@gov.in',
        password: 'password123',
        requestedRole: UserRole.admin,
      );
      expect(res.success, true);
      expect(res.user?.role, UserRole.admin);
    });
  });

  group('ComplaintModel Tests', () {
    test('Serialization with attachments and copyWith', () {
      final complaint = ComplaintModel(
        id: '#CC10245',
        title: 'Deep Pothole',
        description: 'Road damage on Station Road',
        category: 'Roads',
        department: 'Roads & Public Works',
        priority: 'High',
        status: 'Submitted',
        location: 'Station Road, Anand',
        attachments: ['photo1.jpg', 'photo2.jpg'],
        citizenName: 'Purvesh Patel',
        createdAt: DateTime(2026, 9, 12),
      );

      final json = complaint.toJson();
      final fromJson = ComplaintModel.fromJson(json);

      expect(fromJson.id, '#CC10245');
      expect(fromJson.attachments.length, 2);
      expect(fromJson.attachments.first, 'photo1.jpg');

      final updated = complaint.copyWith(status: 'In Progress');
      expect(updated.status, 'In Progress');
      expect(updated.title, 'Deep Pothole');
    });
  });

  group('ComplaintProvider Tests', () {
    test('Draft management and submission', () {
      final provider = ComplaintProvider();
      expect(provider.complaints.isNotEmpty, true);

      provider.setDraftCategory('Roads');
      expect(provider.draftCategory, 'Roads');

      provider.setDraftDetails(
        title: 'Broken Divider',
        description: 'Near bus stand',
        priority: 'Urgent',
        location: 'Bus Stand, Anand',
      );
      expect(provider.draftTitle, 'Broken Divider');
      expect(provider.draftPriority, 'Urgent');

      provider.addDraftAttachment('test_photo.jpg');
      expect(provider.draftAttachments.contains('test_photo.jpg'), true);

      final submitted = provider.submitComplaint(citizenName: 'Purvesh Patel');
      expect(submitted.title, 'Broken Divider');
      expect(submitted.status, 'Submitted');
      expect(provider.complaints.first.id, submitted.id);
    });

    test('Filter complaints by status', () {
      final provider = ComplaintProvider();
      provider.setStatusFilter('All');
      expect(provider.filteredComplaints.length, provider.complaints.length);

      provider.setStatusFilter('Resolved');
      for (final c in provider.filteredComplaints) {
        expect(c.status, 'Resolved');
      }
    });
  });

  group('UI Screens Smoke Widget Tests', () {
    testWidgets('LoginScreen renders form, buttons, and links',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('CitizenConnect'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue with OTP'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('RegistrationScreen renders form fields and create button',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('City / Region'), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders first step correctly',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('Report Civic Issues Easily'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('CitizenMainScreen renders 5 bottom tabs and HomeScreen',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
            ChangeNotifierProvider(create: (_) => ServicesProvider()),
            ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
          ],
          child: const MaterialApp(
            home: CitizenMainScreen(),
          ),
        ),
      );

      // Verify bottom nav items
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Complaints'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify home dashboard elements
      expect(find.text('How can we help you today?'), findsOneWidget);
      expect(find.text('Report an Issue'), findsOneWidget);
      expect(find.text('Track Complaint'), findsOneWidget);
      expect(find.text('Ask AI Assistant'), findsOneWidget);
      expect(find.text('Complaint Status'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user profile menu items',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('My Documents & Certificates'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders filter chips', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('Unread ('), findsOneWidget);
    });

    // Phase 3 Smoke Widget Tests
    testWidgets('SelectCategoryScreen renders categories and search bar',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: SelectCategoryScreen(),
          ),
        ),
      );

      expect(find.text('New Report'), findsOneWidget);
      expect(find.text('What issue do you want to report?'), findsOneWidget);
      expect(find.text('Roads'), findsOneWidget);
      expect(find.text('Garbage'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Street Lights'), findsOneWidget);
      expect(find.text('Drainage'), findsOneWidget);
    });

    testWidgets(
        'ComplaintDetailsFormScreen renders title, description, and GPS button',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: ComplaintDetailsFormScreen(),
          ),
        ),
      );

      expect(find.text('STEP 2 OF 4'), findsOneWidget);
      expect(find.text('What happened?'), findsOneWidget);
      expect(find.text('Complaint Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Where did it happen?'), findsOneWidget);
      expect(find.text('Use Current Location'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('UploadEvidenceScreen renders media options and continue button',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: UploadEvidenceScreen(),
          ),
        ),
      );

      expect(find.text('STEP 3 OF 4'), findsOneWidget);
      expect(find.text('Upload Evidence'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose Gallery'), findsOneWidget);
      expect(find.text('REQUIRED'), findsOneWidget);
      expect(find.text('Continue to Review'), findsOneWidget);
    });

    testWidgets('ReviewComplaintScreen renders bento review cards and submit button',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: ReviewComplaintScreen(),
          ),
        ),
      );

      expect(find.text('STEP 4 OF 4'), findsOneWidget);
      expect(find.text('Review Your Complaint'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Submit Complaint'), findsOneWidget);
      expect(find.text('Save as Draft'), findsOneWidget);
    });

    testWidgets('ComplaintSuccessScreen renders celebration card and actions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ComplaintSuccessScreen(),
        ),
      );

      expect(find.textContaining('Complaint Submitted'), findsOneWidget);
      expect(find.text('COMPLAINT ID'), findsOneWidget);
      expect(find.text('#CC10245'), findsOneWidget);
      expect(find.text('Track Complaint'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('ComplaintsListScreen renders filters and tracker title',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: ComplaintsListScreen(),
          ),
        ),
      );

      expect(find.text('Complaints Tracker'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Submitted'), findsWidgets);
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);
      expect(find.text('Report Issue'), findsOneWidget);
    });

    testWidgets('OfficerDashboardScreen renders summary counters and priority tasks',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: OfficerDashboardScreen(),
          ),
        ),
      );

      expect(find.text('Good Morning,'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text("Today's Tasks"), findsOneWidget);
      expect(find.text('Site Inspection'), findsOneWidget);
    });

    testWidgets('OfficerComplaintDetailsScreen renders AI analysis result',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: OfficerComplaintDetailsScreen(complaintId: '#CMP-8492'),
          ),
        ),
      );

      expect(find.text('Complaint Details'), findsOneWidget);
      expect(find.text('HIGH PRIORITY'), findsOneWidget);
      expect(find.text('AI Analysis Result'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('UPDATE STATUS'), findsOneWidget);
    });

    testWidgets('StatusUpdateConfirmedScreen renders confirmation badge and actions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatusUpdateConfirmedScreen(
            complaintId: '#CMP-8492',
            status: 'In Progress',
          ),
        ),
      );

      expect(find.text('Status Updated Successfully'), findsOneWidget);
      expect(find.textContaining('Complaint #CMP-8492 has been updated'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('Return to Dashboard'), findsOneWidget);
      expect(find.text('View Complaint'), findsOneWidget);
    });

    testWidgets('OfficerFieldMapScreen renders field map and preview card',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfficerFieldMapScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Field Map'), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('OfficerMainScreen renders 5 navigation tabs and switches content',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
            home: OfficerMainScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Complaints'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap Complaints tab
      await tester.tap(find.text('Complaints'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Assigned Complaints'), findsOneWidget);

      // Tap Map tab
      await tester.tap(find.text('Map'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Field Map'), findsOneWidget);

      // Tap Alerts tab
      await tester.tap(find.text('Alerts'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Officer Alerts & SLA'), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Officer Profile'), findsOneWidget);
      expect(find.text('Senior Field Inspector'), findsOneWidget);
    });
  });
}

