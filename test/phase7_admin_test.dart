import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/admin_model.dart';
import 'package:citizen_connect/providers/admin_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/screens/admin/admin_analytics_screen.dart';
import 'package:citizen_connect/screens/admin/admin_auto_assign_screen.dart';
import 'package:citizen_connect/screens/admin/admin_complaints_screen.dart';
import 'package:citizen_connect/screens/admin/admin_home_screen.dart';
import 'package:citizen_connect/screens/admin/admin_main_screen.dart';
import 'package:citizen_connect/screens/admin/departments_oversight_screen.dart';
import 'package:citizen_connect/screens/admin/manage_officers_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdminProvider Unit Tests', () {
    test('Initialization metrics and attention queue', () {
      final provider = AdminProvider();
      expect(provider.metrics.total, 1248);
      expect(provider.metrics.resolutionRate, 92.0);
      expect(provider.metrics.overdue, 34);
      expect(provider.attentionItems.isNotEmpty, true);
      expect(provider.departments.length, 4);
      expect(provider.officers.length, 5);
    });

    test('Filter officers by status and search query', () {
      final provider = AdminProvider();
      expect(provider.filteredOfficers.length, 5);

      provider.setOfficerStatusFilter('Available');
      for (final off in provider.filteredOfficers) {
        expect(off.status, OfficerAvailabilityStatus.available);
      }

      provider.setOfficerStatusFilter('All Status');
      provider.searchOfficers('Sarah');
      expect(provider.filteredOfficers.length, 1);
      expect(provider.filteredOfficers.first.name, 'Sarah Jenkins');
    });

    test('Add and remove officer', () {
      final provider = AdminProvider();
      final initialCount = provider.officers.length;

      provider.addOfficer(
        name: 'Inspector Ramesh Kumar',
        department: 'Roads & Public Works',
        status: OfficerAvailabilityStatus.available,
      );
      expect(provider.officers.length, initialCount + 1);
      expect(provider.officers.first.name, 'Inspector Ramesh Kumar');

      final addedId = provider.officers.first.id;
      provider.removeOfficer(addedId);
      expect(provider.officers.length, initialCount);
    });

    test('Auto-assign recommendation and assignment execution', () {
      final provider = AdminProvider();
      final rec = provider.getAutoAssignRecommendation('#CMP-8921');

      expect(rec.complaintId, '#CMP-8921');
      expect(rec.distanceKm, 2.4);
      expect(rec.matchScore, 96);
      expect(rec.recommendedOfficer.name, isNotEmpty);

      final officerId = rec.recommendedOfficer.id;
      final initialInProgress = provider.metrics.inProgress;

      provider.assignComplaint('#CMP-8921', officerId);
      expect(provider.metrics.inProgress, initialInProgress + 1);
      expect(provider.attentionItems.any((c) => c.id == '#CMP-8921'), false);
    });
  });

  group('Phase 7 Admin UI Screen Widget Tests', () {
    testWidgets('AdminHomeScreen renders counters, attention feed, and chart',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminHomeScreen(),
          ),
        ),
      );

      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('1248'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('HIGH PRIORITY'), findsWidgets);
      expect(find.text('OVERDUE'), findsWidgets);
      expect(find.text('Requires Attention'), findsOneWidget);
      expect(find.text('Water Main Break - Downtown'), findsOneWidget);
      expect(find.text('Complaint Trends'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
    });

    testWidgets('AdminAutoAssignScreen renders AI recommendation and buttons',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminAutoAssignScreen(complaintId: '#CMP-8921'),
          ),
        ),
      );

      expect(find.text('Auto Assign Complaint'), findsOneWidget);
      expect(find.textContaining('#CMP-8921'), findsOneWidget);
      expect(find.text('AI RECOMMENDATION'), findsOneWidget);
      expect(find.textContaining('Suitability'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Active Workload'), findsOneWidget);
      expect(find.text('ACCEPT ASSIGNMENT'), findsOneWidget);
      expect(find.text('CHOOSE MANUALLY'), findsOneWidget);
    });

    testWidgets('AdminComplaintsScreen renders queue and auto-assign triggers',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminComplaintsScreen(),
          ),
        ),
      );

      expect(find.text('City Complaints Queue'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('High Priority'), findsWidgets);
      expect(find.text('Auto Assign'), findsWidgets);
    });

    testWidgets('ManageOfficersScreen renders directory and add officer FAB',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: ManageOfficersScreen(),
          ),
        ),
      );

      expect(find.text('Officer Directory'), findsOneWidget);
      expect(find.text('All Status'), findsOneWidget);
      expect(find.text('Available'), findsWidgets);
      expect(find.text('Raj Patel'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Add Officer'), findsOneWidget);
    });

    testWidgets('AdminAnalyticsScreen renders KPI tiles, bar chart, and AI stats',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminAnalyticsScreen(),
          ),
        ),
      );

      expect(find.text('Operational Analytics'), findsOneWidget);
      expect(find.text('TOTAL RESOLUTION RATE'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('AVG. RESPONSE TIME'), findsOneWidget);
      expect(find.text('1.2h'), findsOneWidget);
      expect(find.text('Category Breakdown'), findsOneWidget);
      expect(find.text('AI Civic Assistant Performance'), findsOneWidget);
    });

    testWidgets('DepartmentsOversightScreen renders division capacities',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: DepartmentsOversightScreen(),
          ),
        ),
      );

      expect(find.text('Department Oversight'), findsOneWidget);
      expect(find.text('Roads & Public Works'), findsOneWidget);
      expect(find.text('Sanitation & Waste'), findsOneWidget);
      expect(find.text('Water Supply & Sewerage'), findsOneWidget);
      expect(find.text('Electrical & Lighting'), findsOneWidget);
      expect(find.text('Workload Capacity'), findsWidgets);
    });

    testWidgets('AdminMainScreen renders 5 navigation tabs and switches content',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminMainScreen(),
          ),
        ),
      );

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Complaints'), findsOneWidget);
      expect(find.text('Auto Assign'), findsOneWidget);
      expect(find.text('Officers'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Tap Complaints tab
      await tester.tap(find.text('Complaints'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('City Complaints Queue'), findsOneWidget);

      // Tap Auto Assign tab
      await tester.tap(find.byIcon(Icons.smart_toy_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('AI RECOMMENDATION'), findsOneWidget);

      // Tap Officers tab
      await tester.tap(find.text('Officers'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Officer Directory'), findsOneWidget);

      // Tap Analytics tab
      await tester.tap(find.text('Analytics'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Operational Analytics'), findsOneWidget);
    });
  });
}
