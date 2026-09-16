import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/admin_provider.dart';
import '../../providers/complaint_provider.dart';

class AdminAutoAssignScreen extends StatelessWidget {
  final String? complaintId;

  const AdminAutoAssignScreen({super.key, this.complaintId});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final targetId = complaintId ?? '#CMP-8921';
    final recommendation =
        adminProvider.getAutoAssignRecommendation(targetId);
    final officer = recommendation.recommendedOfficer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary, size: 20),
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Auto Assign Complaint',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint Summary Context Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(80),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          'COMPLAINT ID: ${recommendation.complaintId}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer.withAlpha(70),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recommendation.priority.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recommendation.complaintTitle,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.complaintDescription,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Recommendation Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.aiSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.aiAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI RECOMMENDATION',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.aiSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.aiBorder),
                    ),
                    child: Text(
                      '${recommendation.matchScore}% Suitability',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.aiAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bento-Style Officer Recommendation Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.aiBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Gradient Accent Top Bar
                    Container(
                      height: 3.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.aiAccent, AppColors.primary],
                        ),
                      ),
                    ),
                    // Officer Profile Preview
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryFixed,
                            child: Text(
                              officer.name.isNotEmpty
                                  ? officer.name[0].toUpperCase()
                                  : 'O',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  officer.name,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  officer.department,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Metrics 2x2 Grid
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: AppColors.outlineVariant.withAlpha(80)),
                          bottom: BorderSide(
                              color: AppColors.outlineVariant.withAlpha(80)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                border: Border(
                                  right: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 18, color: AppColors.textSecondary),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Distance',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${recommendation.distanceKm} km',
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              color: AppColors.surfaceContainerLow,
                              child: Column(
                                children: [
                                  const Icon(Icons.work_history_outlined,
                                      size: 18, color: AppColors.textSecondary),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Active Workload',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${recommendation.activeTasks} tasks',
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Availability Status row
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      color: AppColors.surfaceContainerLow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Status: ${officer.status.label} (Capacity Available)',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AI Reasoning Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.aiSurface,
                        border: Border(
                          top: BorderSide(
                              color: AppColors.outlineVariant.withAlpha(80)),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.aiAccent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REASON FOR RECOMMENDATION',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.aiAccent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${recommendation.matchReason}"',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontStyle: FontStyle.italic,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
                  label: const Text(
                    'ACCEPT ASSIGNMENT',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    context.read<AdminProvider>().assignComplaint(
                          targetId,
                          officer.id,
                        );
                    try {
                      context.read<ComplaintProvider>().assignOfficer(
                            complaintId: targetId,
                            officerId: officer.id,
                            officerName: officer.name,
                            department: officer.department,
                          );
                    } catch (_) {}

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Assigned $targetId to ${officer.name} successfully!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                      ),
                    );
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(
                      color: AppColors.outlineVariant.withAlpha(120),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.person_search_rounded, size: 20),
                  label: const Text(
                    'CHOOSE MANUALLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select an officer from the Officers Directory.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
