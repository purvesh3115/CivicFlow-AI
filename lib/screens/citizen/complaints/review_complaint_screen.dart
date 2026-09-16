import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';

class ReviewComplaintScreen extends StatefulWidget {
  const ReviewComplaintScreen({super.key});

  @override
  State<ReviewComplaintScreen> createState() => _ReviewComplaintScreenState();
}

class _ReviewComplaintScreenState extends State<ReviewComplaintScreen> {
  bool _isSubmitting = false;

  void _onSubmit() async {
    final complaintProvider = context.read<ComplaintProvider>();

    // Strictly enforce mandatory image
    if (complaintProvider.draftAttachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please add an image of the issue.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'ADD PHOTO',
            textColor: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authUser = context.read<AuthProvider>().currentUser;
      final citizenName = authUser?.name ?? 'Purvesh Patel';
      final citizenId = authUser?.id;

      final submitted = await complaintProvider.submitComplaintAsync(
        citizenName: citizenName,
        citizenId: citizenId,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.complaintSuccess,
        (route) => route.isFirst,
        arguments: submitted,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _onSubmit,
          ),
        ),
      );
    }
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Complaint saved to drafts successfully!'),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'CitizenConnect',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator: Step 4 of 4 (100%)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP 4 OF 4',
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'REVIEW',
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 22),

              // Title Header
              Text(
                'Review Your Complaint',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please review the details below before final submission. Ensure all information is accurate.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Bento Review Card 1: Category & Title with quick Edit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              provider.draftCategory.isNotEmpty
                                  ? provider.draftCategory
                                  : 'Roads',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.draftTitle.isNotEmpty
                                ? provider.draftTitle
                                : 'Pothole on Main Street',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bento Review Card 2: Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Description',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.draftDescription.isNotEmpty
                          ? provider.draftDescription
                          : 'There is a large, deep pothole in the right lane going northbound, just past the intersection with Elm St. It spans almost half the lane and is causing vehicles to swerve dangerously.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bento Review Card 3: Location Map
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Location',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(80),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.draftLocation.isNotEmpty
                          ? provider.draftLocation
                          : 'Main St & Elm St, Northbound lane, Anand',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bento Review Card 4: Evidence & Priority
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Evidence Row
                    Row(
                      children: [
                        const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Evidence (${provider.draftAttachments.length})',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: provider.draftAttachments.isNotEmpty
                                ? AppColors.successContainer
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            provider.draftAttachments.isNotEmpty ? 'ATTACHED' : 'REQUIRED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: provider.draftAttachments.isNotEmpty
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (provider.draftAttachments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Please add an image of the issue.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Add Image', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.draftAttachments.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final att = provider.draftAttachments[idx];
                            final isUrl = att.startsWith('http');
                            return Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withAlpha(70),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isUrl
                                  ? Image.network(
                                      att,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                        Icons.image_rounded,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Image.file(
                                      File(att),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                        Icons.image_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Priority
                    Row(
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Priority',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFFEEBA),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.priority_high_rounded,
                            size: 14,
                            color: Color(0xFF856404),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.draftPriority,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF856404),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Accuracy Disclaimer Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(60),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please confirm that the information provided is accurate to the best of your knowledge before submitting.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons: Submit & Save as Draft
              PrimaryButton(
                text: 'Submit Complaint',
                isLoading: _isSubmitting,
                icon: Icons.check_circle_rounded,
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Save as Draft',
                icon: Icons.bookmark_border_rounded,
                onPressed: _onSaveDraft,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
