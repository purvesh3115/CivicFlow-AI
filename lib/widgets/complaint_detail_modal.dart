import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/complaint_model.dart';
import 'citizen_feedback_modal.dart';
import 'status_chip.dart';

class ComplaintDetailModal {
  static void show(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Top Meta row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      complaint.id,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    StatusChip(status: complaint.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Complaint Title
                Text(
                  complaint.title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                // Department & Priority tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        complaint.category,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: complaint.priority.toLowerCase() == 'urgent' ||
                                complaint.priority.toLowerCase() == 'high'
                            ? AppColors.errorContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${complaint.priority} Priority',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: complaint.priority.toLowerCase() == 'urgent' ||
                                  complaint.priority.toLowerCase() == 'high'
                              ? AppColors.onErrorContainer
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        complaint.location,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Issue Description',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complaint.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),

                // Live Progress Stepper
                _buildProgressStepper(complaint.status),
                const SizedBox(height: 18),

                // Officer Remarks Box (if updated by officer)
                if (complaint.officerRemarks != null &&
                    complaint.officerRemarks!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_ind_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Officer Update (${complaint.assignedOfficerName ?? 'Field Officer'})',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint.officerRemarks!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Attachments preview (if any)
                if (complaint.attachments.isNotEmpty) ...[
                  Text(
                    'Attached Evidence (${complaint.attachments.length})',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: complaint.attachments.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final att = complaint.attachments[i];
                        if (att.startsWith('http')) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              att,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 70,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image_outlined),
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: 80,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.description_rounded, size: 24, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text(
                                att.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Citizen Rating & Feedback Section for Resolved issues
                if (complaint.status.toLowerCase() == 'resolved') ...[
                  if (complaint.citizenRating == null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withAlpha(120),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFD97706),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Resolution Awaiting Your Review',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Are you satisfied with how this issue was resolved? Rate the resolution to help us maintain civic standards.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                CitizenFeedbackModal.show(context, complaint);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.rate_review_rounded,
                                  size: 18),
                              label: const Text(
                                'Rate & Review',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Citizen Review & Rating',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  final isFilled =
                                      index < (complaint.citizenRating ?? 0);
                                  return Icon(
                                    isFilled
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 18,
                                    color: isFilled
                                        ? const Color(0xFFF59E0B)
                                        : AppColors.outlineVariant,
                                  );
                                }),
                              ),
                            ],
                          ),
                          if (complaint.citizenFeedback != null &&
                              complaint.citizenFeedback!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"${complaint.citizenFeedback}"',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildProgressStepper(String status) {
    final lower = status.toLowerCase();
    int currentStep = 1;
    if (lower == 'assigned') {
      currentStep = 2;
    } else if (lower == 'in progress' || lower == 'accepted') {
      currentStep = 3;
    } else if (lower == 'resolved') {
      currentStep = 4;
    }

    final steps = ['Submitted', 'Assigned', 'In Progress', 'Resolved'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resolution Progress',
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isDone = index + 1 <= currentStep;
              final isCurrent = index + 1 == currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isDone
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                          ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.outline,
                                    ),
                                  ),
                          ),
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index + 1 < currentStep
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : isDone
                                ? AppColors.onSurface
                                : AppColors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
