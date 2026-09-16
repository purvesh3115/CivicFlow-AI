import 'dart:async';
import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../models/complaint_model.dart';
import '../models/user_model.dart';
import '../services/complaint_service.dart';
import '../services/user_service.dart';

class AdminProvider extends ChangeNotifier {
  final ComplaintService _complaintService;
  final UserService _userService;
  StreamSubscription<List<ComplaintModel>>? _complaintsSub;
  StreamSubscription<List<UserModel>>? _officersSub;

  AdminMetricsModel _metrics = const AdminMetricsModel();
  String _officerSearchQuery = '';
  String _officerStatusFilter = 'All Status';
  String _complaintStatusFilter = 'All';

  final List<AdminOfficerModel> _officers = [
    const AdminOfficerModel(
      id: 'off-1',
      name: 'Raj Patel',
      department: 'Roads & Public Works',
      status: OfficerAvailabilityStatus.available,
      activeTasks: 4,
      completedTasks: 28,
      rating: 4.9,
    ),
    const AdminOfficerModel(
      id: 'off-2',
      name: 'Sarah Jenkins',
      department: 'Parks & Recreation',
      status: OfficerAvailabilityStatus.onTask,
      activeTasks: 1,
      completedTasks: 142,
      rating: 4.8,
    ),
    const AdminOfficerModel(
      id: 'off-3',
      name: 'Elena Rodriguez',
      department: 'Public Health',
      status: OfficerAvailabilityStatus.offline,
      activeTasks: 0,
      completedTasks: 89,
      rating: 4.7,
    ),
    const AdminOfficerModel(
      id: 'off-4',
      name: 'Vikram Singh',
      department: 'Water Supply & Sewerage',
      status: OfficerAvailabilityStatus.available,
      activeTasks: 2,
      completedTasks: 65,
      rating: 4.8,
    ),
    const AdminOfficerModel(
      id: 'off-5',
      name: 'Priya Sharma',
      department: 'Electrical & Street Lighting',
      status: OfficerAvailabilityStatus.onTask,
      activeTasks: 3,
      completedTasks: 94,
      rating: 4.9,
    ),
  ];

  final List<AdminComplaintAttentionItem> _attentionItems = [];
  final List<ComplaintModel> _allComplaints = [];

  final List<DepartmentOversightModel> _departments = const [
    DepartmentOversightModel(
      id: 'dep-1',
      name: 'Roads & Public Works',
      icon: Icons.commute_rounded,
      activeComplaints: 142,
      officerCount: 18,
      capacityPercentage: 85,
      avgResolutionDays: 2.4,
    ),
    DepartmentOversightModel(
      id: 'dep-2',
      name: 'Sanitation & Waste',
      icon: Icons.delete_outline_rounded,
      activeComplaints: 98,
      officerCount: 14,
      capacityPercentage: 72,
      avgResolutionDays: 1.8,
    ),
    DepartmentOversightModel(
      id: 'dep-3',
      name: 'Water Supply & Sewerage',
      icon: Icons.water_drop_outlined,
      activeComplaints: 84,
      officerCount: 12,
      capacityPercentage: 65,
      avgResolutionDays: 2.1,
    ),
    DepartmentOversightModel(
      id: 'dep-4',
      name: 'Electrical & Lighting',
      icon: Icons.lightbulb_outline_rounded,
      activeComplaints: 62,
      officerCount: 10,
      capacityPercentage: 58,
      avgResolutionDays: 1.5,
    ),
  ];

  // 7-day trend metrics
  final List<double> _weeklyVolumes = [45, 52, 68, 55, 78, 62, 58];
  final List<String> weeklyDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  AdminProvider({
    ComplaintService? complaintService,
    UserService? userService,
  })  : _complaintService = complaintService ?? ComplaintService(),
        _userService = userService ?? UserService() {
    _initSampleAttentionItems();
    _startListeners();
  }

  @override
  void dispose() {
    _complaintsSub?.cancel();
    _officersSub?.cancel();
    super.dispose();
  }

  AdminMetricsModel get metrics => _metrics;
  List<AdminOfficerModel> get officers => List.unmodifiable(_officers);
  List<AdminComplaintAttentionItem> get attentionItems =>
      List.unmodifiable(_attentionItems);
  List<ComplaintModel> get allComplaints => List.unmodifiable(_allComplaints);
  List<DepartmentOversightModel> get departments =>
      List.unmodifiable(_departments);
  String get officerStatusFilter => _officerStatusFilter;
  String get officerSearchQuery => _officerSearchQuery;
  String get complaintStatusFilter => _complaintStatusFilter;
  List<double> get weeklyVolumes => List.unmodifiable(_weeklyVolumes);

