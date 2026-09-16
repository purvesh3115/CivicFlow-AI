import 'package:citizen_connect/navigation/route_generator.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/notification_provider.dart';
import 'package:citizen_connect/providers/services_provider.dart';
import 'package:citizen_connect/models/user_model.dart';
import 'package:citizen_connect/screens/auth/otp_verification_screen.dart';
import 'package:citizen_connect/screens/auth/registration_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaint_details_form_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/upload_evidence_screen.dart';
import 'package:citizen_connect/screens/citizen/profile_screen.dart';
import 'package:citizen_connect/screens/citizen/services/eligibility_check_screen.dart';
import 'package:citizen_connect/screens/officer/officer_dashboard_screen.dart';
import 'package:citizen_connect/screens/officer/widgets/update_status_modal.dart';
import 'package:citizen_connect/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Phase 8 Fixes: Registration Location Type & Mandatory Validation', () {
    testWidgets('RegistrationScreen renders Location Type dropdown and required indicators',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Location Type label and dropdown presence
      expect(find.text('Location Type'), findsOneWidget);
      expect(find.text('City / Region'), findsOneWidget);
      expect(find.text('Residential Area'), findsOneWidget);

      // Verify asterisk indicators are rendered
      expect(find.text(' *'), findsWidgets);

      // Scroll to button and tap to trigger mandatory validation
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Expect required field validation errors
      expect(find.text('Full Name cannot be empty'), findsOneWidget);
    });
  });

  group('Phase 8 Fixes: Complaint Mandatory Evidence & Quick Capture', () {
    testWidgets('ComplaintDetailsFormScreen enforces mandatory fields with red asterisks',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
          child: const MaterialApp(
            home: ComplaintDetailsFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify mandatory labels
      expect(find.text('Complaint Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Location Address'), findsOneWidget);
      expect(find.text('Priority Level'), findsOneWidget);
      expect(find.text(' *'), findsWidgets);
    });

    testWidgets('UploadEvidenceScreen prevents continue without evidence and supports 1-tap quick actions',
        (tester) async {
      final provider = ComplaintProvider();
      provider.resetDraft();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: UploadEvidenceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('REQUIRED'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose Gallery'), findsOneWidget);

      // Ensure Continue to Review button is visible and tap with 0 attachments -> triggers warning SnackBar
      await tester.ensureVisible(find.text('Continue to Review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Review'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please add an image of the issue.'),
        findsOneWidget,
      );

      // Simulate photo selection
      provider.addDraftAttachment('assets/images/sample.jpg');
      await tester.pumpAndSettle();

      // Verify attachment is now added
      expect(provider.draftAttachments.length, 1);
      expect(find.text('Attached Evidence (1)'), findsOneWidget);
    });
  });

  group('Phase 8 Fixes: Eligibility Checker Navigation & Step Tabs', () {
    testWidgets('EligibilityCheckScreen renders interactive tabs and changes steps',
        (tester) async {
      final servicesProvider = ServicesProvider();
      final targetService = servicesProvider.allServices.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: servicesProvider,
          child: MaterialApp(
            home: EligibilityCheckScreen(service: targetService),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify step tabs
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);

      // Tap Household tab directly
      await tester.tap(find.text('Household'));
      await tester.pumpAndSettle();

      expect(find.text('Household & Employment'), findsOneWidget);
      expect(find.text('Step 2 of 3: Pre-screening questions'), findsOneWidget);

      // Tap Documents tab directly
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Document Readiness'), findsOneWidget);
      expect(find.text('Step 3 of 3: Pre-screening questions'), findsOneWidget);
      expect(find.text('Evaluate Eligibility'), findsOneWidget);
    });
  });

  group('Phase 8 Fixes: Officer Dashboard Live Updates & Status Sync', () {
    testWidgets('OfficerDashboardScreen dynamically updates Priority Complaints on resolution',
        (tester) async {
      final complaintProvider = ComplaintProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: complaintProvider,
          child: const MaterialApp(
            home: OfficerDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially #CMP-8492 is among active priority complaints
      expect(find.text('#CMP-8492'), findsOneWidget);

      // Officer resolves #CMP-8492
      complaintProvider.updateComplaintStatus(
        id: '#CMP-8492',
        newStatus: 'Resolved',
        remarks: 'Road crew patched the pothole completely.',
      );
      await tester.pumpAndSettle();

      // #CMP-8492 should be removed from active Priority Complaints!
      expect(find.text('#CMP-8492'), findsNothing);

      // Now #CMP-8493 becomes the visible priority complaint
      expect(find.text('#CMP-8493'), findsOneWidget);

      // Officer resolves remaining priority complaints
      complaintProvider.updateComplaintStatus(
        id: '#CMP-8493',
        newStatus: 'Resolved',
        remarks: 'Traffic controller circuit board replaced.',
      );
      complaintProvider.updateComplaintStatus(
        id: '#C-4891',
        newStatus: 'Resolved',
        remarks: 'Pothole asphalt laid and cured.',
      );
      await tester.pumpAndSettle();

      // Now all priority complaints are handled!
      expect(find.text('#CMP-8493'), findsNothing);
      expect(find.text('No complaints assigned yet.'), findsOneWidget);
    });

    testWidgets('NotificationProvider receives live status update notification',
        (tester) async {
      final complaintProvider = ComplaintProvider();
      final notificationProvider = NotificationProvider();

      // Use a larger surface size for modal testing
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: complaintProvider),
            ChangeNotifierProvider.value(value: notificationProvider),
          ],
          child: MaterialApp(
            onGenerateRoute: RouteGenerator.generateRoute,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: UpdateStatusModal(
                  complaintId: '#CMP-8492',
                  currentStatus: 'In Progress',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialNotifsCount = notificationProvider.notifications.length;

      // Select RESOLUTION SUBMITTED (Resolved)
      await tester.tap(find.text('RESOLUTION SUBMITTED'));
      await tester.pumpAndSettle();

      // Enter remarks
      await tester.enterText(
        find.byType(TextField).first,
        'Grievance completely rectified by municipal crew.',
      );
      await tester.pumpAndSettle();

      // Ensure button visible and tap
      await tester.ensureVisible(find.byKey(const Key('officer_modal_update_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('officer_modal_update_button')));
      await tester.pumpAndSettle();

      // Verify notification was added
      expect(
        notificationProvider.notifications.length,
        initialNotifsCount + 1,
      );
      expect(
        notificationProvider.notifications.first.title,
        'Status Updated: #CMP-8492',
      );
      expect(
        notificationProvider.notifications.first.message.contains('Resolved'),
        isTrue,
      );
    });

    testWidgets('OtpVerificationScreen routes to officer dashboard when role is officer',
        (tester) async {
      final authProvider = AuthProvider();
      authProvider.switchPersona(UserRole.officer);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            onGenerateRoute: RouteGenerator.generateRoute,
            home: OtpVerificationScreen(
              phone: '+91 98765 00001',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verification'), findsOneWidget);
    });

    testWidgets('ProfileScreen and OfficerProfileScreen render Demo Persona Switcher',
        (tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            onGenerateRoute: RouteGenerator.generateRoute,
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Demo Persona Switcher'), findsOneWidget);
      expect(find.byKey(const Key('persona_switch_officer')), findsOneWidget);
      expect(find.byKey(const Key('persona_switch_admin')), findsOneWidget);
    });
  });
}
