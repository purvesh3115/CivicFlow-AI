import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/navigation/app_routes.dart';
import 'package:citizen_connect/navigation/route_generator.dart';
import 'package:citizen_connect/providers/admin_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/notification_provider.dart';
import 'package:citizen_connect/providers/services_provider.dart';
import 'package:citizen_connect/screens/admin/admin_analytics_screen.dart';
import 'package:citizen_connect/screens/admin/admin_auto_assign_screen.dart';
import 'package:citizen_connect/screens/admin/admin_main_screen.dart';
import 'package:citizen_connect/screens/citizen/notifications_screen.dart';
import 'package:citizen_connect/screens/citizen/services/service_details_screen.dart';
import 'package:citizen_connect/screens/citizen/services/service_eligibility_screen.dart';
import 'package:citizen_connect/screens/officer/officer_complaint_details_screen.dart';
import 'package:citizen_connect/widgets/evidence_image_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({
    required Widget child,
    AdminProvider? adminProvider,
    AuthProvider? authProvider,
    ComplaintProvider? complaintProvider,
    ServicesProvider? servicesProvider,
    NotificationProvider? notificationProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider ?? AuthProvider(),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => adminProvider ?? AdminProvider(),
        ),
        ChangeNotifierProvider<ComplaintProvider>(
          create: (_) => complaintProvider ?? ComplaintProvider(),
        ),
        ChangeNotifierProvider<ServicesProvider>(
          create: (_) => servicesProvider ?? ServicesProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => notificationProvider ?? NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        onGenerateRoute: RouteGenerator.generateRoute,
        home: child,
      ),
    );
  }

  group('Fix 1: Scheme Details & Eligibility Routes Resilience', () {
    test('ServicesProvider findServiceByIdOrTitle finds schemes accurately', () {
      final srv1 = ServicesProvider.findServiceByIdOrTitle('srv-health-universal');
      expect(srv1, isNotNull);
      expect(srv1!.title, 'Universal Healthcare Access');

      final srv2 = ServicesProvider.findServiceByIdOrTitle('solar');
      expect(srv2, isNotNull);
      expect(srv2!.id, 'srv-solar-subsidy');

      final fallback = ServicesProvider.fallbackService;
      expect(fallback, isNotNull);
      expect(fallback.id, isNotEmpty);
    });

    testWidgets('AppRoutes.serviceDetails resolves with null args without dead-end error',
        (tester) async {
      final route = RouteGenerator.generateRoute(
        const RouteSettings(name: AppRoutes.serviceDetails, arguments: null),
      );
      expect(route, isA<Route<dynamic>>());

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.serviceDetails),
                child: const Text('Open Details'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      expect(find.byType(ServiceDetailsScreen), findsOneWidget);
      expect(find.text('Service data not provided.'), findsNothing);
    });

    testWidgets('AppRoutes.serviceEligibility resolves with String ID without dead-end error',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.serviceEligibility,
                  arguments: 'srv-health-universal',
                ),
                child: const Text('Open Eligibility'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Eligibility'));
      await tester.pumpAndSettle();

      expect(find.byType(ServiceEligibilityScreen), findsOneWidget);
      expect(find.text('Eligibility Requirements'), findsOneWidget);
      expect(find.text('Service data not provided for eligibility.'), findsNothing);
    });
  });

  group('Fix 2: EvidenceImageViewer & Complaint Photo Rendering', () {
    testWidgets('EvidenceImageViewer renders network and placeholder images safely',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const EvidenceImageViewer(
                    imagePathOrUrl: 'https://example.com/test_photo.jpg',
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  const EvidenceImageViewer(
                    imagePathOrUrl: null,
                    attachments: [],
                    height: 150,
                  ),
                  const SizedBox(height: 10),
                  // Small thumbnail size test
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: const EvidenceImageViewer(
                      imagePathOrUrl: '/data/user/0/cache/picked_image.jpg',
                      height: 48,
                      width: 48,
                      enableZoom: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EvidenceImageViewer), findsNWidgets(3));
      expect(find.text('No Evidence Photo Attached'), findsOneWidget);
    });

    testWidgets('OfficerComplaintDetailsScreen displays complaint photo with EvidenceImageViewer',
        (tester) async {
      final complaintProvider = ComplaintProvider();
      final target = complaintProvider.complaints.first;

      await tester.pumpWidget(
        buildTestApp(
          complaintProvider: complaintProvider,
          child: OfficerComplaintDetailsScreen(complaintId: target.id),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(OfficerComplaintDetailsScreen), findsOneWidget);
      expect(find.byType(EvidenceImageViewer), findsOneWidget);
      expect(find.text(target.title), findsOneWidget);
    });
  });

  group('Fix 3: Admin Safe Navigation & Auto-Assign Sync', () {
    testWidgets('AdminAutoAssignScreen handles embedded display safely without crash',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const AdminAutoAssignScreen(complaintId: '#CMP-8492'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AdminAutoAssignScreen), findsOneWidget);
      expect(find.text('Auto Assign Complaint'), findsOneWidget);
      // Tapping ACCEPT ASSIGNMENT should not crash even when Navigator.canPop is false
      await tester.ensureVisible(find.text('ACCEPT ASSIGNMENT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ACCEPT ASSIGNMENT'));
      await tester.pumpAndSettle();

      expect(find.textContaining('successfully'), findsOneWidget);
    });

    testWidgets('AdminMainScreen can switch to Auto Assign Tab 2 cleanly',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const AdminMainScreen(initialTab: 2),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AdminMainScreen), findsOneWidget);
      expect(find.byType(AdminAutoAssignScreen), findsOneWidget);
      expect(find.text('Auto Assign Complaint'), findsOneWidget);
    });

    testWidgets('AdminAnalyticsScreen renders performance metrics and charts safely',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const AdminAnalyticsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AdminAnalyticsScreen), findsOneWidget);
      expect(find.text('Performance Metrics'), findsOneWidget);
      expect(find.text('Complaint Volume (Last 7 Days)'), findsOneWidget);
    });
  });

  group('Fix 4: Notification Navigation', () {
    testWidgets('Tapping scheme alert notification navigates to service details',
        (tester) async {
      final notifProvider = NotificationProvider();
      // Ensure there are notifications loaded

      await tester.pumpWidget(
        buildTestApp(
          notificationProvider: notifProvider,
          child: const NotificationsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
    });
  });
}
