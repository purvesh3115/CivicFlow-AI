import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/primary_button.dart';

class UploadEvidenceScreen extends StatefulWidget {
  const UploadEvidenceScreen({super.key});

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  void _onContinue() {
    final attachments = context.read<ComplaintProvider>().draftAttachments;
    if (attachments.isEmpty) {
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
        ),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.reviewComplaint);
  }

  // --- Real Camera Capture ---
  Future<void> _takePhoto() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        if (!mounted) return;
        context.read<ComplaintProvider>().addDraftAttachment(photo.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Photo captured successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied' || e.message?.contains('permission') == true) {
        _showPermissionDeniedDialog('Camera permission is required to take a photo.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.message ?? e.code}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access camera: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // --- Real Gallery Picker ---
  Future<void> _chooseFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        if (!mounted) return;
        final provider = context.read<ComplaintProvider>();
        for (final img in images) {
          provider.addDraftAttachment(img.path);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🖼️ Added ${images.length} photo(s) from gallery!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'photo_access_denied' || e.message?.contains('permission') == true) {
        _showPermissionDeniedDialog('Gallery permission is required to select photos.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery error: ${e.message ?? e.code}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access gallery: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // --- Retake specific image ---
  Future<void> _retakePhoto(int index) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        if (!mounted) return;
        final provider = context.read<ComplaintProvider>();
        provider.removeDraftAttachment(index);
        provider.addDraftAttachment(photo.path);
      }
    } catch (_) {}
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final attachments = provider.draftAttachments;
    final hasImage = attachments.isNotEmpty;

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
              // Step 3 of 4 Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP 3 OF 4',
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'EVIDENCE',
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
                  value: 0.75,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 22),

              // Title Header
              Row(
                children: [
                  Text(
                    'Upload Evidence',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'An image of the issue is required for verification. Take a live photo or select from your gallery.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Action Cards: Take Photo & Choose Gallery
              Row(
                children: [
                  // Camera Card
                  Expanded(
                    child: InkWell(
                      onTap: _takePhoto,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(80),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Take Photo',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Use Camera',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Gallery Card
                  Expanded(
                    child: InkWell(
                      onTap: _chooseFromGallery,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1.5,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: AppColors.textPrimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Choose Gallery',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select Photos',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Selected Images Preview Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attached Evidence (${attachments.length})',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasImage)
                    TextButton(
                      onPressed: () => provider.clearDraftAttachments(),
                      child: const Text(
                        'Remove All',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (!hasImage)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withAlpha(70),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: AppColors.error.withAlpha(180),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No image added yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please tap "Take Photo" or "Choose Gallery" above to attach proof of the issue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: List.generate(attachments.length, (index) {
                    final item = attachments[index];
                    final isLocal = !item.startsWith('http');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          // Thumbnail Preview
                          SizedBox(
                            width: 100,
                            height: 90,
                            child: isLocal
                                ? Image.file(
                                    File(item),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(Icons.image),
                                    ),
                                  )
                                : Image.network(
                                    item,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 14),

                          // Image Info & Actions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Photo ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isLocal
                                      ? (item.split(Platform.pathSeparator).last)
                                      : 'Verified Civic Evidence',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Retake Button
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            tooltip: 'Retake Photo',
                            color: AppColors.primary,
                            onPressed: () => _retakePhoto(index),
                          ),

                          // Remove Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.error),
                            tooltip: 'Remove',
                            onPressed: () => provider.removeDraftAttachment(index),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 28),

              // Continue Button
              PrimaryButton(
                text: 'Continue to Review',
                icon: Icons.arrow_forward_rounded,
                onPressed: _onContinue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
