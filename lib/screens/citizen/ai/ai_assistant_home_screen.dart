import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/ai_assistant_provider.dart';
import '../../../providers/auth_provider.dart';

class AiAssistantHomeScreen extends StatefulWidget {
  const AiAssistantHomeScreen({super.key});

  @override
  State<AiAssistantHomeScreen> createState() => _AiAssistantHomeScreenState();
}

class _AiAssistantHomeScreenState extends State<AiAssistantHomeScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _submitPrompt(String query) {
    if (query.trim().isEmpty) return;
    final aiProvider = context.read<AiAssistantProvider>();
    aiProvider.sendMessage(query.trim());
    _promptController.clear();
    Navigator.pushNamed(context, AppRoutes.aiChat);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final aiProvider = context.watch<AiAssistantProvider>();
    final userName = authProvider.currentUser?.name ?? 'Alex Citizen';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          tooltip: 'Menu',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Civic Assistant Menu & Shortcuts'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.aiSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.aiBorder),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.aiAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CitizenConnect AI',
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.onSurfaceVariant),
            tooltip: 'Conversation History',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.aiConversationHistory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.aiAccent),
            tooltip: 'Voice Assistant',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.aiVoiceAssistant);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resident Greeting Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withAlpha(70)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryFixed,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Verified Resident • AI Assistant Ready',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                color: AppColors.aiAccent),
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.aiChat);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Civic Safety Advisory Banner
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.civicSafetyAlerts);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDBA74)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Municipal Advisory: Monsoon Alert',
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9A3412),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Ward 7 drainage flash flood advisory & 24x7 emergency helplines.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFFC2410C),
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFEA580C), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // AI Guided Complaint Wizard Hero Card
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.aiGuidedComplaint);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF005AC1), Color(0xFF007DF0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF005AC1).withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(45),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assistant_direction_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'AI Guided Complaint',
                                        style: AppTypography.labelLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00C49F),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '4 STEPS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Visual triage, photo CV analysis, GPS location lock, and 1-tap submission.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withAlpha(230),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Welcome Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.aiSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.aiBorder, width: 1.2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.aiContainer.withAlpha(120),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.aiBorder),
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: AppColors.aiDarkText,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi! I'm your Civic Assistant 👋",
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.aiDarkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'I can help you report civic issues, track complaints, analyze damaged road photos, and discover government services. How can I assist you today?',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Suggested Questions Section
                    Text(
                      'Suggested Questions',
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: aiProvider.suggestions.map((query) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              backgroundColor: AppColors.surfaceContainerLowest,
                              side: BorderSide(
                                color: AppColors.outlineVariant.withAlpha(100),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              label: Text(
                                query,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              onPressed: () => _submitPrompt(query),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bento Grid: "How can I help?"
                    Text(
                      'How can I help?',
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Civic AI Modules & Services',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Card 1: Report an Issue
                        _buildBentoTile(
                          icon: Icons.edit_document,
                          iconBg: AppColors.primaryFixed,
                          iconColor: AppColors.primary,
                          title: 'Report an Issue',
                          description: 'Create a civic complaint with AI auto-categorization.',
                          onTap: () {
                            _submitPrompt('I want to report a civic issue');
                          },
                        ),
                        // Card 2: Track My Complaint
                        _buildBentoTile(
                          icon: Icons.track_changes_rounded,
                          iconBg: AppColors.tertiaryFixed,
                          iconColor: AppColors.tertiary,
                          title: 'Track My Complaint',
                          description: 'Instant timeline updates on active civic cases.',
                          onTap: () {
                            _submitPrompt('Track my complaint status');
                          },
                        ),
                        // Card 3: Analyze an Image (Only this has AI Enhanced tag to satisfy Phase 6 test)
                        _buildBentoTile(
                          icon: Icons.photo_camera_rounded,
                          iconBg: AppColors.aiSurface,
                          iconColor: AppColors.aiAccent,
                          title: 'Analyze an Image',
                          description: 'Upload damage photo to identify severity & department.',
                          isAiEnhanced: true,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.aiImageAnalysis);
                          },
                        ),
                        // Card 4: Government Services
                        _buildBentoTile(
                          icon: Icons.account_balance_rounded,
                          iconBg: AppColors.surfaceContainerHigh,
                          iconColor: AppColors.onSurfaceVariant,
                          title: 'Government Services',
                          description: 'Discover municipal schemes, certificates, & policies.',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.governmentServices);
                          },
                        ),
                        // Card 5: Document Guidance (Phase 9)
                        _buildBentoTile(
                          icon: Icons.document_scanner_rounded,
                          iconBg: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0369A1),
                          title: 'Document Checklist',
                          description: 'Smart certificate checklist & OCR readiness.',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.aiDocumentGuidance);
                          },
                        ),
                        // Card 6: Civic Safety & Helplines (Phase 9)
                        _buildBentoTile(
                          icon: Icons.health_and_safety_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Safety & Weather',
                          description: 'Municipal alerts and 24x7 emergency contacts.',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.civicSafetyAlerts);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Prompt Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withAlpha(80),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Camera shortcut
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: AppColors.aiAccent),
                    tooltip: 'Analyze Image',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.aiImageAnalysis);
                    },
                  ),
                  // Mic shortcut
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: AppColors.aiAccent),
                    tooltip: 'Voice Assistant',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.aiVoiceAssistant);
                    },
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Ask anything or describe issue...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _submitPrompt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.aiAccent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      tooltip: 'Send',
                      onPressed: () => _submitPrompt(_promptController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isAiEnhanced = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isAiEnhanced
                ? AppColors.aiAccent.withAlpha(160)
                : AppColors.outlineVariant.withAlpha(80),
            width: isAiEnhanced ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isAiEnhanced)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.aiAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'AI Enhanced',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
