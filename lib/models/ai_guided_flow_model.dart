import 'package:flutter/material.dart';

enum GuidedStep {
  issue,
  photo,
  location,
  review,
}

class GuidedIssueOption {
  final String id;
  final String label;
  final String category;
  final String defaultDepartment;
  final IconData icon;
  final String defaultDescription;

  const GuidedIssueOption({
    required this.id,
    required this.label,
    required this.category,
    required this.defaultDepartment,
    required this.icon,
    required this.defaultDescription,
  });
}

class AiSessionHistoryItem {
  final String id;
  final String title;
  final String snippet;
  final DateTime timestamp;
  final String category;
  final String status;
  final IconData icon;
  final Color accentColor;
  final List<String> keyRecommendations;

  const AiSessionHistoryItem({
    required this.id,
    required this.title,
    required this.snippet,
    required this.timestamp,
    required this.category,
    required this.status,
    required this.icon,
    required this.accentColor,
    this.keyRecommendations = const [],
  });
}

enum SafetyAlertSeverity {
  urgent,
  warning,
  advisory,
}

class CivicSafetyAlertModel {
  final String id;
  final String title;
  final String description;
  final String issuedBy;
  final DateTime issuedAt;
  final SafetyAlertSeverity severity;
  final String area;
  final List<String> advisoryPoints;
  final String? helplineNumber;

  const CivicSafetyAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.issuedBy,
    required this.issuedAt,
    required this.severity,
    required this.area,
    required this.advisoryPoints,
    this.helplineNumber,
  });
}
