import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/complaint_card.dart';
import '../../../widgets/complaint_detail_modal.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/primary_button.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterTabs = [
    'All',
    'Submitted',
    'In Progress',
    'Resolved',
    'Queued Offline',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    final complaints = complaintProvider.filteredComplaints;
    final selectedFilter = complaintProvider.selectedStatusFilter;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Complaints Tracker',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            tooltip: 'New Complaint',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.selectCategory),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Offline Sync Banner
            if (complaintProvider.inMemoryOfflineQueuedCount > 0)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFF59E0B).withAlpha(90)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Complaints Queued',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          Text(
                            '${complaintProvider.inMemoryOfflineQueuedCount} issue(s) waiting to upload.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: const Size(60, 32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: complaintProvider.isSyncingOfflineQueue
                          ? null
                          : () async {
                              final count =
                                  await complaintProvider.syncOfflineQueue();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(count > 0
                                        ? 'Successfully synchronized $count offline complaint(s)!'
                                        : 'All complaints are up to date.'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: complaintProvider.isSyncingOfflineQueue
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sync Now',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => complaintProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, title, or street...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.outline,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              complaintProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filterTabs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filterTabs[index];
                  final isSelected = selectedFilter.toLowerCase() ==
                      (filter == 'Submitted' ? 'active' : filter.toLowerCase()) ||
                      selectedFilter.toLowerCase() == filter.toLowerCase();

                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (sel) {
                      if (sel) complaintProvider.setStatusFilter(filter);
                    },
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withAlpha(70),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Complaints Feed List
            Expanded(
              child: complaints.isEmpty
                  ? EmptyStateWidget(
                      title: 'No Complaints Found',
                      message: _searchController.text.isNotEmpty
                          ? 'No results match your search query.'
                          : 'You have no complaints matching "$selectedFilter".',
                      icon: Icons.assignment_outlined,
                      action: PrimaryButton(
                        text: 'Report an Issue',
                        width: 180,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.selectCategory,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      itemCount: complaints.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];
                        return ComplaintCard(
                          complaint: complaint,
                          onTap: () {
                            // Show complaint full interactive detail modal
                            ComplaintDetailModal.show(context, complaint);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Issue'),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.selectCategory),
      ),
    );
  }
}
