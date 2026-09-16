import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai_message_model.dart';
import '../../../providers/ai_assistant_provider.dart';

class AiImageAnalysisScreen extends StatefulWidget {
  const AiImageAnalysisScreen({super.key});

  @override
  State<AiImageAnalysisScreen> createState() => _AiImageAnalysisScreenState();
}

class _AiImageAnalysisScreenState extends State<AiImageAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  late AiImageAnalysisResult _analysisResult;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    final provider = context.read<AiAssistantProvider>();
    _analysisResult = provider.runImageAnalysis(notify: false);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _reanalyze() {
    final provider = context.read<AiAssistantProvider>();
    setState(() {
      _analysisResult = provider.runImageAnalysis();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Re-analyzed image with CitizenConnect Vision AI v2.4'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'CitizenConnect AI',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.onSurfaceVariant),
            tooltip: 'Re-analyze',
            onPressed: _reanalyze,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'AI Image Analysis',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reviewing your submitted image for civic infrastructure issues.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 18),

              // Image Preview with Laser Scanning Animation & Bounding Box
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      children: [
                        // Synthetic Road Damage / Pothole representation
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF334155),
                                const Color(0xFF1E293B),
                                Colors.grey.shade900,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 140,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(190),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: Colors.white.withAlpha(40),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(200),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber.shade400,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bounding Box Overlay around anomaly
                        Center(
                          child: Container(
                            width: 170,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.aiAccent.withAlpha(25),
                              border: Border.all(
                                color: AppColors.aiAccent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -12,
                                  right: -12,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.aiAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.priority_high_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Animated Laser Scanning Line
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanAnimation.value * 200,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: AppColors.aiAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.aiAccent.withAlpha(200),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Metadata bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uploaded: Today, 10:42 AM',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.error, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          _analysisResult.location,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Primary AI Assessment Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(90),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teal Top Bar
                    Container(height: 3.5, color: AppColors.aiAccent),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: AI Detected & Confidence Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.aiSurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.aiAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AI DETECTED',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        _analysisResult.issueName,
                                        style: AppTypography.headlineSmall
                                            .copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.aiSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.aiBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.aiAccent, size: 15),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_analysisResult.confidenceScore}% Confidence',
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
                          const SizedBox(height: 16),

                          // Details Table
                          _buildDetailRow(
                            'Category',
                            _analysisResult.category,
                          ),
                          _buildDetailRow(
                            'Severity',
                            _analysisResult.severity,
                            isSeverity: true,
                          ),
                          _buildDetailRow(
                            'Recommended Dept',
                            _analysisResult.department,
                            isLast: true,
                          ),
                          const SizedBox(height: 16),

                          // AI Explanation Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.aiSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.aiBorder),
                            ),
                            child: Text(
                              '"${_analysisResult.explanation}"',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.aiDarkText,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded,
                                  size: 18),
                              label: const Text(
                                'CREATE COMPLAINT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                context
                                    .read<AiAssistantProvider>()
                                    .prefillComplaintAndNavigate(
                                      context,
                                      category: 'Roads',
                                      title: 'Deep Pothole on Station Road',
                                      description: _analysisResult.explanation,
                                      priority: _analysisResult.severity,
                                      attachment: 'pothole_ai_scanned.jpg',
                                    );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.aiAccent,
                                side: const BorderSide(
                                    color: AppColors.aiAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'ANALYZE AGAIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: _reanalyze,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Glassmorphism Model Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Analysis powered by CitizenConnect Vision AI v2.4',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isSeverity = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.surfaceContainerHighest.withAlpha(80),
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (isSeverity)
            Row(
              children: [
                const Icon(Icons.priority_high,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 2),
                Text(
                  value,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
        ],
      ),
    );
  }
}
