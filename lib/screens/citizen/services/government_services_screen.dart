import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/service_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/services_provider.dart';

class GovernmentServicesScreen extends StatefulWidget {
  const GovernmentServicesScreen({super.key});

  @override
  State<GovernmentServicesScreen> createState() =>
      _GovernmentServicesScreenState();
}

class _GovernmentServicesScreenState extends State<GovernmentServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Health',
      'icon': Icons.health_and_safety_rounded,
      'color': AppColors.primary,
      'bg': Color(0xFFEFF4FF),
    },
    {
      'name': 'Education',
      'icon': Icons.school_rounded,
      'color': AppColors.secondary,
      'bg': Color(0xFFEFF3FF),
    },
    {
      'name': 'Housing',
      'icon': Icons.home_work_rounded,
      'color': Color(0xFF0284C7),
      'bg': Color(0xFFF0F9FF),
    },
    {
      'name': 'Social Welfare',
      'icon': Icons.diversity_3_rounded,
      'color': AppColors.tertiary,
      'bg': Color(0xFFF7EDFF),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = context.watch<ServicesProvider>();
    final services = servicesProvider.filteredServices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Government Services',
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.folder_shared_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'My Documents Vault',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myDocuments);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title & Intro
                Text(
                  'Find Civic Schemes',
                  style: AppTypography.headlineLarge.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover welfare assistance, education subsidies, and civic permits tailored to you.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: servicesProvider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search for Health, Housing, Subsidies...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                servicesProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Digital Document Vault Banner
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.myDocuments);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Digital Document Vault',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '5 Verified',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.onSuccessContainer,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Access official certificates, ID cards, and receipts',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primaryFixed,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Bento Grid
                Text(
                  'Service Categories',
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected =
                        servicesProvider.selectedCategory == cat['name'];
                    return _CategoryBentoCard(
                      name: cat['name'] as String,
                      icon: cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      bgColor: cat['bg'] as Color,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          servicesProvider.setSelectedCategory('All');
                        } else {
                          servicesProvider.setSelectedCategory(cat['name']);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 22),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All Schemes',
                        isSelected: servicesProvider.selectedCategory == 'All',
                        onTap: () => servicesProvider.setSelectedCategory('All'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Health',
                        isSelected:
                            servicesProvider.selectedCategory == 'Health',
                        onTap: () =>
                            servicesProvider.setSelectedCategory('Health'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Education',
                        isSelected:
                            servicesProvider.selectedCategory == 'Education',
                        onTap: () =>
                            servicesProvider.setSelectedCategory('Education'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Housing',
                        isSelected:
                            servicesProvider.selectedCategory == 'Housing',
                        onTap: () =>
                            servicesProvider.setSelectedCategory('Housing'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Social Welfare',
                        isSelected:
                            servicesProvider.selectedCategory == 'Social Welfare',
                        onTap: () => servicesProvider
                            .setSelectedCategory('Social Welfare'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Civic Permits',
                        isSelected:
                            servicesProvider.selectedCategory == 'Civic Permits',
                        onTap: () => servicesProvider
                            .setSelectedCategory('Civic Permits'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Recommended / Available Schemes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Programs (${services.length})',
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (servicesProvider.selectedCategory != 'All' ||
                        servicesProvider.searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          servicesProvider.setSelectedCategory('All');
                          servicesProvider.setSearchQuery('');
                        },
                        child: Text(
                          'Reset Filter',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Schemes List
                if (services.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.outlineVariant.withAlpha(60),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching services found',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching with a different civic term or reset category filters.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _ServiceCard(
                        service: service,
                        onCheckEligibility: () {
                          servicesProvider.startEligibilityQuiz(service);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.eligibilityCheck,
                            arguments: service,
                          );
                        },
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.serviceDetails,
                            arguments: service,
                          );
                        },
                        onToggleBookmark: () {
                          servicesProvider.toggleBookmark(service.id);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBentoCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryBentoCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant.withAlpha(60),
            width: isSelected ? 1.8 : 0.8,
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.onSurface,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Explore',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
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
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withAlpha(80),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final GovernmentServiceModel service;
  final VoidCallback onCheckEligibility;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  const _ServiceCard({
    required this.service,
    required this.onCheckEligibility,
    required this.onTap,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withAlpha(70),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Pill & Bookmark
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
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
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
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
                            size: 11,
                            color: AppColors.onSuccessContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSuccessContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        service.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: service.isBookmarked
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: onToggleBookmark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Service Icon & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: service.accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        service.icon,
                        color: service.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            service.department,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  service.shortDescription,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Highlights Info Badges
                Row(
                  children: [
                    _InfoBadge(
                      icon: Icons.schedule_rounded,
                      label: service.processingTime,
                    ),
                    const SizedBox(width: 8),
                    _InfoBadge(
                      icon: Icons.payments_outlined,
                      label: service.fee,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: onCheckEligibility,
                        icon: const Icon(
                          Icons.fact_check_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Check Eligibility',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Details',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
