import 'package:flutter/material.dart';

enum OfficerAvailabilityStatus {
  available,
  onTask,
  offline;

  String get label {
    switch (this) {
      case OfficerAvailabilityStatus.available:
        return 'Available';
      case OfficerAvailabilityStatus.onTask:
        return 'On Task';
      case OfficerAvailabilityStatus.offline:
        return 'Offline';
    }
  }

  static OfficerAvailabilityStatus fromString(String val) {
    final lower = val.toLowerCase().replaceAll(' ', '');
    if (lower == 'ontask') return OfficerAvailabilityStatus.onTask;
    if (lower == 'offline') return OfficerAvailabilityStatus.offline;
    return OfficerAvailabilityStatus.available;
  }
}

class AdminOfficerModel {
  final String id;
  final String name;
  final String department;
  final OfficerAvailabilityStatus status;
  final int activeTasks;
  final int completedTasks;
  final String? avatarUrl;
  final double rating;

  const AdminOfficerModel({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
    required this.activeTasks,
    required this.completedTasks,
    this.avatarUrl,
    this.rating = 4.8,
  });

  AdminOfficerModel copyWith({
    String? name,
    String? department,
    OfficerAvailabilityStatus? status,
    int? activeTasks,
    int? completedTasks,
    String? avatarUrl,
    double? rating,
  }) {
    return AdminOfficerModel(
      id: id,
      name: name ?? this.name,
      department: department ?? this.department,
      status: status ?? this.status,
      activeTasks: activeTasks ?? this.activeTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
    );
  }
}

class DepartmentOversightModel {
  final String id;
  final String name;
  final IconData icon;
  final int activeComplaints;
  final int officerCount;
  final int capacityPercentage;
  final double avgResolutionDays;

  const DepartmentOversightModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.activeComplaints,
    required this.officerCount,
    required this.capacityPercentage,
    required this.avgResolutionDays,
  });
}

class AdminMetricsModel {
  final int total;
  final int newCount;
  final int inProgress;
  final int highPriority;
  final int overdue;
  final int resolved;
  final double resolutionRate;
  final double avgResponseHours;

  const AdminMetricsModel({
    this.total = 1248,
    this.newCount = 124,
    this.inProgress = 386,
    this.highPriority = 78,
    this.overdue = 34,
    this.resolved = 698,
    this.resolutionRate = 92.0,
    this.avgResponseHours = 1.2,
  });
}

class AdminComplaintAttentionItem {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String timeAgo;
  final String location;
  final String department;
  final String? assignedOfficerId;
  final bool isOverdue;

  const AdminComplaintAttentionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.timeAgo,
    required this.location,
    required this.department,
    this.assignedOfficerId,
    this.isOverdue = false,
  });
}

class AutoAssignRecommendation {
  final String complaintId;
  final String complaintTitle;
  final String complaintDescription;
  final String priority;
  final AdminOfficerModel recommendedOfficer;
  final double distanceKm;
  final int activeTasks;
  final String matchReason;
  final int matchScore;

  const AutoAssignRecommendation({
    required this.complaintId,
    required this.complaintTitle,
    required this.complaintDescription,
    required this.priority,
    required this.recommendedOfficer,
    required this.distanceKm,
    required this.activeTasks,
    required this.matchReason,
    this.matchScore = 96,
  });
}
