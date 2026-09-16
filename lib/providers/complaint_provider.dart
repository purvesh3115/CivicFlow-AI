import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../services/offline_queue_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService;
  final OfflineQueueService _offlineQueueService;
  StreamSubscription<List<ComplaintModel>>? _complaintsSubscription;

  final List<ComplaintModel> _complaints = [];
  bool _isSyncingOfflineQueue = false;

  // Multi-step Draft State
  String _draftCategory = '';
  String _draftTitle = '';
  String _draftDescription = '';
  String _draftDepartment = 'Municipal Corporation';
  String _draftPriority = 'High';
  String _draftLocation = 'Main St & Elm St, Northbound lane, Anand';
  double? _draftLatitude = 22.5645;
  double? _draftLongitude = 72.9289;
  List<String> _draftAttachments = [];

  ComplaintModel? _lastSubmittedComplaint;
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  final bool _isLoading = false;

  ComplaintProvider({
    ComplaintService? complaintService,
    OfflineQueueService? offlineQueueService,
  })  : _complaintService = complaintService ?? ComplaintService(),
        _offlineQueueService = offlineQueueService ?? OfflineQueueService() {
    _initSampleComplaints();
    _startRealtimeListener();
    _loadOfflineQueuedComplaints();
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }

  // Getters
  List<ComplaintModel> get complaints => List.unmodifiable(_complaints);
  String get draftCategory => _draftCategory;
  String get draftTitle => _draftTitle;
  String get draftDescription => _draftDescription;
  String get draftDepartment => _draftDepartment;
  String get draftPriority => _draftPriority;
  String get draftLocation => _draftLocation;
  double? get draftLatitude => _draftLatitude;
  double? get draftLongitude => _draftLongitude;
  List<String> get draftAttachments => List.unmodifiable(_draftAttachments);
  ComplaintModel? get lastSubmittedComplaint => _lastSubmittedComplaint;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  int get activeCount => _complaints
      .where((c) =>
          c.status.toLowerCase() == 'submitted' ||
          c.status.toLowerCase() == 'new' ||
          c.status.toLowerCase() == 'under review')
      .length;

  int get inProgressCount => _complaints
      .where((c) =>
          c.status.toLowerCase() == 'in progress' ||
          c.status.toLowerCase() == 'working' ||
          c.status.toLowerCase() == 'assigned')
      .length;

  int get resolvedCount => _complaints
      .where((c) =>
          c.status.toLowerCase() == 'resolved' ||
          c.status.toLowerCase() == 'complete' ||
          c.status.toLowerCase() == 'closed')
      .length;

  bool get isSyncingOfflineQueue => _isSyncingOfflineQueue;

  int get inMemoryOfflineQueuedCount => _complaints
      .where((c) => c.status.toLowerCase() == 'queued offline')
      .length;

  Future<int> get offlineQueuedCount async =>
      await _offlineQueueService.getQueueCount();

  Future<void> _loadOfflineQueuedComplaints() async {
    try {
      final queued = await _offlineQueueService.getQueuedComplaints();
      for (final q in queued) {
        if (!_complaints.any((c) => c.id.toLowerCase() == q.id.toLowerCase())) {
          _complaints.insert(0, q);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<int> syncOfflineQueue() async {
    if (_isSyncingOfflineQueue) return 0;
    _isSyncingOfflineQueue = true;
    notifyListeners();

    try {
      final synced = await _offlineQueueService.syncQueue(
        complaintService: _complaintService,
      );

      if (synced > 0) {
        final remainingQueued = await _offlineQueueService.getQueuedComplaints();
        final remainingIds =
            remainingQueued.map((c) => c.id.toLowerCase()).toSet();

        // Update status of in-memory complaints that successfully synced to Submitted
        for (int i = 0; i < _complaints.length; i++) {
          if (_complaints[i].status.toLowerCase() == 'queued offline' &&
              !remainingIds.contains(_complaints[i].id.toLowerCase())) {
            _complaints[i] = _complaints[i].copyWith(
              status: 'Submitted',
              updatedAt: DateTime.now(),
            );
          }
        }
      }
      return synced;
    } finally {
      _isSyncingOfflineQueue = false;
      notifyListeners();
    }
  }

  void _startRealtimeListener() {
    try {
      _complaintsSubscription =
          _complaintService.getComplaintsStream().listen((firestoreComplaints) {
        if (firestoreComplaints.isNotEmpty) {
          // Merge / replace complaints with real Firestore data
          _complaints.clear();
          _complaints.addAll(firestoreComplaints);
          notifyListeners();
        }
      }, onError: (err) {
        if (kDebugMode) {
          print('Error in Firestore complaints subscription: $err');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Could not start Firestore listener: $e');
      }
    }
  }

  void _initSampleComplaints() {
    final now = DateTime.now();
    _complaints.addAll([
      ComplaintModel(
        id: '#C-4920',
        title: 'Water Supply Interruption',
        description:
            'Pipeline rupture near Sector 4 has cut off clean drinking water supply for 400 households.',
        category: 'Water',
        department: 'Water Supply & Sewerage Board',
        priority: 'High',
        status: 'Submitted',
        location: 'Sector 4, Anand, Gujarat',
        latitude: 22.5658,
        longitude: 72.9341,
        citizenName: 'Purvesh Patel',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
        attachments: ['https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800'],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ComplaintModel(
        id: '#C-4891',
        title: 'Severe Potholes on Main St.',
        description:
            'There is a large, deep pothole in the right lane going northbound, just past the intersection with Elm St. It spans almost half the lane and is causing vehicles to swerve dangerously.',
        category: 'Roads',
        department: 'Roads & Public Infrastructure',
        priority: 'Urgent',
        status: 'In Progress',
        location: 'Main St & Elm St, Northbound lane, Anand',
        latitude: 22.5645,
        longitude: 72.9289,
        assignedOfficerId: 'off_202',
        assignedOfficerName: 'Officer Rajesh Sharma',
        officerRemarks:
            'Inspection completed. Tar patch team dispatched. Estimated resolution 4:00 PM.',
        citizenName: 'Purvesh Patel',
        imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800',
        attachments: ['https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ComplaintModel(
        id: '#C-4810',
        title: 'Streetlight not working on MG Road',
        description:
            'Three consecutive street lamps have been non-functional for over 5 nights.',
        category: 'Street Lights',
        department: 'Electricity & Public Lighting',
        priority: 'Medium',
        status: 'Resolved',
        location: 'MG Road, Anand, Gujarat',
        latitude: 22.5612,
        longitude: 72.9220,
        assignedOfficerId: 'off-5',
        assignedOfficerName: 'Officer Amit Verma',
        officerRemarks: 'Bulb replaced and circuit breaker restored.',
        citizenName: 'Purvesh Patel',
        imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800',
        attachments: ['https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800'],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ComplaintModel(
        id: '#C-4762',
        title: 'Overflowing Garbage Bin',
        description:
            'Commercial waste container overflowing near Municipal Market.',
        category: 'Garbage',
        department: 'Sanitation & Solid Waste',
        priority: 'High',
        status: 'Resolved',
        location: 'Old Town Market, Anand',
        latitude: 22.5590,
        longitude: 72.9255,
        assignedOfficerId: 'off-3',
        assignedOfficerName: 'Officer Anita Desai',
        officerRemarks: 'Sanitation truck cleared waste and disinfected area.',
        citizenName: 'Purvesh Patel',
        imageUrl: 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2a?w=800',
        attachments: ['https://images.unsplash.com/photo-1605600659873-d808a13e4d2a?w=800'],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ComplaintModel(
        id: '#CMP-8492',
        title: 'Pothole near University Road',
        description: 'Large pothole near college entrance causing severe traffic slowdown.',
        category: 'Roads',
        department: 'Roads & Public Works',
        priority: 'High',
        status: 'In Progress',
        location: 'University Road, Anand',
        latitude: 22.5532,
        longitude: 72.9465,
        assignedOfficerId: 'off_202',
        assignedOfficerName: 'Officer Rajesh Sharma',
        officerRemarks: 'Inspection scheduled. Patch crew on standby.',
        citizenName: 'Student Union',
        imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800',
        attachments: ['https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800'],
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      ComplaintModel(
        id: '#CMP-8493',
        title: 'Traffic Light Malfunction',
        description: 'Signal remains stuck on red causing severe traffic backup at the intersection.',
        category: 'Street Lights',
        department: 'Electricity & Public Lighting',
        priority: 'High',
        status: 'Submitted',
        location: 'Station Circle, Anand',
        latitude: 22.5580,
        longitude: 72.9310,
        assignedOfficerId: 'off_202',
        assignedOfficerName: 'Officer Rajesh Sharma',
        officerRemarks: null,
        citizenName: 'Amit Kumar',
        imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800',
        attachments: ['https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800'],
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  // Officer Tasks State
  final List<OfficerTaskItem> _officerTasks = [
    OfficerTaskItem(
      id: 'task_1',
      title: 'Site Inspection',
      location: 'Downtown Sector A',
      time: '10:00 AM',
      isCompleted: false,
    ),
    OfficerTaskItem(
      id: 'task_2',
      title: 'Report Filing',
      location: 'HQ',
      time: '02:00 PM',
      isCompleted: true,
    ),
    OfficerTaskItem(
      id: 'task_3',
      title: 'Drainage Pipe Check',
      location: 'Sector 4 Junction',
      time: '04:30 PM',
      isCompleted: false,
    ),
  ];

  List<OfficerTaskItem> get officerTasks => List.unmodifiable(_officerTasks);

  void toggleTaskCompletion(String taskId) {
    final idx = _officerTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _officerTasks[idx].isCompleted = !_officerTasks[idx].isCompleted;
      notifyListeners();
    }
  }

  // Officer / Admin Status Mutation
  void updateComplaintStatus({
    required String id,
    required String newStatus,
    String? remarks,
    String? officerName,
    String? officerId,
    String? resolutionImageUrl,
  }) {
    final index =
        _complaints.indexWhere((c) => c.id.toLowerCase() == id.toLowerCase());

    if (index != -1) {
      final old = _complaints[index];
      final updated = old.copyWith(
        status: newStatus,
        officerRemarks: remarks ?? old.officerRemarks,
        assignedOfficerId: officerId ?? old.assignedOfficerId,
        assignedOfficerName:
            officerName ?? old.assignedOfficerName ?? 'Officer Rajesh Sharma',
        resolutionImageUrl: resolutionImageUrl ?? old.resolutionImageUrl,
        updatedAt: DateTime.now(),
      );
      _complaints[index] = updated;
      notifyListeners();

      // Sync to Firestore
      _complaintService.updateComplaintStatus(
        complaintId: updated.id,
        newStatus: newStatus,
        remarks: remarks,
        officerName: updated.assignedOfficerName,
        officerId: updated.assignedOfficerId,
        resolutionImageUrl: resolutionImageUrl,
      );
    } else {
      final newComp = ComplaintModel(
        id: id,
        title: 'Priority Grievance $id',
        description: remarks ?? 'Inspection and status updated to $newStatus.',
        category: 'Infrastructure',
        department: 'Roads & Public Infrastructure',
        priority: 'High',
        status: newStatus,
        location: 'Zone 4, Anand, Gujarat',
        latitude: 22.5645,
        longitude: 72.9289,
        assignedOfficerId: officerId ?? 'off_202',
        assignedOfficerName: officerName ?? 'Officer Rajesh Sharma',
        officerRemarks: remarks ?? 'Status updated by field officer.',
        citizenName: 'Purvesh Patel',
        resolutionImageUrl: resolutionImageUrl,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
      );
      _complaints.insert(0, newComp);
      notifyListeners();

      _complaintService.createComplaint(newComp);
    }
  }

  // Assign Officer to Complaint
  void assignOfficer({
    required String complaintId,
    required String officerId,
    required String officerName,
    String? department,
  }) {
    final index = _complaints
        .indexWhere((c) => c.id.toLowerCase() == complaintId.toLowerCase());

    if (index != -1) {
      final old = _complaints[index];
      _complaints[index] = old.copyWith(
        assignedOfficerId: officerId,
        assignedOfficerName: officerName,
        status: 'Assigned',
        department: department ?? old.department,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }

    _complaintService.assignOfficer(
      complaintId: complaintId,
      officerId: officerId,
      officerName: officerName,
      department: department,
    );
  }

  // Unassign Officer from Complaint
  void unassignOfficer({
    required String complaintId,
  }) {
    final index = _complaints
        .indexWhere((c) => c.id.toLowerCase() == complaintId.toLowerCase());

    if (index != -1) {
      final old = _complaints[index];
      _complaints[index] = old.copyWith(
        clearAssignment: true,
        status: 'Submitted',
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }

    _complaintService.unassignOfficer(complaintId: complaintId);
  }


  // Step 1: Category selection
  void setDraftCategory(String category) {
    _draftCategory = category;
    _draftDepartment = _resolveDepartment(category);
    if (_draftTitle.isEmpty) {
      if (category == 'Roads') {
        _draftTitle = 'Pothole on Main Street';
      } else if (category == 'Water') {
        _draftTitle = 'Water Leakage on Street';
      } else if (category == 'Garbage') {
        _draftTitle = 'Overflowing Trash Bin';
      } else if (category == 'Street Lights') {
        _draftTitle = 'Streetlight Malfunction';
      }
    }
    notifyListeners();
  }

  // Step 2: Details & Location
  void setDraftDetails({
    String? title,
    String? description,
    String? priority,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    if (title != null) _draftTitle = title;
    if (description != null) _draftDescription = description;
    if (priority != null) _draftPriority = priority;
    if (location != null) _draftLocation = location;
    if (latitude != null) _draftLatitude = latitude;
    if (longitude != null) _draftLongitude = longitude;
    notifyListeners();
  }

  // Step 3: Evidence (Images)
  void addDraftAttachment(String attachment) {
    _draftAttachments.add(attachment);
    notifyListeners();
  }

  void removeDraftAttachment(int index) {
    if (index >= 0 && index < _draftAttachments.length) {
      _draftAttachments.removeAt(index);
      notifyListeners();
    }
  }

  void clearDraftAttachments() {
    _draftAttachments.clear();
    notifyListeners();
  }

  // Step 4: Submission with MANDATORY Image Enforcement
  ComplaintModel submitComplaint({
    required String citizenName,
    String? citizenId,
    String? primaryImageUrl,
  }) {
    // ENFORCE MANDATORY IMAGE
    if (_draftAttachments.isEmpty &&
        (primaryImageUrl == null || primaryImageUrl.isEmpty)) {
      throw StateError('Please add an image of the issue.');
    }

    final newId = '#CC${(10000 + _complaints.length + 1)}';
    final mainImage = primaryImageUrl ??
        (_draftAttachments.isNotEmpty ? _draftAttachments.first : null);

    final complaint = ComplaintModel(
      id: newId,
      title: _draftTitle.isNotEmpty ? _draftTitle : 'Civic Issue Report',
      description: _draftDescription.isNotEmpty
          ? _draftDescription
          : 'Reported issue regarding $_draftCategory at $_draftLocation.',
      category: _draftCategory.isNotEmpty ? _draftCategory : 'General',
      department: _draftDepartment,
      priority: _draftPriority,
      status: 'Submitted',
      location: _draftLocation,
      latitude: _draftLatitude,
      longitude: _draftLongitude,
      imageUrl: mainImage,
      attachments: List.from(_draftAttachments),
      citizenId: citizenId ?? '',
      citizenName: citizenName,
      createdAt: DateTime.now(),
    );

    _complaints.insert(0, complaint);
    _lastSubmittedComplaint = complaint;

    // Persist to Cloud Firestore or fallback to offline queue
    _complaintService.createComplaint(complaint).then((success) {
      if (!success) {
        _queueComplaintOffline(complaint);
      }
    }).catchError((err) {
      if (kDebugMode) {
        print('Firestore complaint save error, queueing offline: $err');
      }
      _queueComplaintOffline(complaint);
    });

    // Reset draft fields
    resetDraft();
    notifyListeners();
    return complaint;
  }

  void _queueComplaintOffline(ComplaintModel complaint) {
    final offlineComp = complaint.copyWith(status: 'Queued Offline');
    final idx = _complaints.indexWhere((c) => c.id == complaint.id);
    if (idx != -1) {
      _complaints[idx] = offlineComp;
    }
    _offlineQueueService.queueComplaint(offlineComp);
    notifyListeners();
  }

  /// Async submission that uploads any local photo evidence to Firebase Storage first
  Future<ComplaintModel> submitComplaintAsync({
    required String citizenName,
    String? citizenId,
    String? primaryImageUrl,
  }) async {
    // ENFORCE MANDATORY IMAGE
    if (_draftAttachments.isEmpty &&
        (primaryImageUrl == null || primaryImageUrl.isEmpty)) {
      throw StateError('Please add an image of the issue.');
    }

    final newId = '#CC${(10000 + _complaints.length + 1)}';

    // Upload any local file paths in _draftAttachments to Firebase Storage
    final List<String> uploadedAttachments = [];
    for (final att in _draftAttachments) {
      if (!att.startsWith('http')) {
        try {
          final file = File(att);
          if (await file.exists()) {
            final downloadUrl = await _complaintService.uploadComplaintImage(
              file: file,
              complaintId: newId,
            );
            uploadedAttachments.add(downloadUrl);
          } else {
            uploadedAttachments.add(att);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Storage upload warning for $att: $e');
          }
          uploadedAttachments.add(att);
        }
      } else {
        uploadedAttachments.add(att);
      }
    }

    final mainImage = primaryImageUrl ??
        (uploadedAttachments.isNotEmpty ? uploadedAttachments.first : null);

    final complaint = ComplaintModel(
      id: newId,
      title: _draftTitle.isNotEmpty ? _draftTitle : 'Civic Issue Report',
      description: _draftDescription.isNotEmpty
          ? _draftDescription
          : 'Reported issue regarding $_draftCategory at $_draftLocation.',
      category: _draftCategory.isNotEmpty ? _draftCategory : 'General',
      department: _draftDepartment,
      priority: _draftPriority,
      status: 'Submitted',
      location: _draftLocation,
      latitude: _draftLatitude,
      longitude: _draftLongitude,
      imageUrl: mainImage,
      attachments: uploadedAttachments,
      citizenId: citizenId ?? '',
      citizenName: citizenName,
      createdAt: DateTime.now(),
    );

    _complaints.insert(0, complaint);
    _lastSubmittedComplaint = complaint;

    // Persist to Cloud Firestore or fallback to offline queue
    bool firestoreSuccess = false;
    try {
      firestoreSuccess = await _complaintService.createComplaint(complaint);
    } catch (err) {
      if (kDebugMode) {
        print('Firestore complaint save error, queuing offline: $err');
      }
    }

    ComplaintModel finalComplaint = complaint;
    if (!firestoreSuccess) {
      finalComplaint = complaint.copyWith(status: 'Queued Offline');
      _lastSubmittedComplaint = finalComplaint;
      _queueComplaintOffline(complaint);
    }

    // Reset draft fields
    resetDraft();
    notifyListeners();
    return finalComplaint;
  }

  void resetDraft() {
    _draftCategory = '';
    _draftTitle = '';
    _draftDescription = '';
    _draftDepartment = 'Municipal Corporation';
    _draftPriority = 'High';
    _draftLocation = 'Main St & Elm St, Northbound lane, Anand';
    _draftLatitude = 22.5645;
    _draftLongitude = 72.9289;
    _draftAttachments = [];
    notifyListeners();
  }

  // Filtering
  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ComplaintModel> get filteredComplaints {
    return _complaints.where((c) {
      final matchesFilter = _selectedStatusFilter == 'All' ||
          c.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.location.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  ComplaintModel? getComplaintById(String id) {
    try {
      return _complaints.firstWhere(
        (c) => c.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  String _resolveDepartment(String category) {
    switch (category.toLowerCase()) {
      case 'roads':
        return 'Roads & Infrastructure Department';
      case 'garbage':
        return 'Sanitation & Solid Waste Management';
      case 'water':
        return 'Water Supply & Sewerage Board';
      case 'street lights':
      case 'electricity':
        return 'Public Lighting & Electricity';
      case 'drainage':
        return 'Drainage & Stormwater Drainage';
      case 'pollution':
        return 'Environmental Protection Cell';
      case 'public safety':
        return 'Civil Defense & Safety';
      default:
        return 'Municipal Administration';
    }
  }
}
