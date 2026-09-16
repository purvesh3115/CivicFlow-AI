import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/complaint_model.dart';
import 'package:citizen_connect/providers/admin_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/screens/admin/admin_complaints_screen.dart';
import 'package:citizen_connect/screens/admin/manage_officers_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Admin Officer Work Management Provider Unit Tests', () {
    test('Assign and unassign complaint in AdminProvider', () {
      final provider = AdminProvider();
      expect(provider.officers.isNotEmpty, true);

      final officer1 = provider.officers[0];
      final officer2 = provider.officers[1];
      final initialOfficer1Tasks = officer1.activeTasks;

      // 1. Assign to officer 1
      provider.assignComplaint('#CMP-8921', officer1.id);
      final off1AfterAssign =
          provider.officers.firstWhere((o) => o.id == officer1.id);
      expect(off1AfterAssign.activeTasks, initialOfficer1Tasks + 1);

      // 2. Reassign to officer 2 -> officer 1 tasks should decrement, officer 2 tasks should increment
      final initialOfficer2Tasks = officer2.activeTasks;
      provider.assignComplaint('#CMP-8921', officer2.id);

      final off1AfterReassign =
          provider.officers.firstWhere((o) => o.id == officer1.id);
      final off2AfterReassign =
          provider.officers.firstWhere((o) => o.id == officer2.id);

      expect(off1AfterReassign.activeTasks, initialOfficer1Tasks);
      expect(off2AfterReassign.activeTasks, initialOfficer2Tasks + 1);

      // 3. Unassign complaint -> officer 2 tasks should decrement, complaint returned to attention queue
      provider.unassignComplaint('#CMP-8921');
      final off2AfterUnassign =
          provider.officers.firstWhere((o) => o.id == officer2.id);
      expect(off2AfterUnassign.activeTasks, initialOfficer2Tasks);
    });

    test('ComplaintProvider unassignOfficer clears assignment and resets to Submitted', () {
      final complaintProvider = ComplaintProvider();
      expect(complaintProvider.complaints.isNotEmpty, true);

      // Take first complaint and assign officer
      final targetId = complaintProvider.complaints.first.id;
      complaintProvider.assignOfficer(
        complaintId: targetId,
        officerId: 'off-test-1',
        officerName: 'Test Officer',
      );

      final assigned = complaintProvider.complaints
          .firstWhere((c) => c.id == targetId);
      expect(assigned.assignedOfficerId, 'off-test-1');
      expect(assigned.status, 'Assigned');

      // Now unassign
      complaintProvider.unassignOfficer(complaintId: targetId);
      final unassigned = complaintProvider.complaints
          .firstWhere((c) => c.id == targetId);
      expect(unassigned.assignedOfficerId, isNull);
      expect(unassigned.assignedOfficerName, isNull);
      expect(unassigned.status, 'Submitted');
    });

    test('AdminProvider getOfficerWork and getUnassignedComplaints query helpers', () {
      final provider = AdminProvider();
      final officer = provider.officers.first;

      final initialWork = provider.getOfficerWork(officer.id);
      expect(initialWork, isA<List<ComplaintModel>>());

      final unassigned = provider.getUnassignedComplaints();
      expect(unassigned, isA<List<ComplaintModel>>());
    });

    test('AdminProvider removeOfficer unassigns complaints and removes from list', () {
      final provider = AdminProvider();
      final initialCount = provider.officers.length;

      // Add a test officer
      provider.addOfficer(
        name: 'Temporary Officer',
        department: 'Sanitation & Waste',
      );
      expect(provider.officers.length, initialCount + 1);
      final newOfficerId = provider.officers.first.id;

      // Remove the officer
      provider.removeOfficer(newOfficerId);
      expect(provider.officers.length, initialCount);
      expect(provider.officers.any((o) => o.id == newOfficerId), false);
    });
  });

  group('Admin Officer Work Management UI Widget Tests', () {
    testWidgets('ManageOfficersScreen renders Manage Work and Assign buttons',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: ManageOfficersScreen(),
          ),
        ),
      );

      // Verify header and filter chips
      expect(find.text('Officer Directory'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('On Task'), findsOneWidget);

      // Verify officer cards render Manage Work and Assign buttons
      expect(find.textContaining('Manage Work'), findsWidgets);
      expect(find.text('Assign'), findsWidgets);
    });

    testWidgets('ManageOfficersScreen opening work sheet shows assigned work and status selector',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: ManageOfficersScreen(),
          ),
        ),
      );

      // Tap on first Manage Work button
      final manageWorkBtn = find.textContaining('Manage Work').first;
      await tester.tap(manageWorkBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('Assigned Work'), findsOneWidget);
      expect(find.text('Availability Status'), findsOneWidget);
      expect(find.text('Assign Work'), findsWidgets);
    });

    testWidgets('AdminComplaintsScreen detail modal renders Unassign button for assigned complaints',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final complaintProvider = ComplaintProvider();
      final adminProvider = AdminProvider();

      // Ensure at least one complaint is assigned
      final target = complaintProvider.complaints.first;
      complaintProvider.assignOfficer(
        complaintId: target.id,
        officerId: 'off-1',
        officerName: 'Raj Patel',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: complaintProvider),
            ChangeNotifierProvider.value(value: adminProvider),
          ],
          child: const MaterialApp(
            home: AdminComplaintsScreen(),
          ),
        ),
      );

      // Open detail modal on first complaint
      final detailBtn = find.text('Details').first;
      await tester.tap(detailBtn);
      await tester.pumpAndSettle();

      // Scroll inside modal to ensure buttons are laid out
      await tester.scrollUntilVisible(
        find.text('Reassign Field Officer'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      // Verify Reassign and Unassign buttons are present
      expect(find.text('Reassign Field Officer'), findsOneWidget);
      expect(find.text('Unassign / Remove Officer'), findsOneWidget);
    });
  });
}
