import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/complaint_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';

class ComplaintSuccessScreen extends StatefulWidget {
  final ComplaintModel? complaint;

  const ComplaintSuccessScreen({super.key, this.complaint});

  @override
  State<ComplaintSuccessScreen> createState() => _ComplaintSuccessScreenState();
}

class _ComplaintSuccessScreenState extends State<ComplaintSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Complaint ID copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.onSurface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaintId = widget.complaint?.id ?? '#CC10245';
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final formattedDate =
        '${months[now.month - 1]} ${now.day}, ${now.year}';

    final isOffline =
        widget.complaint?.status.toLowerCase() == 'queued offline';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient blurred decorative background circles
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOffline
                    ? const Color(0xFFFEF3C7).withAlpha(120)
                    : AppColors.primaryContainer.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOffline
                    ? const Color(0xFFFDE68A).withAlpha(80)
                    : AppColors.secondary.withAlpha(30),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Celebration Icon with pulse ring
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOffline
                                  ? const Color(0xFFD97706)
                                  : AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: (isOffline
                                          ? const Color(0xFFD97706)
                                          : AppColors.primary)
                                      .withAlpha(90),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                isOffline
                                    ? Icons.cloud_off_rounded
                                    : Icons.check_circle_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Headline
                    Text(
                      isOffline
                          ? 'Saved to Offline Queue'
                          : 'Complaint Submitted\nSuccessfully',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOffline
                          ? 'Your report and photo evidence are safely queued on your device and will automatically sync once internet connectivity is restored.'
                          : 'Your request has been securely logged with the local authorities.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Glassmorphic Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withAlpha(240),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(70),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Complaint ID Row with Copy button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'COMPLAINT ID',
                                    style: AppTypography.labelSmall.copyWith(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    complaintId,
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: isOffline
                                          ? const Color(0xFFD97706)
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton.filledTonal(
                                onPressed: () => _copyId(complaintId),
                                icon: Icon(
                                  _isCopied
                                      ? Icons.check_rounded
                                      : Icons.content_copy_rounded,
                                  size: 18,
                                  color: isOffline
                                      ? const Color(0xFFD97706)
                                      : AppColors.primary,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surfaceVariant,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: AppColors.outlineVariant.withAlpha(60),
                          ),
                          const SizedBox(height: 14),

                          // Status & Date Grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATUS',
                                    style: AppTypography.labelSmall.copyWith(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOffline
                                          ? const Color(0xFFFEF3C7)
                                          : AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isOffline
                                              ? Icons.cloud_off_rounded
                                              : Icons.pending_actions_rounded,
                                          size: 14,
                                          color: isOffline
                                              ? const Color(0xFFB45309)
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isOffline
                                              ? 'Queued Offline'
                                              : 'Submitted',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: isOffline
                                                ? const Color(0xFFB45309)
                                                : Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'DATE',
                                    style: AppTypography.labelSmall.copyWith(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formattedDate,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    PrimaryButton(
                      text: 'Track Complaint',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        // Navigate to home and open Tab 1 (Complaints)
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                          arguments: 1,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      text: 'Back to Home',
                      icon: Icons.home_rounded,
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