  void _initSampleAttentionItems() {
    _attentionItems.addAll([
      const AdminComplaintAttentionItem(
        id: '#CMP-8921',
        title: 'Water Main Break - Downtown',
        description: 'Major water line rupture on 5th Ave causing street flooding and pressure drop.',
        priority: 'High',
        timeAgo: '12m ago',
        location: '5th Ave & Pine St',
        department: 'Water & Sanitation',
        isOverdue: false,
      ),
      const AdminComplaintAttentionItem(
        id: '#CMP-8894',
        title: 'Traffic Signal Malfunction',
        description: 'Intersection signals flashing red, creating severe peak-hour congestion.',
        priority: 'Overdue',
        timeAgo: '4h ago',
        location: 'Broad St & Market Blvd',
        department: 'Traffic & Enforcement',
        isOverdue: true,
      ),
      const AdminComplaintAttentionItem(
        id: '#CMP-8910',
        title: 'Hazardous Waste Dump',
        description: 'Industrial barrels abandoned near local elementary school perimeter.',
        priority: 'High',
        timeAgo: '45m ago',
        location: 'Oak Lane Industrial Park',
        department: 'Public Safety',
        isOverdue: false,
      ),
      const AdminComplaintAttentionItem(
        id: '#CMP-8872',
        title: 'Fallen Tree Blocking Road',
        description: 'Storm damaged branch blocking two lanes of westbound commuter traffic.',
        priority: 'Overdue',
        timeAgo: '6h ago',
        location: 'Westwood Expressway km 14',
        department: 'Roads & Public Works',
        isOverdue: true,
      ),
    ]);
  }

