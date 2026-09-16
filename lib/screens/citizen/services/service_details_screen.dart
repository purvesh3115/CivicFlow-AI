import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/service_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/services_provider.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final GovernmentServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final servicesProvider = context.watch<ServicesProvider>();
    final isBookmarked = servicesProvider.allServices
        .firstWhere((s) => s.id == service.id, orElse: () => service)
        .isBookmarked;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Scheme Details',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppColors.primary : AppColors.onSurface,
            ),
            tooltip: 'Bookmark',
            onPressed: () {
              servicesProvider.toggleBookmark(service.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Category Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: service.accentColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.category.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: service.accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: AppColors.onSuccessContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active Scheme',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSuccessContainer,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      service.title,
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.department,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Specs Row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickSpec(
                              label: 'Processing Time',
                              value: service.processingTime,
                              icon: Icons.schedule_rounded,
                            ),
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.outlineVariant.withAlpha(80),
                          ),
                          Expanded(
                            child: _QuickSpec(
                              label: 'Application Fee',
                              value: service.fee,
                              icon: Icons.payments_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Program Overview Section
              _DetailSectionCard(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Program Overview',
                child: Text(
                  service.fullOverview,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Key Benefits Section
              _DetailSectionCard(
                icon: Icons.stars_rounded,
                iconColor: AppColors.secondary,
                title: 'Key Benefits',
                child: Column(
                  children: service.benefits
                      .map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.onSurface,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Eligibility Criteria Section
              _DetailSectionCard(
                icon: Icons.verified_user_outlined,
                iconColor: const Color(0xFF0284C7),
                title: 'Eligibility Requirements',
                child: Column(
                  children: [
                    ...service.eligibilityCriteria
                        .map(
                          (criteria) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0284C7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    criteria,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.serviceEligibility,
                          arguments: service,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.rule_folder_outlined,
                                  size: 18,
                                  color: Color(0xFF0284C7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Full Eligibility Rules (Age, Income, Domicile)',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0284C7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFF0284C7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Required Documents Section
              _DetailSectionCard(
                icon: Icons.folder_open_rounded,
                iconColor: AppColors.tertiary,
                title: 'Required Documents',
                child: Column(
                  children: service.requiredDocuments
                      .map(
                        (doc) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.outlineVariant.withAlpha(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 18,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 90), // Spacing for bottom bar
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withAlpha(70),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton.filledTonal(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.primary : AppColors.onSurface,
                ),
                onPressed: () {
                  servicesProvider.toggleBookmark(service.id);
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.serviceEligibility,
                    arguments: service,
                  );
                },
                icon: const Icon(Icons.rule_folder_outlined, size: 18),
                label: const Text('Criteria'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0284C7),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    servicesProvider.startEligibilityQuiz(service);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eligibilityCheck,
                      arguments: service,
                    );
                  },
                  icon: const Icon(
                    Icons.fact_check_outlined,
                    size: 19,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Check Your Eligibility',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickSpec extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuickSpec({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.5,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _DetailSectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withAlpha(70),
          width: 0.8,
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
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
