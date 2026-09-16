import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/complaint_provider.dart';

class CivicCategoryItem {
  final String title;
  final String description;
  final IconData icon;

  const CivicCategoryItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<CivicCategoryItem> _allCategories = [
    CivicCategoryItem(
      title: 'Roads',
      description: 'Potholes, damaged tarmac, broken dividers',
      icon: Icons.add_road_rounded,
    ),
    CivicCategoryItem(
      title: 'Garbage',
      description: 'Overflowing bins, uncollected waste, litter',
      icon: Icons.recycling_rounded,
    ),
    CivicCategoryItem(
      title: 'Water',
      description: 'Pipe leaks, low pressure, contamination',
      icon: Icons.water_drop_rounded,
    ),
    CivicCategoryItem(
      title: 'Street Lights',
      description: 'Faulty lamps, dark stretches, flickering bulbs',
      icon: Icons.lightbulb_outline_rounded,
    ),
    CivicCategoryItem(
      title: 'Drainage',
      description: 'Clogged drains, sewage overflow, flooding',
      icon: Icons.plumbing_rounded,
    ),
    CivicCategoryItem(
      title: 'Electricity',
      description: 'Loose cables, power faults, transformer issues',
      icon: Icons.electrical_services_rounded,
    ),
    CivicCategoryItem(
      title: 'Pollution',
      description: 'Industrial discharge, smoke, noise levels',
      icon: Icons.factory_rounded,
    ),
    CivicCategoryItem(
      title: 'Public Safety',
      description: 'Hazardous structures, fallen trees, encroachments',
      icon: Icons.local_police_rounded,
    ),
    CivicCategoryItem(
      title: 'Other',
      description: 'Parks, stray animals, general municipal inquiries',
      icon: Icons.category_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CivicCategoryItem> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _allCategories;
    final q = _searchQuery.toLowerCase();
    return _allCategories.where((cat) {
      return cat.title.toLowerCase().contains(q) ||
          cat.description.toLowerCase().contains(q);
    }).toList();
  }

  void _onSelectCategory(CivicCategoryItem category) {
    context.read<ComplaintProvider>().setDraftCategory(category.title);
    Navigator.pushNamed(context, AppRoutes.complaintDetails);
  }

  @override
  Widget build(BuildContext context) {
    final displayedCategories = _filteredCategories;

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
          'New Report',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'What issue do you want to report?',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select the category that best matches your concern.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

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
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search categories (e.g., potholes, leakage)...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.outline,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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
              const SizedBox(height: 22),

              // Category Grid
              if (displayedCategories.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No categories found matching "$_searchQuery"',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedCategories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final cat = displayedCategories[index];
                        return _CategoryCard(
                          category: cat,
                          onTap: () => _onSelectCategory(cat),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CivicCategoryItem category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primaryContainer.withAlpha(40),
        highlightColor: AppColors.primary.withAlpha(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withAlpha(70),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withAlpha(120),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
