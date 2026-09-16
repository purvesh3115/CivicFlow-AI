import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_guided_flow_model.dart';
import '../models/ai_message_model.dart';
import '../navigation/app_routes.dart';
import 'complaint_provider.dart';

class AiAssistantProvider extends ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isThinking = false;
  bool _isVoiceListening = false;
  String _voiceTranscript = 'There is garbage near my house.';
  AiImageAnalysisResult? _currentImageAnalysis;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isThinking => _isThinking;
  bool get isVoiceListening => _isVoiceListening;
  String get voiceTranscript => _voiceTranscript;
  AiImageAnalysisResult? get currentImageAnalysis => _currentImageAnalysis;

  final List<String> suggestions = const [
    'How do I report a pothole?',
    'Where is my complaint?',
    'Which department handles garbage?',
    'What government benefits are available?',
    'What documents do I need?',
  ];

  AiAssistantProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    if (_messages.isNotEmpty) return;
    _messages.add(
      AiMessage(
        id: 'msg-init',
        text:
            'Hello! How can I help you today? You can describe a civic issue, track your complaints, or discover government services.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        quickActions: [
          'Report an issue',
          'Track my complaint',
          'Analyze an image',
        ],
      ),
    );
  }

  Future<void> sendMessage(String text, {String? imageAttachment}) async {
    final clean = text.trim();
    if (clean.isEmpty && imageAttachment == null) return;

    final userMsgId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      AiMessage(
        id: userMsgId,
        text: clean,
        role: AiMessageRole.user,
        timestamp: DateTime.now(),
        imageAttachment: imageAttachment,
      ),
    );
    _isThinking = true;
    notifyListeners();

    // Simulate AI reasoning and natural language processing
    await Future.delayed(const Duration(milliseconds: 400));

    final lower = clean.toLowerCase();
    AiMessage response;

    if (lower.contains('pothole') || lower.contains('road') || lower.contains('crater')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'I can help you report this issue. Based on your description, it appears to be a road infrastructure problem.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        insightCard: const AiInsightCardData(
          title: 'Pothole',
          category: 'Roads',
          department: 'Roads & Public Works',
          severity: 'High',
          matchScore: 94,
          explanation:
              'Significant asphalt deformation detected that may pose safety hazards to motorists.',
        ),
      );
    } else if (lower.contains('garbage') ||
        lower.contains('trash') ||
        lower.contains('waste') ||
        lower.contains('dump')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'I have identified an issue related to sanitation and waste management.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        insightCard: const AiInsightCardData(
          title: 'Overflowing Garbage Dump',
          category: 'Garbage',
          department: 'Solid Waste Management',
          severity: 'High',
          matchScore: 96,
          explanation:
              'Uncollected municipal garbage bins causing public hygiene concerns in residential area.',
        ),
      );
    } else if (lower.contains('light') ||
        lower.contains('dark') ||
        lower.contains('lamp') ||
        lower.contains('street light')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'This issue falls under urban electrical lighting maintenance.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        insightCard: const AiInsightCardData(
          title: 'Non-Functional Streetlight',
          category: 'Street Lights',
          department: 'Electrical & Lighting Dept',
          severity: 'Medium',
          matchScore: 91,
          explanation:
              'Street lamp out of order leading to reduced visibility at night.',
        ),
      );
    } else if (lower.contains('water') ||
        lower.contains('leak') ||
        lower.contains('pipe')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'Detected a municipal water supply anomaly requiring prompt municipal response.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        insightCard: const AiInsightCardData(
          title: 'Pressurized Pipeline Leak',
          category: 'Water',
          department: 'Water Supply & Sewerage',
          severity: 'High',
          matchScore: 95,
          explanation:
              'Potable pipeline breach causing water loss and localized puddling on public road.',
        ),
      );
    } else if (lower.contains('track') ||
        lower.contains('where is my') ||
        lower.contains('status')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: 'Here are your active complaints and current timeline progress.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        insightCard: const AiInsightCardData(
          title: 'Pothole near University Road',
          category: 'Roads & Infrastructure',
          department: 'Roads & Public Works',
          severity: 'High',
          complaintId: '#CC-2026-00125',
          status: 'In Progress',
          isTrackingCard: true,
          timelineSteps: [
            'Submitted',
            'Assigned',
            'In Progress',
            'Resolution',
            'Verification'
          ],
          currentStepIndex: 2,
        ),
      );
    } else if (lower.contains('benefit') ||
        lower.contains('scheme') ||
        lower.contains('service') ||
        lower.contains('document')) {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'You have access to 24+ municipal schemes and verified certificates including Residential Water Connection, Trade License Renewal, and Property Tax Rebates.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        quickActions: [
          'View Government Services',
          'Check Scheme Eligibility',
          'Open Document Vault',
        ],
      );
    } else {
      response = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'I understand you need assistance with civic management. You can tell me the details of any issue (like roads, sanitation, water, or streetlights) and I will automatically match the department, assess severity, and assist in reporting.',
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
        quickActions: [
          'Report a pothole',
          'Report garbage',
          'Track my complaint',
        ],
      );
    }

    _messages.add(response);
    _isThinking = false;
    notifyListeners();
  }

  void toggleVoiceListening({bool? forceState}) {
    _isVoiceListening = forceState ?? !_isVoiceListening;
    notifyListeners();
  }

  void setVoiceTranscript(String text) {
    _voiceTranscript = text;
    notifyListeners();
  }

  AiImageAnalysisResult runImageAnalysis(
      {String? customImage, bool notify = true}) {
    final result = AiImageAnalysisResult(
      issueName: 'Pothole',
      category: 'Road Infrastructure',
      department: 'Roads & Public Works',
      severity: 'High',
      confidenceScore: 94,
      explanation:
          'Significant road surface damage was detected. The depth and width of the anomaly suggest a moderate to severe pothole, which may create a safety risk for vehicles and cyclists. Immediate assessment recommended.',
      location: '124 Main St, Cityville',
      timestamp: DateTime.now(),
      imageAsset: customImage ?? 'assets/images/sample_pothole.jpg',
    );
    _currentImageAnalysis = result;
    if (notify) {
      notifyListeners();
    }
    return result;
  }

  void prefillComplaintAndNavigate(
    BuildContext context, {
    required String category,
    required String title,
    required String description,
    String priority = 'High',
    String? attachment,
  }) {
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);

    // Set draft data in ComplaintProvider
    complaintProvider.setDraftCategory(category);
    complaintProvider.setDraftDetails(
      title: title,
      description: description,
      priority: priority,
      location: '124 Main St, Anand, Gujarat',
    );
    if (attachment != null) {
      complaintProvider.addDraftAttachment(attachment);
    }

    // Push into Phase 3 form
    Navigator.pushNamed(context, AppRoutes.complaintDetails);
  }

  void applyPreFilledComplaint(ComplaintProvider complaintProvider) {
    final latestWithCard = _messages.lastWhere(
      (m) => m.insightCard != null,
      orElse: () => _messages.first,
    );
    final card = latestWithCard.insightCard;
    if (card != null) {
      String cat = 'General';
      if (card.category.toLowerCase().contains('road')) {
        cat = 'Roads';
      } else if (card.category.toLowerCase().contains('sanitation') ||
          card.category.toLowerCase().contains('garbage')) {
        cat = 'Garbage';
      } else if (card.category.toLowerCase().contains('water')) {
        cat = 'Water';
      }
      complaintProvider.setDraftCategory(cat);
      complaintProvider.setDraftDetails(
        title: card.title,
        description: card.explanation ?? card.title,
        priority: card.severity,
        location: '124 Main St, Anand, Gujarat',
      );
    }
  }

  void clearHistory() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }

  // ==========================================
  // PHASE 9: CONVERSATIONAL AI GUIDED COMPLAINT FLOW
  // ==========================================

  GuidedStep _guidedStep = GuidedStep.issue;
  GuidedIssueOption? _selectedGuidedIssue;
  String? _guidedPhotoUrl;
  String _guidedLocation = 'Near Anand Railway Station, Station Rd, Anand';
  double _guidedLatitude = 22.5645;
  double _guidedLongitude = 72.9289;
  String _guidedDescription = '';
  bool _isAnalyzingPhoto = false;

  GuidedStep get guidedStep => _guidedStep;
  GuidedIssueOption? get selectedGuidedIssue => _selectedGuidedIssue;
  String? get guidedPhotoUrl => _guidedPhotoUrl;
  String get guidedLocation => _guidedLocation;
  double get guidedLatitude => _guidedLatitude;
  double get guidedLongitude => _guidedLongitude;
  String get guidedDescription => _guidedDescription;
  bool get isAnalyzingPhoto => _isAnalyzingPhoto;

  final List<GuidedIssueOption> guidedIssueOptions = const [
    GuidedIssueOption(
      id: 'pothole',
      label: 'Pothole',
      category: 'Roads',
      defaultDepartment: 'Roads & Public Infrastructure',
      icon: Icons.terrain_rounded,
      defaultDescription: 'Deep road crater causing vehicle damage and traffic bottleneck.',
    ),
    GuidedIssueOption(
      id: 'garbage',
      label: 'Garbage Dump',
      category: 'Garbage',
      defaultDepartment: 'Sanitation & Solid Waste',
      icon: Icons.delete_outline_rounded,
      defaultDescription: 'Overflowing public waste bin creating unsanitary odors.',
    ),
    GuidedIssueOption(
      id: 'water_leak',
      label: 'Water Leakage',
      category: 'Water',
      defaultDepartment: 'Water Supply & Sewerage Board',
      icon: Icons.water_drop_outlined,
      defaultDescription: 'Sub-surface pipe fracture causing water loss and pooling.',
    ),
    GuidedIssueOption(
      id: 'streetlight',
      label: 'Street Light',
      category: 'Street Lights',
      defaultDepartment: 'Electricity & Public Lighting',
      icon: Icons.lightbulb_outline_rounded,
      defaultDescription: 'Overhead light pole extinguished, creating darkness on pedestrian street.',
    ),
    GuidedIssueOption(
      id: 'broken_manhole',
      label: 'Open Manhole',
      category: 'Roads',
      defaultDepartment: 'Drainage & Stormwater Network',
      icon: Icons.dangerous_outlined,
      defaultDescription: 'Hazardous exposed sewer opening on roadside.',
    ),
    GuidedIssueOption(
      id: 'fallen_tree',
      label: 'Fallen Tree',
      category: 'General',
      defaultDepartment: 'Parks & Garden Department',
      icon: Icons.park_outlined,
      defaultDescription: 'Large tree branch obstructing vehicular pathway.',
    ),
  ];

  void setGuidedStep(GuidedStep step) {
    _guidedStep = step;
    notifyListeners();
  }

  void selectGuidedIssue(GuidedIssueOption issue) {
    _selectedGuidedIssue = issue;
    if (_guidedDescription.isEmpty) {
      _guidedDescription = issue.defaultDescription;
    }
    _guidedStep = GuidedStep.photo;
    notifyListeners();
  }

  Future<void> attachGuidedPhoto(String photoUrl) async {
    _isAnalyzingPhoto = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _guidedPhotoUrl = photoUrl;
    _isAnalyzingPhoto = false;
    _guidedStep = GuidedStep.location;
    notifyListeners();
  }

  void setGuidedLocation(String loc, {double? lat, double? lng}) {
    _guidedLocation = loc;
    if (lat != null) _guidedLatitude = lat;
    if (lng != null) _guidedLongitude = lng;
    notifyListeners();
  }

  void setGuidedDescription(String desc) {
    _guidedDescription = desc;
    notifyListeners();
  }

  void resetGuidedFlow() {
    _guidedStep = GuidedStep.issue;
    _selectedGuidedIssue = null;
    _guidedPhotoUrl = null;
    _guidedDescription = '';
    _guidedLocation = 'Near Anand Railway Station, Station Rd, Anand';
    _isAnalyzingPhoto = false;
    notifyListeners();
  }

  // ==========================================
  // PHASE 9: AI CONVERSATION HISTORY SESSIONS
  // ==========================================

  final List<AiSessionHistoryItem> _sessionHistory = [
    AiSessionHistoryItem(
      id: 'sess-01',
      title: 'Road Pothole Triage & Severity Check',
      snippet: 'AI analyzed photo of 15cm pothole on MG Road. Recommended Roads & Infrastructure.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'Grievances',
      status: 'Complaint Filed',
      icon: Icons.alt_route_rounded,
      accentColor: const Color(0xFF004AC6),
      keyRecommendations: [
        'Classified as High Priority',
        'Assigned to Roads & Public Works',
        'Estimated SLA: 24-48 hours',
      ],
    ),
    AiSessionHistoryItem(
      id: 'sess-02',
      title: 'Universal Healthcare Eligibility Quiz',
      snippet: 'Evaluated municipal criteria for Universal Health Scheme. 92% match score.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Services',
      status: 'Eligible',
      icon: Icons.health_and_safety_rounded,
      accentColor: const Color(0xFF006A63),
      keyRecommendations: [
        'Aadhaar verified',
        'Income threshold met (< ₹3,00,000)',
        'Next step: Upload residency proof',
      ],
    ),
    AiSessionHistoryItem(
      id: 'sess-03',
      title: 'Water Pipe Burst Voice Inquiry',
      snippet: 'Transcribed voice note regarding sub-surface pipe leak in Sector 4.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Triage',
      status: 'Resolved',
      icon: Icons.record_voice_over_rounded,
      accentColor: const Color(0xFF2563EB),
      keyRecommendations: [
        'Speech audio transcribed',
        'Emergency water crew alerted',
      ],
    ),
    AiSessionHistoryItem(
      id: 'sess-04',
      title: 'Trade License Renewal Document Checklist',
      snippet: 'Verified required documents: Property Tax Receipt and Fire NOC.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      category: 'Documents',
      status: 'Checklist Ready',
      icon: Icons.description_rounded,
      accentColor: const Color(0xFFB45309),
      keyRecommendations: [
        'All 4 documents ready for submission',
        'Fee payable: ₹500',
      ],
    ),
  ];

  List<AiSessionHistoryItem> get sessionHistory => List.unmodifiable(_sessionHistory);

  void addSessionHistory(AiSessionHistoryItem item) {
    _sessionHistory.insert(0, item);
    notifyListeners();
  }

  // ==========================================
  // PHASE 9: CIVIC SAFETY NOTICES & WEATHER ALERTS
  // ==========================================

  final List<CivicSafetyAlertModel> _safetyAlerts = [
    CivicSafetyAlertModel(
      id: 'alert-01',
      title: 'Heavy Monsoon Flash Flood Advisory',
      description:
          'Indian Meteorological Department issued an Orange Alert. Heavy rains expected across Anand & Vadodara districts over the next 36 hours. Avoid low-lying underpasses.',
      issuedBy: 'Gujarat State Disaster Management Authority (GSDMA)',
      issuedAt: DateTime.now().subtract(const Duration(hours: 1)),
      severity: SafetyAlertSeverity.urgent,
      area: 'Anand Municipal Corporation & Surrounding Wards',
      advisoryPoints: [
        'Stay indoors during peak rainfall between 2:00 PM and 7:00 PM.',
        'Avoid commuting through Jagnath Underpass and University Station Road.',
        'Report clogged storm drains or waterlogging immediately via CitizenConnect.',
      ],
      helplineNumber: '1077',
    ),
    CivicSafetyAlertModel(
      id: 'alert-02',
      title: 'Road Resurfacing & Traffic Diversion on Station Road',
      description:
          'Major asphalt resurfacing work underway between Anand Railway Station and Town Hall. Traffic diverted via Amul Dairy Road.',
      issuedBy: 'Municipal Traffic Engineering Wing',
      issuedAt: DateTime.now().subtract(const Duration(hours: 5)),
      severity: SafetyAlertSeverity.warning,
      area: 'Station Road to Town Hall Circle',
      advisoryPoints: [
        'Single-lane operation from 8:00 AM to 6:00 PM.',
        'Heavy commercial vehicles strictly restricted until 9:00 PM.',
        'Follow digital signage and ward marshal instructions.',
      ],
      helplineNumber: '1913',
    ),
    CivicSafetyAlertModel(
      id: 'alert-03',
      title: 'Scheduled Water Supply Pressure Regulation',
      description:
          'Routine pipeline maintenance and valve replacement in Sector 4 water distribution grid. Water supply will operate at low pressure between 1:00 PM and 5:00 PM.',
      issuedBy: 'Water Supply & Sewerage Board',
      issuedAt: DateTime.now().subtract(const Duration(days: 1)),
      severity: SafetyAlertSeverity.advisory,
      area: 'Sector 4, 5, and Vidyanagar Extensions',
      advisoryPoints: [
        'Store sufficient potable water for afternoon usage.',
        'Normal full-pressure supply resumes at 6:00 PM.',
      ],
      helplineNumber: '02692-245600',
    ),
  ];

  List<CivicSafetyAlertModel> get safetyAlerts => List.unmodifiable(_safetyAlerts);
}
