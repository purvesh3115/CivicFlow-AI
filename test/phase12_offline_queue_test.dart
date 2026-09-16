import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/complaint_model.dart';
import 'package:citizen_connect/models/user_model.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/providers/notification_provider.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaint_success_screen.dart';
import 'package:citizen_connect/screens/citizen/complaints/complaints_list_screen.dart';
import 'package:citizen_connect/screens/citizen/home_screen.dart';
import 'package:citizen_connect/services/complaint_service.dart';
import 'package:citizen_connect/services/offline_queue_service.dart';

class MockComplaintService extends ComplaintService {
  bool shouldSucceed = true;
  final List<ComplaintModel> createdComplaints = [];

  @override
  Future<bool> createComplaint(ComplaintModel complaint) async {
    if (!shouldSucceed) {
      throw Exception('Network unreachable - offline simulation');
    }
    createdComplaints.add(complaint);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 12: OfflineQueueService Unit Tests', () {
    test('Queue complaint, retrieve complaints, and verify count', () async {
      final queueService = OfflineQueueService();
      final complaint = ComplaintModel(
        id: '#CC-TEST-001',
        title: 'Offline Water Pipe Leak',
        description: 'Water pipe leaking severely with zero cellular network.',
        category: 'Water',
        department: 'Water Supply & Sewerage Board',
        priority: 'High',
        status: 'Submitted',
        location: 'Sector 9, Rural Anand',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
        attachments: [
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957'
        ],
        citizenName: 'Purvesh Patel',
        createdAt: DateTime.now(),
      );

      final queueSuccess = await queueService.queueComplaint(complaint);
      expect(queueSuccess, true);

      final count = await queueService.getQueueCount();
      expect(count, 1);

      final queuedItems = await queueService.getQueuedComplaints();
      expect(queuedItems.length, 1);
      expect(queuedItems.first.id, '#CC-TEST-001');
      expect(queuedItems.first.status, 'Queued Offline');

      // Deduplication: queueing same ID again should not increase count
      await queueService.queueComplaint(complaint);
      final countAfterRequeue = await queueService.getQueueCount();
      expect(countAfterRequeue, 1);

      // Remove complaint
      final removeSuccess =
          await queueService.removeQueuedComplaint('#CC-TEST-001');
      expect(removeSuccess, true);
      final countAfterRemove = await queueService.getQueueCount();
      expect(countAfterRemove, 0);
    });

    test('syncQueue successfully pushes queued items to ComplaintService and clears queue',
        () async {
      final queueService = OfflineQueueService();
      final mockService = MockComplaintService();

      final complaint1 = ComplaintModel(
        id: '#CC-OFFLINE-1',
        title: 'Broken Streetlamp',
        description: 'Light non-functional for 2 days.',
        category: 'Street Lights',
        department: 'Electricity & Public Lighting',
        priority: 'Medium',
        status: 'Submitted',
        location: 'Station Road',
        imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395',
        attachments: [
          'https://images.unsplash.com/photo-1508873696983-2df5293cb395'
        ],
        citizenName: 'Purvesh Patel',
        createdAt: DateTime.now(),
      );

      final complaint2 = ComplaintModel(
        id: '#CC-OFFLINE-2',
        title: 'Uncollected Trash',
        description: 'Garbage heap left behind market.',
        category: 'Garbage',
        department: 'Sanitation & Solid Waste',
        priority: 'High',
        status: 'Submitted',
        location: 'Market Crossroad',
        imageUrl: 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2a',
        attachments: [
          'https://images.unsplash.com/photo-1605600659873-d808a13e4d2a'
        ],
        citizenName: 'Purvesh Patel',
        createdAt: DateTime.now(),
      );

      await queueService.queueComplaint(complaint1);
      await queueService.queueComplaint(complaint2);
      expect(await queueService.getQueueCount(), 2);

      // Trigger sync
      final syncedCount =
          await queueService.syncQueue(complaintService: mockService);
      expect(syncedCount, 2);
      expect(mockService.createdComplaints.length, 2);
      expect(await queueService.getQueueCount(), 0);
    });
  });

  group('Phase 12: ComplaintProvider Offline & Sync Integration Tests', () {
    test('submitComplaint falls back to offline queue on network error',
        () async {
      final mockService = MockComplaintService();
      mockService.shouldSucceed = false; // Simulate offline network failure
      final queueService = OfflineQueueService();

      final provider = ComplaintProvider(
        complaintService: mockService,
        offlineQueueService: queueService,
      );

      provider.setDraftCategory('Roads');
      provider.setDraftDetails(
        title: 'Deep Crater on Highway',
        description: 'Road surface collapsed after rain.',
        priority: 'Urgent',
        location: 'Expressway km 42',
      );
      provider.addDraftAttachment(
          'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7');

      final submitted = provider.submitComplaint(
        citizenName: 'Purvesh Patel',
      );

      expect(submitted.title, 'Deep Crater on Highway');
      // In-memory complaint is available immediately
      expect(provider.complaints.any((c) => c.id == submitted.id), true);

      // Verify async offline queue persistence
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.inMemoryOfflineQueuedCount, greaterThanOrEqualTo(1));
      expect(await queueService.getQueueCount(), 1);

      // Now restore network connectivity and sync
      mockService.shouldSucceed = true;
      final synced = await provider.syncOfflineQueue();
      expect(synced, 1);
      expect(await queueService.getQueueCount(), 0);
      expect(provider.inMemoryOfflineQueuedCount, 0);
    });

    test('submitComplaintAsync returns Queued Offline complaint when offline',
        () async {
      final mockService = MockComplaintService();
      mockService.shouldSucceed = false;
      final queueService = OfflineQueueService();

      final provider = ComplaintProvider(
        complaintService: mockService,
        offlineQueueService: queueService,
      );

      provider.setDraftCategory('Garbage');
      provider.setDraftDetails(
        title: 'Litter in public park',
        description: 'Trash bins overflowing.',
        priority: 'Low',
        location: 'Childrens Park, Anand',
      );
      provider.addDraftAttachment(
          'https://images.unsplash.com/photo-1605600659873-d808a13e4d2a');

      final submitted = await provider.submitComplaintAsync(
        citizenName: 'Purvesh Patel',
      );

      expect(submitted.status, 'Queued Offline');
      expect(provider.inMemoryOfflineQueuedCount, 1);
      expect(await queueService.getQueueCount(), 1);
    });
  });

  group('Phase 12: Offline UI & Banner Widget Tests', () {
    testWidgets('ComplaintsListScreen renders Offline Sync Banner with Sync Now button',
        (tester) async {
      final queueService = OfflineQueueService();
      final mockService = MockComplaintService();
      mockService.shouldSucceed = false;

      final provider = ComplaintProvider(
        complaintService: mockService,
        offlineQueueService: queueService,
      );

      // Queue an offline complaint
      provider.setDraftCategory('Water');
      provider.setDraftDetails(
        title: 'Leaking Municipal Pipe',
        description: 'Clean drinking water pooling on street.',
      );
      provider.addDraftAttachment(
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957');
      await provider.submitComplaintAsync(citizenName: 'Purvesh Patel');

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ComplaintProvider>.value(value: provider),
            ],
            child: const ComplaintsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Offline Sync Banner appears
      expect(find.text('Offline Complaints Queued'), findsOneWidget);
      expect(find.text('1 issue(s) waiting to upload.'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);

      // Tap Sync Now
      mockService.shouldSucceed = true;
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();

      // Verify that offline banner is gone once synced
      expect(find.text('Offline Complaints Queued'), findsNothing);
    });

    testWidgets('HomeScreen renders offline alert banner when complaints are queued',
        (tester) async {
      final queueService = OfflineQueueService();
      final mockService = MockComplaintService();
      mockService.shouldSucceed = false;

      final complaintProvider = ComplaintProvider(
        complaintService: mockService,
        offlineQueueService: queueService,
      );

      final authProvider = AuthProvider();
      authProvider.switchPersona(UserRole.citizen);

      final notifProvider = NotificationProvider();

      // Queue an offline complaint
      complaintProvider.setDraftCategory('Roads');
      complaintProvider.setDraftDetails(
        title: 'Pothole on Crossroad',
        description: 'Road hazard in village zone.',
      );
      complaintProvider.addDraftAttachment(
          'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7');
      await complaintProvider.submitComplaintAsync(citizenName: 'Purvesh Patel');

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<NotificationProvider>.value(
                  value: notifProvider),
              ChangeNotifierProvider<ComplaintProvider>.value(
                  value: complaintProvider),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offline Complaints Queued'), findsOneWidget);
      expect(find.text('1 issue(s) waiting to upload.'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
    });

    testWidgets('ComplaintSuccessScreen renders offline badge & explanation when queued',
        (tester) async {
      final offlineComplaint = ComplaintModel(
        id: '#CC-OFFLINE-999',
        title: 'Offline Emergency Drain',
        description: 'Severe blockage.',
        category: 'Drainage',
        department: 'Drainage & Stormwater Drainage',
        priority: 'Urgent',
        status: 'Queued Offline',
        location: 'Zone 2, Anand',
        citizenName: 'Purvesh Patel',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ComplaintSuccessScreen(complaint: offlineComplaint),
        ),
      );

      await tester.pump();

      expect(find.text('Saved to Offline Queue'), findsOneWidget);
      expect(find.text('#CC-OFFLINE-999'), findsOneWidget);
      expect(find.text('Queued Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsWidgets);
    });
  });
}
