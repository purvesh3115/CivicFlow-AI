import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/complaint_model.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/widgets/citizen_feedback_modal.dart';
import 'package:citizen_connect/widgets/complaint_card.dart';
import 'package:citizen_connect/widgets/complaint_detail_modal.dart';
import 'package:citizen_connect/screens/officer/officer_complaint_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ComplaintModel Rating & Feedback Serialization Unit Tests', () {
    test('Serializes and deserializes rating, feedback, and ratedAt', () {
      final now = DateTime.now();
      final complaint = ComplaintModel(
        id: '#CMP-TEST-1',
        title: 'Broken Water Pipe',
        description: 'Water leaking near market junction',
        category: 'Water Supply',
        department: 'Water Department',
        priority: 'High',
        status: 'Resolved',
        location: 'Market Road',
        citizenName: 'Aarav Patel',
        citizenRating: 5,
        citizenFeedback: 'Quick and clean resolution by officer',
        ratedAt: now,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      final json = complaint.toJson();
      expect(json['citizen_rating'], 5);
      expect(json['citizen_feedback'], 'Quick and clean resolution by officer');
      expect(json['rated_at'], isNotNull);

      final fromJson = ComplaintModel.fromJson(json);
      expect(fromJson.id, '#CMP-TEST-1');
      expect(fromJson.citizenName, 'Aarav Patel');
      expect(fromJson.citizenRating, 5);
      expect(fromJson.citizenFeedback, 'Quick and clean resolution by officer');
      expect(fromJson.ratedAt?.year, now.year);
    });

    test('Handles null rating and feedback backwards-compatibility', () {
      final complaint = ComplaintModel(
        id: '#CMP-TEST-2',
        title: 'Streetlight Blown',
        description: 'Streetlight flickering at night',
        category: 'Electricity',
        department: 'Electrical Board',
        priority: 'Low',
        status: 'Resolved',
        location: 'Sector 4',
        citizenName: 'Pooja Sharma',
        createdAt: DateTime.now(),
      );

      final json = complaint.toJson();
      expect(json['citizen_rating'], isNull);
      expect(json['citizen_feedback'], isNull);
      expect(json['rated_at'], isNull);

      final fromJson = ComplaintModel.fromJson(json);
      expect(fromJson.citizenRating, isNull);
      expect(fromJson.citizenFeedback, isNull);
      expect(fromJson.ratedAt, isNull);
    });

    test('copyWith properly sets citizenRating and citizenFeedback', () {
      final base = ComplaintModel(
        id: '#CMP-TEST-3',
        title: 'Pothole on Main Rd',
        description: 'Large pothole',
        category: 'Roads',
        department: 'Public Works',
        priority: 'Medium',
        status: 'Resolved',
        location: 'Main Road',
        citizenName: 'Rahul Verma',
        createdAt: DateTime.now(),
      );

      final rated = base.copyWith(
        citizenRating: 4,
        citizenFeedback: 'Pothole filled smoothly',
        ratedAt: DateTime.now(),
      );

      expect(rated.citizenRating, 4);
      expect(rated.citizenFeedback, 'Pothole filled smoothly');
      expect(rated.ratedAt, isNotNull);
      expect(rated.status, 'Resolved');
    });
  });

  group('ComplaintProvider Feedback Submission Unit Tests', () {
    test('submitComplaintFeedback updates local complaint with rating & feedback', () async {
      final provider = ComplaintProvider();
      expect(provider.complaints.isNotEmpty, true);

      final targetId = provider.complaints.first.id;
      final result = await provider.submitComplaintFeedback(
        complaintId: targetId,
        rating: 5,
        feedback: 'Excellent civic repair work!',
      );

      expect(result, true);
      final updated = provider.complaints.firstWhere((c) => c.id == targetId);
      expect(updated.citizenRating, 5);
      expect(updated.citizenFeedback, 'Excellent civic repair work!');
      expect(updated.ratedAt, isNotNull);
    });
  });

  group('CitizenFeedbackModal Widget Tests', () {
    testWidgets('Renders header, 5-star selector, quick tags, and text field',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final complaint = ComplaintModel(
        id: '#CMP-RATE-1',
        title: 'Open Drainage Manhole',
        description: 'Dangerous manhole left open',
        category: 'Drainage',
        department: 'Drainage Division',
        priority: 'High',
        status: 'Resolved',
        location: 'Sector 9',
        citizenName: 'Vikram Mehta',
        assignedOfficerName: 'Officer K. Sharma',
        createdAt: DateTime.now(),
      );

      final provider = ComplaintProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ComplaintProvider>.value(value: provider),
            ],
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CitizenFeedbackModal.show(context, complaint),
                  child: const Text('Open Rating Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Rating Modal'));
      await tester.pumpAndSettle();

      // Check header and complaint info
      expect(find.text('Rate Resolution Quality'), findsOneWidget);
      expect(find.textContaining('#CMP-RATE-1'), findsOneWidget);
      expect(find.text('Resolved by: Officer K. Sharma'), findsOneWidget);

      // Default rating is 5 stars -> check sentiment
      expect(
        find.text('Excellent - Outstanding civic resolution!'),
        findsOneWidget,
      );

      // Verify quick tags are rendered
      expect(find.text('Fast Response'), findsOneWidget);
      expect(find.text('Clean Work'), findsOneWidget);
      expect(find.text('Polite Officer'), findsOneWidget);

      // Tap on a quick tag to toggle
      await tester.tap(find.text('Fast Response'));
      await tester.pumpAndSettle();

      // Enter custom comments in the feedback text field
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      await tester.enterText(textFieldFinder, 'Resolved within 2 hours. Very satisfied.');
      await tester.pumpAndSettle();

      // Tap Submit Feedback button
      final submitBtn = find.text('Submit Feedback');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify modal is dismissed
      expect(find.text('Rate Resolution Quality'), findsNothing);
    });

    testWidgets('Tapping star updates selected rating & sentiment label',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final complaint = ComplaintModel(
        id: '#CMP-RATE-2',
        title: 'Garbage Dump Overflow',
        description: 'Overflowing dump on corner',
        category: 'Sanitation',
        department: 'Solid Waste',
        priority: 'Medium',
        status: 'Resolved',
        location: 'Corner St',
        citizenName: 'Sneha Roy',
        createdAt: DateTime.now(),
      );

      final provider = ComplaintProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ComplaintProvider>.value(value: provider),
            ],
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CitizenFeedbackModal.show(context, complaint),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Find star icons (5 stars in rating row + 1 in header)
      final starIcons = find.byIcon(Icons.star_rounded);
      expect(starIcons, findsWidgets);

      // Tap the second star in the row (index 2 because index 0 is header icon)
      await tester.tap(starIcons.at(2));
      await tester.pumpAndSettle();

      // Verify label reflects 2-star rating
      expect(
        find.text('Fair - Resolution had shortcomings'),
        findsOneWidget,
      );

      // Tap "Maybe Later" to dismiss without submitting
      await tester.tap(find.text('Maybe Later'));
      await tester.pumpAndSettle();
      expect(find.text('Rate Resolution Quality'), findsNothing);
    });

    testWidgets('Close button dismisses CitizenFeedbackModal', (tester) async {
      final complaint = ComplaintModel(
        id: '#CMP-RATE-3',
        title: 'Streetlight Broken',
        description: 'Dark corner',
        category: 'Electricity',
        department: 'Power Board',
        priority: 'Low',
        status: 'Resolved',
        location: 'Cross 5',
        citizenName: 'Rohan Sen',
        createdAt: DateTime.now(),
      );

      final provider = ComplaintProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ComplaintProvider>.value(value: provider),
            ],
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CitizenFeedbackModal.show(context, complaint),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap Close icon button
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Rate Resolution Quality'), findsNothing);
    });
  });

  group('ComplaintDetailModal Citizen Feedback Display Widget Tests', () {
    testWidgets('Displays Rate & Review callout when resolved and unrated',
        (tester) async {
      final unratedResolvedComplaint = ComplaintModel(
        id: '#CMP-DETAIL-1',
        title: 'Water Pipeline Leak',
        description: 'Clean water gushing onto road',
        category: 'Water Supply',
        department: 'Water Department',
        priority: 'High',
        status: 'Resolved',
        location: 'MG Road',
        citizenName: 'Amit Singh',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    ComplaintDetailModal.show(context, unratedResolvedComplaint),
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      // Check review callout banner
      expect(find.text('Resolution Awaiting Your Review'), findsOneWidget);
      expect(find.text('Rate & Review'), findsOneWidget);
    });

    testWidgets('Displays Citizen Review & Rating when already rated',
        (tester) async {
      final ratedComplaint = ComplaintModel(
        id: '#CMP-DETAIL-2',
        title: 'Park Light Defect',
        description: 'Light in civic park dark',
        category: 'Electricity',
        department: 'Parks Dept',
        priority: 'Medium',
        status: 'Resolved',
        location: 'Central Park',
        citizenName: 'Anita Desai',
        citizenRating: 5,
        citizenFeedback: 'Outstanding resolution, repaired same evening!',
        ratedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    ComplaintDetailModal.show(context, ratedComplaint),
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      // Check review section and comment
      expect(find.text('Citizen Review & Rating'), findsOneWidget);
      expect(
        find.text('"Outstanding resolution, repaired same evening!"'),
        findsOneWidget,
      );
    });
  });

  group('ComplaintCard & Officer Detail Citizen Rating Display Widget Tests', () {
    testWidgets('ComplaintCard shows rating badge for rated resolved complaint',
        (tester) async {
      final ratedComplaint = ComplaintModel(
        id: '#CMP-CARD-1',
        title: 'Pothole on Cross Rd',
        description: 'Deep road damage',
        category: 'Roads',
        department: 'Road Works',
        priority: 'High',
        status: 'Resolved',
        location: 'Cross Rd 4',
        citizenName: 'Devika Nair',
        citizenRating: 4,
        citizenFeedback: 'Good work',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplaintCard(complaint: ratedComplaint),
          ),
        ),
      );

      // Verify "4.0" rating badge renders
      expect(find.text('4.0'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('ComplaintCard shows Rate chip for unrated resolved complaint',
        (tester) async {
      final unratedComplaint = ComplaintModel(
        id: '#CMP-CARD-2',
        title: 'Garbage on Street',
        description: 'Debris left behind',
        category: 'Sanitation',
        department: 'Solid Waste',
        priority: 'Low',
        status: 'Resolved',
        location: 'Street 12',
        citizenName: 'Deepak Jain',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplaintCard(complaint: unratedComplaint),
          ),
        ),
      );

      // Verify "Rate" chip renders
      expect(find.text('Rate'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });

    testWidgets('OfficerComplaintDetailsScreen renders Citizen Review & Rating',
        (tester) async {
      final complaintProvider = ComplaintProvider();
      expect(complaintProvider.complaints.isNotEmpty, true);

      final targetComplaint = complaintProvider.complaints.first;
      await complaintProvider.submitComplaintFeedback(
        complaintId: targetComplaint.id,
        rating: 5,
        feedback: 'Prompt and clean repair by officer!',
      );

      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ComplaintProvider>.value(
                  value: complaintProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: OfficerComplaintDetailsScreen(
                complaintId: targetComplaint.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check officer details renders citizen review
      expect(find.text('CITIZEN REVIEW & RATING'), findsOneWidget);
      expect(
        find.text('"Prompt and clean repair by officer!"'),
        findsOneWidget,
      );
      expect(find.textContaining('Submitted on'), findsOneWidget);
    });
  });
}
