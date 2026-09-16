enum AiMessageRole {
  user,
  assistant,
  system,
}

class AiInsightCardData {
  final String title;
  final String category;
  final String department;
  final String severity;
  final int matchScore;
  final String? explanation;
  final String? complaintId;
  final String? status;
  final bool isTrackingCard;
  final List<String>? timelineSteps;
  final int currentStepIndex;

  const AiInsightCardData({
    required this.title,
    required this.category,
    required this.department,
    required this.severity,
    this.matchScore = 94,
    this.explanation,
    this.complaintId,
    this.status,
    this.isTrackingCard = false,
    this.timelineSteps,
    this.currentStepIndex = 2,
  });
}

class AiMessage {
  final String id;
  final String text;
  final AiMessageRole role;
  final DateTime timestamp;
  final String? imageAttachment;
  final AiInsightCardData? insightCard;
  final List<String>? quickActions;

  const AiMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.imageAttachment,
    this.insightCard,
    this.quickActions,
  });

  bool get isUser => role == AiMessageRole.user;
  bool get isAssistant => role == AiMessageRole.assistant;
}

class AiImageAnalysisResult {
  final String issueName;
  final String category;
  final String department;
  final String severity;
  final int confidenceScore;
  final String explanation;
  final String location;
  final DateTime timestamp;
  final String imageAsset;

  const AiImageAnalysisResult({
    required this.issueName,
    required this.category,
    required this.department,
    required this.severity,
    required this.confidenceScore,
    required this.explanation,
    required this.location,
    required this.timestamp,
    required this.imageAsset,
  });
}