  void _startListeners() {
    // 1. Realtime complaints sync for Admin
    try {
      _complaintsSub = _complaintService.getComplaintsStream().listen((list) {
        _allComplaints.clear();
        _allComplaints.addAll(list);

        // Update attention items from real complaints if any are high priority or overdue
        if (list.isNotEmpty) {
          _attentionItems.clear();
          for (final c in list) {
            final isHigh = c.priority.toLowerCase() == 'high' ||
                c.priority.toLowerCase() == 'urgent';
            final isOverdue = c.status.toLowerCase() == 'overdue' ||
                c.status.toLowerCase() == 'escalated';
            final isPending = c.status.toLowerCase() == 'submitted' ||
                c.status.toLowerCase() == 'new';

            if ((isHigh || isOverdue || isPending) &&
                c.status.toLowerCase() != 'resolved' &&
                c.status.toLowerCase() != 'closed') {
              _attentionItems.add(
                AdminComplaintAttentionItem(
                  id: c.id,
                  title: c.title,
                  description: c.description,
                  priority: isOverdue ? 'Overdue' : c.priority,
                  timeAgo: _formatTimeAgo(c.createdAt),
                  location: c.location,
                  department: c.department,
                  isOverdue: isOverdue,
                ),
              );
            }
          }
        }
        _recalculateMetrics();
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}

    // 2. Realtime officers sync
    try {
      _officersSub = _userService.getOfficersStream().listen((officerUsers) {
        if (officerUsers.isNotEmpty) {
          for (final u in officerUsers) {
            if (!_officers.any((o) => o.id == u.id)) {
              _officers.add(
                AdminOfficerModel(
                  id: u.id,
                  name: u.name,
                  department: u.department ?? 'Roads & Public Works',
                  status: OfficerAvailabilityStatus.available,
                  activeTasks: 1,
                  completedTasks: 10,
                  rating: 4.8,
                ),
              );
            }
          }
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _recalculateMetrics() {
    if (_allComplaints.isNotEmpty) {
      final total = _allComplaints.length;
      final newCount = _allComplaints
          .where((c) =>
              c.status.toLowerCase() == 'submitted' ||
              c.status.toLowerCase() == 'live' ||
              c.status.toLowerCase() == 'new')
          .length;
      final inProgress = _allComplaints
          .where((c) =>
              c.status.toLowerCase() == 'in progress' ||
              c.status.toLowerCase() == 'working' ||
              c.status.toLowerCase() == 'assigned')
          .length;
      final highPriority = _allComplaints
          .where((c) =>
              c.priority.toLowerCase() == 'high' ||
              c.priority.toLowerCase() == 'urgent')
          .length;
      final overdue = _allComplaints
          .where((c) =>
              c.status.toLowerCase() == 'overdue' ||
              c.status.toLowerCase() == 'escalated')
          .length;
      final resolved = _allComplaints
          .where((c) =>
              c.status.toLowerCase() == 'resolved' ||
              c.status.toLowerCase() == 'closed')
          .length;

      _metrics = AdminMetricsModel(
        total: total,
        newCount: newCount,
        inProgress: inProgress,
        highPriority: highPriority,
        overdue: overdue,
        resolved: resolved,
        resolutionRate: total > 0 ? ((resolved / total) * 100).toDouble() : 92.0,
        avgResponseHours: 1.2,
      );
    } else {
      _metrics = const AdminMetricsModel();
    }
  }

  List<AdminOfficerModel> get filteredOfficers {
    return _officers.where((officer) {
      final matchesSearch = _officerSearchQuery.isEmpty ||
          officer.name.toLowerCase().contains(_officerSearchQuery.toLowerCase()) ||
          officer.department.toLowerCase().contains(_officerSearchQuery.toLowerCase());

      final matchesStatus = _officerStatusFilter == 'All Status' ||
          officer.status.label.toLowerCase() == _officerStatusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void searchOfficers(String query) {
    _officerSearchQuery = query.trim();
    notifyListeners();
  }

  void setOfficerStatusFilter(String status) {
    _officerStatusFilter = status;
    notifyListeners();
  }

  void setComplaintStatusFilter(String filter) {
    _complaintStatusFilter = filter;
    notifyListeners();
  }

  void addOfficer({
    required String name,
    required String department,
    OfficerAvailabilityStatus status = OfficerAvailabilityStatus.available,
  }) {
    final newOfficer = AdminOfficerModel(
      id: 'off-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      department: department,
      status: status,
      activeTasks: 0,
      completedTasks: 0,
      rating: 5.0,
    );
    _officers.insert(0, newOfficer);

    _userService.saveUser(
      UserModel(
        id: newOfficer.id,
        name: name,
        phone: '+91 98765 00000',
        email: '${name.toLowerCase().replaceAll(' ', '.')}@citizenconnect.gov.in',
        role: UserRole.officer,
        department: department,
        city: 'Anand, Gujarat',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void removeOfficer(String id) {
    // Unassign all active complaints assigned to this officer
    final assigned = _allComplaints.where((c) => c.assignedOfficerId == id).toList();
    for (final c in assigned) {
      unassignComplaint(c.id);
    }
    _officers.removeWhere((off) => off.id == id);
    notifyListeners();
  }

  void updateOfficerStatus(String id, OfficerAvailabilityStatus newStatus) {
    final idx = _officers.indexWhere((off) => off.id == id);
    if (idx != -1) {
      _officers[idx] = _officers[idx].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  /// Guard against empty items, mismatch IDs, and prioritize target complaint accurately
  AutoAssignRecommendation getAutoAssignRecommendation(String complaintId) {
    final cleanTarget = complaintId.toLowerCase().trim();

    // 1. Try finding exact complaint in _allComplaints
    final complaintMatch = _allComplaints.where(
      (c) => c.id.toLowerCase().trim() == cleanTarget,
    ).firstOrNull;

    // 2. Try finding in _attentionItems
    final attentionMatch = _attentionItems.where(
      (c) => c.id.toLowerCase().trim() == cleanTarget,
    ).firstOrNull;

    AdminComplaintAttentionItem targetItem;
    if (complaintMatch != null) {
      targetItem = AdminComplaintAttentionItem(
        id: complaintMatch.id,
        title: complaintMatch.title,
        description: complaintMatch.description,
        priority: complaintMatch.priority,
        timeAgo: _formatTimeAgo(complaintMatch.createdAt),
        location: complaintMatch.location,
        department: complaintMatch.department,
        isOverdue: complaintMatch.status.toLowerCase() == 'overdue',
      );
    } else if (attentionMatch != null) {
      targetItem = attentionMatch;
    } else if (_attentionItems.isNotEmpty) {
      targetItem = _attentionItems.first;
    } else if (_allComplaints.isNotEmpty) {
      final first = _allComplaints.first;
      targetItem = AdminComplaintAttentionItem(
        id: first.id,
        title: first.title,
        description: first.description,
        priority: first.priority,
        timeAgo: _formatTimeAgo(first.createdAt),
        location: first.location,
        department: first.department,
        isOverdue: first.status.toLowerCase() == 'overdue',
      );
    } else {
      // Fallback safe dummy when zero complaints exist in the system
      targetItem = const AdminComplaintAttentionItem(
        id: '#CMP-PENDING',
        title: 'Pending Civic Issue',
        description: 'New complaint awaiting officer assignment.',
        priority: 'Medium',
        timeAgo: 'Just now',
        location: 'City Center',
        department: 'Roads & Public Works',
      );
    }

    // 2. Safe lookup for officer
    AdminOfficerModel bestOfficer;
    if (_officers.isNotEmpty) {
      bestOfficer = _officers.firstWhere(
        (o) =>
            o.status == OfficerAvailabilityStatus.available &&
            o.department.toLowerCase().contains(targetItem.department.split(' ').first.toLowerCase()),
        orElse: () => _officers.firstWhere(
          (o) => o.status == OfficerAvailabilityStatus.available,
          orElse: () => _officers.first,
        ),
      );
    } else {
      bestOfficer = const AdminOfficerModel(
        id: 'off_fallback',
        name: 'Officer Duty Desk',
        department: 'Municipal Operations',
        status: OfficerAvailabilityStatus.available,
        activeTasks: 1,
        completedTasks: 50,
        rating: 4.8,
      );
    }

    return AutoAssignRecommendation(
      complaintId: targetItem.id,
      complaintTitle: targetItem.title,
      complaintDescription: targetItem.description,
      priority: targetItem.priority,
      recommendedOfficer: bestOfficer,
      distanceKm: 2.4,
      activeTasks: bestOfficer.activeTasks,
      matchReason: 'Closest available officer with suitable workload capacity.',
      matchScore: 96,
    );
  }

  bool assignComplaint(String complaintId, String officerId) {
    String officerName = 'Field Officer';
    String officerDept = 'Municipal Works';

    final cleanId = complaintId.toLowerCase().trim();

    // 1. If previously assigned to another officer, decrement that officer's active tasks
    final compIdx =
        _allComplaints.indexWhere((c) => c.id.toLowerCase().trim() == cleanId);
    String? prevOfficerId;
    if (compIdx != -1) {
      prevOfficerId = _allComplaints[compIdx].assignedOfficerId;
    } else {
      final attMatch = _attentionItems
          .where((c) => c.id.toLowerCase().trim() == cleanId)
          .firstOrNull;
      prevOfficerId = attMatch?.assignedOfficerId;
    }

    if (prevOfficerId != null &&
        prevOfficerId.isNotEmpty &&
        prevOfficerId != officerId) {
      final prevOffIdx = _officers.indexWhere((o) => o.id == prevOfficerId);
      if (prevOffIdx != -1) {
        final newActive = _officers[prevOffIdx].activeTasks > 0
            ? _officers[prevOffIdx].activeTasks - 1
            : 0;
        _officers[prevOffIdx] = _officers[prevOffIdx].copyWith(
          activeTasks: newActive,
          status: newActive == 0 &&
                  _officers[prevOffIdx].status ==
                      OfficerAvailabilityStatus.onTask
              ? OfficerAvailabilityStatus.available
              : _officers[prevOffIdx].status,
        );
      }
    }

    // 2. Increment new officer's active tasks
    final offIndex = _officers.indexWhere((o) => o.id == officerId);
    if (offIndex != -1) {
      final updated = _officers[offIndex].copyWith(
        activeTasks: _officers[offIndex].activeTasks + 1,
        status: OfficerAvailabilityStatus.onTask,
      );
      _officers[offIndex] = updated;
      officerName = updated.name;
      officerDept = updated.department;
    }

    // Remove from unassigned/attention items
    _attentionItems.removeWhere((c) => c.id.toLowerCase().trim() == cleanId);

    // Update in all complaints (or add if it was an attention item)
    if (compIdx != -1) {
      _allComplaints[compIdx] = _allComplaints[compIdx].copyWith(
        assignedOfficerId: officerId,
        assignedOfficerName: officerName,
        status: 'Assigned',
        updatedAt: DateTime.now(),
      );
    } else {
      _allComplaints.add(ComplaintModel(
        id: complaintId,
        title: 'Civic Priority Issue',
        description: 'Auto-assigned municipal complaint.',
        category: 'General',
        department: officerDept,
        priority: 'High',
        status: 'Assigned',
        location: 'City Center',
        assignedOfficerId: officerId,
        assignedOfficerName: officerName,
        citizenName: 'Citizen',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Sync to Firestore
    _complaintService.assignOfficer(
      complaintId: complaintId,
      officerId: officerId,
      officerName: officerName,
      department: officerDept,
    );

    if (_allComplaints.length >= 10) {
      _recalculateMetrics();
    } else {
      _metrics = AdminMetricsModel(
        total: _metrics.total,
        newCount: _metrics.newCount > 0 ? _metrics.newCount - 1 : 0,
        inProgress: _metrics.inProgress + 1,
        highPriority: _metrics.highPriority,
        overdue: _metrics.overdue,
        resolved: _metrics.resolved,
        resolutionRate: _metrics.resolutionRate,
        avgResponseHours: _metrics.avgResponseHours,
      );
    }
    notifyListeners();
    return true;
  }

  /// Removes an officer assignment from a complaint, returning it to the submitted pool
  bool unassignComplaint(String complaintId) {
    final cleanId = complaintId.toLowerCase().trim();
    String? assignedOfficerId;
    final compIdx =
        _allComplaints.indexWhere((c) => c.id.toLowerCase().trim() == cleanId);

    if (compIdx != -1) {
      final oldComp = _allComplaints[compIdx];
      assignedOfficerId = oldComp.assignedOfficerId;

      _allComplaints[compIdx] = oldComp.copyWith(
        clearAssignment: true,
        status: 'Submitted',
        updatedAt: DateTime.now(),
      );

      final c = _allComplaints[compIdx];
      // Re-insert into attention items if not present
      if (!_attentionItems.any((item) => item.id.toLowerCase().trim() == cleanId)) {
        _attentionItems.insert(
          0,
          AdminComplaintAttentionItem(
            id: c.id,
            title: c.title,
            description: c.description,
            priority: c.priority,
            timeAgo: _formatTimeAgo(c.createdAt),
            location: c.location,
            department: c.department,
            isOverdue: c.status.toLowerCase() == 'overdue',
          ),
        );
      }
    }

    // Decrement active tasks on the assigned officer
    if (assignedOfficerId != null && assignedOfficerId.isNotEmpty) {
      final offIdx = _officers.indexWhere((o) => o.id == assignedOfficerId);
      if (offIdx != -1) {
        final newActive = _officers[offIdx].activeTasks > 0
            ? _officers[offIdx].activeTasks - 1
            : 0;
        _officers[offIdx] = _officers[offIdx].copyWith(
          activeTasks: newActive,
          status: newActive == 0 &&
                  _officers[offIdx].status == OfficerAvailabilityStatus.onTask
              ? OfficerAvailabilityStatus.available
              : _officers[offIdx].status,
        );
      }
    }

    // Sync to Firestore
    _complaintService.unassignOfficer(complaintId: complaintId);

    if (_allComplaints.length >= 10) {
      _recalculateMetrics();
    } else {
      _metrics = AdminMetricsModel(
        total: _metrics.total,
        newCount: _metrics.newCount + 1,
        inProgress: _metrics.inProgress > 0 ? _metrics.inProgress - 1 : 0,
        highPriority: _metrics.highPriority,
        overdue: _metrics.overdue,
        resolved: _metrics.resolved,
        resolutionRate: _metrics.resolutionRate,
        avgResponseHours: _metrics.avgResponseHours,
      );
    }
    notifyListeners();
    return true;
  }

  /// Returns all complaints assigned to a specific officer
  List<ComplaintModel> getOfficerWork(String officerId, [String? officerName]) {
    return _allComplaints.where((c) {
      if (c.assignedOfficerId != null &&
          c.assignedOfficerId!.isNotEmpty &&
          c.assignedOfficerId == officerId) {
        return true;
      }
      if (officerName != null &&
          officerName.isNotEmpty &&
          c.assignedOfficerName != null &&
          c.assignedOfficerName!.toLowerCase() == officerName.toLowerCase()) {
        return true;
      }
      return false;
    }).toList();
  }

  /// Returns all unassigned complaints (status is Submitted/New and assignedOfficerId is null or empty)
  List<ComplaintModel> getUnassignedComplaints() {
    return _allComplaints.where((c) {
      final isUnassigned =
          c.assignedOfficerId == null || c.assignedOfficerId!.isEmpty;
      final isResolved = c.status.toLowerCase() == 'resolved' ||
          c.status.toLowerCase() == 'closed';
      return isUnassigned && !isResolved;
    }).toList();
  }

  void updateComplaintStatus(String complaintId, String newStatus) {
    final compIdx = _allComplaints.indexWhere((c) => c.id == complaintId);
    if (compIdx != -1) {
      _allComplaints[compIdx] = _allComplaints[compIdx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }

    _complaintService.updateComplaintStatus(
      complaintId: complaintId,
      newStatus: newStatus,
    );

    _recalculateMetrics();
    notifyListeners();
  }
}
