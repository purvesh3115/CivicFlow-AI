import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai_guided_flow_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/ai_assistant_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';

class AiGuidedComplaintScreen extends StatefulWidget {
  const AiGuidedComplaintScreen({super.key});

  @override
  State<AiGuidedComplaintScreen> createState() => _AiGuidedComplaintScreenState();
}

class _AiGuidedComplaintScreenState extends State<AiGuidedComplaintScreen> {
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ai = context.read<AiAssistantProvider>();
      _landmarkController.text = ai.guidedLocation;
      if (ai.guidedDescription.isNotEmpty) {
        _descController.text = ai.guidedDescription;
      }
    });
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSelectIssue(GuidedIssueOption issue) {
    final ai = context.read<AiAssistantProvider>();
    ai.selectGuidedIssue(issue);
    _descController.text = issue.defaultDescription;
  }

  void _onAttachPhoto(String url) {
    context.read<AiAssistantProvider>().attachGuidedPhoto(url);
  }

  void _onSubmit() async {
    final ai = context.read<AiAssistantProvider>();
    final complaintProvider = context.read<ComplaintProvider>();
    final authUser = context.read<AuthProvider>().currentUser;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final issue = ai.selectedGuidedIssue;
    final category = issue?.category ?? 'General';
    final title = '${issue?.label ?? "Civic Grievance"} - AI Reported';
    final desc = _descController.text.trim().isNotEmpty
        ? _descController.text.trim()
        : (issue?.defaultDescription ?? 'Issue reported via AI Guided Assistant.');
    final location = _landmarkController.text.trim().isNotEmpty
        ? _landmarkController.text.trim()
        : ai.guidedLocation;

    complaintProvider.setDraftCategory(category);
    complaintProvider.setDraftDetails(
      title: title,
      description: desc,
      priority: 'High',
      location: location,
      latitude: ai.guidedLatitude,
      longitude: ai.guidedLongitude,
    );
    final photoUrl = ai.guidedPhotoUrl ??
        'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=600';
    complaintProvider.addDraftAttachment(photoUrl);

    final submitted = complaintProvider.submitComplaint(
      citizenName: authUser?.name ?? 'Purvesh Patel',
    );

    // Save to AI Session History
    ai.addSessionHistory(
      AiSessionHistoryItem(
        id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
        title: '$title (${submitted.id})',
        snippet: desc,
        timestamp: DateTime.now(),
        category: 'Grievances',
        status: 'Complaint Filed',
        icon: issue?.icon ?? Icons.auto_awesome_rounded,
        accentColor: AppColors.primary,
        keyRecommendations: [
          'Filed as ${submitted.id}',
          'Priority: High',
          'Assigned Department: ${issue?.defaultDepartment ?? "Municipal Works"}',
        ],
      ),
    );

    ai.resetGuidedFlow();
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.complaintSuccess,
      (route) => route.isFirst,
      arguments: submitted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiAssistantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (ai.guidedStep != GuidedStep.issue) {
              if (ai.guidedStep == GuidedStep.photo) {
                ai.setGuidedStep(GuidedStep.issue);
              } else if (ai.guidedStep == GuidedStep.location) {
                ai.setGuidedStep(GuidedStep.photo);
              } else if (ai.guidedStep == GuidedStep.review) {
                ai.setGuidedStep(GuidedStep.location);
              }
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFF006A63),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CitizenConnect AI',
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Session History',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.aiConversationHistory),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildProgressStepper(ai.guidedStep),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Chat Greeting Bubble
              _buildAiChatBubble(
                title: _getStepTitle(ai.guidedStep),
                message: _getStepPrompt(ai.guidedStep),
              ),
              const SizedBox(height: 20),

              // Step Content Switcher
              if (ai.guidedStep == GuidedStep.issue) ...[
                _buildIssueSelector(ai),
              ] else if (ai.guidedStep == GuidedStep.photo) ...[
                _buildPhotoStep(ai),
              ] else if (ai.guidedStep == GuidedStep.location) ...[
                _buildLocationStep(ai),
              ] else if (ai.guidedStep == GuidedStep.review) ...[
                _buildReviewStep(ai),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper(GuidedStep step) {
    final steps = [
      {'label': 'Issue', 'step': GuidedStep.issue, 'num': '1'},
      {'label': 'Photo', 'step': GuidedStep.photo, 'num': '2'},
      {'label': 'Location', 'step': GuidedStep.location, 'num': '3'},
      {'label': 'Review', 'step': GuidedStep.review, 'num': '4'},
    ];

    int activeIdx = step.index;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isPast = idx < activeIdx;
          final isActive = idx == activeIdx;

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primary
                          : isPast
                              ? const Color(0xFF006A63)
                              : const Color(0xFFE2E8F0),
                    ),
                    child: Center(
                      child: isPast
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              item['num'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (idx < steps.length - 1)
                Container(
                  width: 38,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  color: isPast ? const Color(0xFF006A63) : const Color(0xFFE2E8F0),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAiChatBubble({required String title, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.zero,
        ),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A63).withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Color(0xFF006A63),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(GuidedStep step) {
    switch (step) {
      case GuidedStep.issue:
        return 'Step 1: Identify Civic Issue';
      case GuidedStep.photo:
        return 'Step 2: Evidence & Computer Vision';
      case GuidedStep.location:
        return 'Step 3: Pinpoint Location';
      case GuidedStep.review:
        return 'Step 4: AI Summary & Confirmation';
    }
  }

  String _getStepPrompt(GuidedStep step) {
    switch (step) {
      case GuidedStep.issue:
        return 'What type of public issue would you like to report? Select from the municipal category options below:';
      case GuidedStep.photo:
        return 'Please attach a photo of the issue. Our multimodal computer vision model will evaluate damage severity automatically.';
      case GuidedStep.location:
        return 'GPS coordinates have been locked. Confirm the location address or add landmark details to help field officers locate it quickly.';
      case GuidedStep.review:
        return 'Here is the summary of your report. Tap "Submit Complaint" to dispatch this directly to field operations.';
    }
  }

  // --- Step 1: Issue Grid ---
  Widget _buildIssueSelector(AiAssistantProvider ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Issue Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ai.guidedIssueOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final option = ai.guidedIssueOptions[index];
            final isSelected = ai.selectedGuidedIssue?.id == option.id;

            return InkWell(
              onTap: () => _onSelectIssue(option),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.icon,
                      size: 32,
                      color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Step 2: Photo Step ---
  Widget _buildPhotoStep(AiAssistantProvider ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ai.isAnalyzingPhoto) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: const Column(
              children: [
                CircularProgressIndicator(color: Color(0xFF006A63)),
                SizedBox(height: 16),
                Text(
                  'Computer Vision Analyzing Damage...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Extracting severity index, surface area, and hazard metrics',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ] else ...[
          // Photo Options
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_a_photo_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Capture or Upload Incident Evidence',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a preset feed or simulate camera capture below:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        key: const Key('ai_capture_photo_btn'),
                        onPressed: () => _onAttachPhoto(
                          'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=600',
                        ),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Snap Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('ai_gallery_photo_btn'),
                        onPressed: () => _onAttachPhoto(
                          'https://images.unsplash.com/photo-1584467735815-f778f274e296?w=600',
                        ),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: const Text('Pick Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF006A63),
                          side: const BorderSide(color: Color(0xFF006A63)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Description Box
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional Notes / Voice Transcript',
              hintText: 'e.g. Near main crossroad, causing traffic delay...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Step 3: Location Step ---
  Widget _buildLocationStep(AiAssistantProvider ai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.gps_fixed_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS Location Verified',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Coordinates: 22.5645° N, 72.9289° E • Accuracy ±3m',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _landmarkController,
                decoration: InputDecoration(
                  labelText: 'Location & Landmark Address',
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('ai_confirm_location_btn'),
                  onPressed: () {
                    ai.setGuidedLocation(_landmarkController.text.trim());
                    ai.setGuidedStep(GuidedStep.review);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm Location & Review Report',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 4: Review Step ---
  Widget _buildReviewStep(AiAssistantProvider ai) {
    final issue = ai.selectedGuidedIssue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    issue?.label ?? 'Civic Grievance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'HIGH PRIORITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBA1A1A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Department: ${issue?.defaultDepartment ?? "Roads & Public Infrastructure"}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _descController.text.isNotEmpty
                    ? _descController.text
                    : (issue?.defaultDescription ?? 'Civic report filed through AI Assistant.'),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text(
                'Location',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _landmarkController.text.isNotEmpty
                    ? _landmarkController.text
                    : ai.guidedLocation,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              // AI Confidence Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 18, color: Color(0xFF006A63)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Confidence: 94.8% • Pre-screened for immediate dispatch',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  key: const Key('ai_guided_submit_btn'),
                  onPressed: _isSubmitting ? null : _onSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isSubmitting ? 'DISPATCHING TO FIELD...' : 'CONFIRM & SUBMIT COMPLAINT',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
