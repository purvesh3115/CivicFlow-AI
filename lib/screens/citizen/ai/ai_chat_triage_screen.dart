import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai_message_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/ai_assistant_provider.dart';

class AiChatTriageScreen extends StatefulWidget {
  const AiChatTriageScreen({super.key});

  @override
  State<AiChatTriageScreen> createState() => _AiChatTriageScreenState();
}

class _AiChatTriageScreenState extends State<AiChatTriageScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? preset]) {
    final query = preset ?? _textController.text;
    if (query.trim().isEmpty) return;

    final provider = context.read<AiAssistantProvider>();
    provider.sendMessage(query.trim());
    if (preset == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiAssistantProvider>();
    final messages = aiProvider.messages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'CitizenConnect AI',
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.aiAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'AI Civic Assistant Online',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.aiAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.aiAccent),
            tooltip: 'Voice Assistant',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.aiVoiceAssistant);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.onSurfaceVariant),
            tooltip: 'Reset Chat',
            onPressed: () {
              aiProvider.clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation reset to initial state.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat message stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length + (aiProvider.isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && aiProvider.isThinking) {
                    return _buildThinkingBubble();
                  }
                  final msg = messages[index];
                  return _buildMessageRow(msg);
                },
              ),
            ),

            // Suggestion chips horizontal bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildQuickChip('Report a pothole',
                        () => _handleSend('There is a large pothole near my college.')),
                    _buildQuickChip('Overflowing garbage',
                        () => _handleSend('Garbage is piling up on Main Street.')),
                    _buildQuickChip('Broken streetlight',
                        () => _handleSend('The streetlight in our block is broken.')),
                    _buildQuickChip('Track complaint',
                        () => _handleSend('Track my complaint status.')),
                    _buildQuickChip('Government services',
                        () => _handleSend('What government benefits are available?')),
                  ],
                ),
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withAlpha(80),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image picker / Camera button
                  IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.onSurfaceVariant),
                    tooltip: 'AI Image Analysis',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.aiImageAnalysis);
                    },
                  ),
                  // Text Area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(60),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 4,
                        minLines: 1,
                        style: AppTypography.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'Ask anything...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Mic button
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded,
                        color: AppColors.onSurfaceVariant),
                    tooltip: 'Voice Input',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.aiVoiceAssistant);
                    },
                  ),
                  // Send button
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: AppColors.aiAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      tooltip: 'Send Message',
                      onPressed: () => _handleSend(),
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

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        side: BorderSide(color: AppColors.outlineVariant.withAlpha(90)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMessageRow(AiMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF475569), // Slate-600
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.zero,
            ),
          ),
          child: Text(
            msg.text,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    // AI Assistant Response
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Bubble
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.aiSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.zero,
                ),
                border: Border.all(color: AppColors.aiBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.only(top: 2, right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.aiAccent,
                      size: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      msg.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.aiDarkText,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Embedded Insight Card (if present)
            if (msg.insightCard != null) ...[
              const SizedBox(height: 8),
              if (msg.insightCard!.isTrackingCard)
                _buildTrackingCard(msg.insightCard!)
              else
                _buildTriageCard(msg.insightCard!),
            ],

            // Quick action chips (if any)
            if (msg.quickActions != null && msg.quickActions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.quickActions!.map((act) {
                  return ActionChip(
                    label: Text(
                      act,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.aiAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.aiSurface,
                    side: const BorderSide(color: AppColors.aiBorder),
                    onPressed: () {
                      if (act.toLowerCase().contains('service')) {
                        Navigator.pushNamed(context, AppRoutes.governmentServices);
                      } else {
                        _handleSend(act);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTriageCard(AiInsightCardData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teal Top Border
          Container(height: 3, color: AppColors.aiAccent),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: "Recommended for you" + Confidence
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECOMMENDED FOR YOU',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.aiSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.aiBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.aiAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${data.matchScore}% Match',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.aiAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Data 2-Column Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Possible Issue',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              )),
                          const SizedBox(height: 2),
                          Text(data.title,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              )),
                          const SizedBox(height: 2),
                          Text(data.category,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Department
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Department',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        )),
                    const SizedBox(height: 2),
                    Text(data.department,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Pre-fill complaint and navigate to Phase 3 wizard
                          context
                              .read<AiAssistantProvider>()
                              .prefillComplaintAndNavigate(
                                context,
                                category: data.category,
                                title: data.title,
                                description: data.explanation ??
                                    '${data.title} reported via AI Civic Assistant at current location.',
                                priority: data.severity,
                              );
                        },
                        child: const Text(
                          'CREATE COMPLAINT',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.aiAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.aiAccent, size: 20),
                        tooltip: 'Edit details',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.selectCategory);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(AiInsightCardData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: AppColors.aiAccent),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.complaintId ?? '#CC-2026-00125',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.status ?? 'IN PROGRESS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Department: ${data.department}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Micro Timeline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimelineDot('Submitted', true),
                    _buildTimelineLine(true),
                    _buildTimelineDot('Assigned', true),
                    _buildTimelineLine(true),
                    _buildTimelineDot('In Progress', true, isCurrent: true),
                    _buildTimelineLine(false),
                    _buildTimelineDot('Resolved', false),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.complaintsList);
                    },
                    child: const Text(
                      'VIEW FULL COMPLAINT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(String label, bool isDone, {bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDone ? AppColors.aiAccent : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.aiAccent, width: 2)
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isCurrent
                ? AppColors.aiAccent
                : (isDone ? AppColors.textPrimary : AppColors.outline),
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDone ? AppColors.aiAccent : AppColors.outlineVariant,
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.aiSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.aiBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.aiAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI is thinking...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.aiAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
