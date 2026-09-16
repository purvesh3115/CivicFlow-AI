import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/ai_guided_flow_model.dart';
import 'package:citizen_connect/navigation/route_generator.dart';
import 'package:citizen_connect/providers/ai_assistant_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/services_provider.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_assistant_home_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_conversation_history_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_document_guidance_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_guided_complaint_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/civic_safety_alerts_screen.dart';

Widget createTestApp({
  required Widget home,
  AuthProvider? authProvider,
  AiAssistantProvider? aiProvider,
  ComplaintProvider? complaintProvider,
  ServicesProvider? servicesProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => authProvider ?? AuthProvider()),
      ChangeNotifierProvider(create: (_) => aiProvider ?? AiAssistantProvider()),
      ChangeNotifierProvider(create: (_) => complaintProvider ?? ComplaintProvider()),
      ChangeNotifierProvider(create: (_) => servicesProvider ?? ServicesProvider()),
    ],
    child: MaterialApp(
      home: home,
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 9 AI Assistant Provider Unit Tests', () {
    test('Initial guided flow state has step 1 and options', () {
      final provider = AiAssistantProvider();
      expect(provider.guidedStep, GuidedStep.issue);
      expect(provider.guidedIssueOptions.isNotEmpty, true);
      expect(provider.selectedGuidedIssue, null);
      expect(provider.guidedLocation.contains('Anand'), true);
    });

    test('Guided issue selection and custom description updates state', () {
      final provider = AiAssistantProvider();
      final pothole = provider.guidedIssueOptions.first;
      provider.selectGuidedIssue(pothole);

      expect(provider.selectedGuidedIssue?.id, pothole.id);
      expect(provider.guidedStep, GuidedStep.photo);
      expect(provider.guidedDescription, pothole.defaultDescription);
    });

    test('Guided photo attachment, location, and reset flow', () async {
      final provider = AiAssistantProvider();
      await provider.attachGuidedPhoto('https://test.images/pothole.jpg');

      expect(provider.guidedPhotoUrl, 'https://test.images/pothole.jpg');
      expect(provider.guidedStep, GuidedStep.location);

      provider.setGuidedLocation('Station Road Crossroad, Anand');
      expect(provider.guidedLocation, 'Station Road Crossroad, Anand');

      provider.resetGuidedFlow();
      expect(provider.selectedGuidedIssue, null);
      expect(provider.guidedStep, GuidedStep.issue);
      expect(provider.guidedPhotoUrl, null);
    });

    test('Session history retrieval & adding items', () {
      final provider = AiAssistantProvider();
      expect(provider.sessionHistory.isNotEmpty, true);

      final initialCount = provider.sessionHistory.length;
      provider.addSessionHistory(
        AiSessionHistoryItem(
          id: 'test-sess',
          title: 'Storm Drain Blockage Triage',
          snippet: 'Reported storm drain blockage with high urgency.',
          timestamp: DateTime.now(),
          category: 'Grievances',
          status: 'Complaint Filed',
          icon: Icons.water_damage_rounded,
          accentColor: const Color(0xFF004AC6),
        ),
      );

      expect(provider.sessionHistory.length, initialCount + 1);
      expect(provider.sessionHistory.first.id, 'test-sess');
    });

    test('Civic safety alerts list contains municipal alerts', () {
      final provider = AiAssistantProvider();
      expect(provider.safetyAlerts.isNotEmpty, true);

      final firstAlert = provider.safetyAlerts.first;
      expect(firstAlert.title.contains('Monsoon'), true);
      expect(firstAlert.severity, SafetyAlertSeverity.urgent);
      expect(firstAlert.helplineNumber, '1077');
    });
  });

  group('Phase 9 Widget Integration Tests', () {
    testWidgets('AiGuidedComplaintScreen completes 4-step wizard and files complaint',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final complaintProvider = ComplaintProvider();
      final aiProvider = AiAssistantProvider();
      final initialComplaintCount = complaintProvider.complaints.length;

      await tester.pumpWidget(
        createTestApp(
          home: const AiGuidedComplaintScreen(),
          complaintProvider: complaintProvider,
          aiProvider: aiProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Issue Selection
      expect(find.text('CitizenConnect AI'), findsOneWidget);
      expect(find.text('Step 1: Identify Civic Issue'), findsOneWidget);
      expect(find.text('Select Issue Category'), findsOneWidget);
      expect(find.text('Pothole'), findsOneWidget);

      // Select Pothole
      await tester.tap(find.text('Pothole'));
      await tester.pumpAndSettle();

      // Step 2: Evidence & Computer Vision
      expect(find.text('Step 2: Evidence & Computer Vision'), findsOneWidget);
      expect(find.byKey(const Key('ai_capture_photo_btn')), findsOneWidget);

      // Simulate capturing photo
      await tester.tap(find.byKey(const Key('ai_capture_photo_btn')));
      // Wait for photo analysis delay
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Step 3: Pinpoint Location
      expect(find.text('Step 3: Pinpoint Location'), findsOneWidget);
      final confirmLocBtn = find.byKey(const Key('ai_confirm_location_btn'));
      expect(confirmLocBtn, findsOneWidget);
      await tester.ensureVisible(confirmLocBtn);
      await tester.tap(confirmLocBtn);
      await tester.pumpAndSettle();

      // Step 4: AI Summary & Confirmation
      expect(find.text('Step 4: AI Summary & Confirmation'), findsOneWidget);
      final submitBtn = find.byKey(const Key('ai_guided_submit_btn'));
      expect(submitBtn, findsOneWidget);
      await tester.ensureVisible(submitBtn);

      // Submit the complaint
      await tester.tap(submitBtn);
      // Wait for submission simulated processing (avoid pumpAndSettle due to ComplaintSuccessScreen pulse loop)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify complaint was created and submitted
      expect(complaintProvider.complaints.length, initialComplaintCount + 1);
    });

    testWidgets('AiConversationHistoryScreen filters sessions and displays details',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final aiProvider = AiAssistantProvider();

      await tester.pumpWidget(
        createTestApp(
          home: const AiConversationHistoryScreen(),
          aiProvider: aiProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Session History'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Grievances'), findsWidgets);
      expect(find.text('Services'), findsWidgets);
      expect(find.text('Triage'), findsWidgets);
      expect(find.text('Documents'), findsWidgets);

      // Verify list of sessions
      expect(find.byType(ListView), findsOneWidget);

      // Tap Grievances filter chip
      await tester.tap(find.widgetWithText(FilterChip, 'Grievances'));
      await tester.pumpAndSettle();

      // Tap on the first session item to open modal bottom sheet
      final firstSession = find.text('Road Pothole Triage & Severity Check');
      expect(firstSession, findsOneWidget);
      await tester.tap(firstSession);
      await tester.pumpAndSettle();

      expect(find.text('Key AI Insights & Outcomes:'), findsOneWidget);
      expect(find.text('Close Session'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close Session'));
      await tester.pumpAndSettle();
    });

    testWidgets('AiDocumentGuidanceScreen renders checklist, OCR analysis, and queries',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          home: const AiDocumentGuidanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Document Assistant'), findsOneWidget);
      expect(find.text('Universal Healthcare Scheme'), findsOneWidget);
      expect(find.text('Required Verification Documents'), findsOneWidget);
      expect(find.text('AI OCR Document Readiness: 98.4%'), findsOneWidget);
      expect(find.byKey(const Key('doc_upload_vault_btn')), findsOneWidget);
      expect(find.byKey(const Key('doc_view_services_btn')), findsOneWidget);

      // Tap on question chip
      final queryChip = find.text('How to get an Income Certificate?');
      expect(queryChip, findsOneWidget);
      await tester.ensureVisible(queryChip);
      await tester.tap(queryChip);
      await tester.pumpAndSettle();

      expect(find.textContaining('Digital Gujarat portal'), findsOneWidget);
    });

    testWidgets('CivicSafetyAlertsScreen displays alerts, helplines and reacts to tap',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final aiProvider = AiAssistantProvider();

      await tester.pumpWidget(
        createTestApp(
          home: const CivicSafetyAlertsScreen(),
          aiProvider: aiProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Civic Safety & Advisories'), findsOneWidget);
      expect(find.text('24x7 Municipal Emergency Helplines'), findsOneWidget);
      expect(find.text('1077'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('101'), findsOneWidget);
      expect(find.text('1913'), findsOneWidget);

      // Verify active bulletins
      expect(find.text('Active Civic Bulletins & Warnings'), findsOneWidget);
      expect(find.text('Heavy Monsoon Flash Flood Advisory'), findsOneWidget);

      // Test tapping a helpline copies number and shows SnackBar
      await tester.tap(find.text('1077'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Helpline Disaster (1077) copied to dialer.'), findsOneWidget);
    });

    testWidgets('AiAssistantHomeScreen has Phase 9 navigation links and bento tiles',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          home: const AiAssistantHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Phase 9 Hero card
      expect(find.text('AI Guided Complaint'), findsAtLeastNWidgets(1));
      expect(find.text('4 STEPS'), findsOneWidget);

      // Check Civic Safety Advisory Banner
      expect(find.text('Active Municipal Advisory: Monsoon Alert'), findsOneWidget);

      // Check Bento tiles
      expect(find.text('Civic AI Modules & Services'), findsOneWidget);
      expect(find.text('Document Checklist'), findsOneWidget);
      expect(find.text('Safety & Weather'), findsOneWidget);

      // Tap on History Icon in AppBar
      final historyIcon = find.byTooltip('Conversation History');
      expect(historyIcon, findsOneWidget);
      await tester.tap(historyIcon);
      await tester.pumpAndSettle();

      // Verifies it navigated to AiConversationHistoryScreen
      expect(find.text('AI Session History'), findsOneWidget);
    });
  });
}
