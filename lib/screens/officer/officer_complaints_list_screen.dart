import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/evidence_image_viewer.dart';

class OfficerComplaintsListScreen extends StatefulWidget {
  const OfficerComplaintsListScreen({super.key});

  @override
  State<OfficerComplaintsListScreen> createState() => _OfficerComplaintsListScreenState();
}

class _OfficerComplaintsListScreenState extends State<OfficerComplaintsListScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'High Priority', 'In Progress', 'Resolved'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Assigned Complaints',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant, height: 1),
        ),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          final query = _searchController.text.toLowerCase().trim();

          final filtered = provider.complaints.where((c) {
            final matchesSearch = query.isEmpty ||
                c.title.toLowerCase().contains(query) ||
                c.id.toLowerCase().contains(query) ||
                c.location.toLowerCase().contains(query);

            if (!matchesSearch) return false;

            if (_selectedFilter == 'All') return true;
            if (_selectedFilter == 'High Priority') {
              return c.priority.toLowerCase() == 'high' ||
                  c.priority.toLowerCase() == 'urgent';
            }
            if (_selectedFilter == 'In Progress') {
              return c.status.toLowerCase() == 'in progress';
            }
            if (_selectedFilter == 'Resolved') {
              return c.status.toLowerCase() == 'resolved';
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by ID, title or street...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: const Color(0xFFF3F3FE),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedFilter = filter),
                              selectedColor: AppColors.primaryFixed,
                              labelStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Complaints list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No complaints match your filter.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          final isHigh = c.priority.toLowerCase() == 'high' ||
                              c.priority.toLowerCase() == 'urgent';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.outlineVariant),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 4,
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
                                        c.id,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isHigh
                                              ? const Color(0xFFFFDAD6)
                                              : const Color(0xFFEDEDF9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          c.status.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isHigh
                                                ? const Color(0xFF93000A)
                                                : AppColors.primary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.title,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 14,
                                                    color:
                                                        AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    c.location,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 13,
                                                      color:
                                                          AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if ((c.imageUrl != null &&
                                              c.imageUrl!.isNotEmpty) ||
                                          c.attachments.isNotEmpty) ...[
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: EvidenceImageViewer(
                                            imagePathOrUrl: c.imageUrl,
                                            attachments: c.attachments,
                                            height: 48,
                                            width: 48,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            enableZoom: false,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Category: ${c.category}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      ElevatedButton(
                                        key: Key('officer_view_list_btn_${c.id}'),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.officerComplaintDetails,
                                            arguments: c.id,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryFixed,
                                          foregroundColor: AppColors.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 6),
                                          minimumSize: const Size(60, 32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'VIEW',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
