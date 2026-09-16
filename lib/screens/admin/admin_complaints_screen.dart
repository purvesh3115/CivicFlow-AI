import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/complaint_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/admin_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/evidence_image_viewer.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    'All',
    'Submitted',
    'Under Review',
    'Assigned',
    'In Progress',
    'Resolved',
    'Closed',
    'High Priority',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    ComplaintProvider? complaintProvider;
    try {
      complaintProvider = Provider.of<ComplaintProvider>(context, listen: true);
    } catch (_) {}

    // Combine complaints: prefer ComplaintProvider complaints list (real Firestore sync),
    // then AdminProvider allComplaints, then convert attentionItems into ComplaintModel for fallback display
    final List<ComplaintModel> allComplaints = (complaintProvider != null &&
            complaintProvider.complaints.isNotEmpty)
        ? complaintProvider.complaints
        : (adminProvider.allComplaints.isNotEmpty
            ? adminProvider.allComplaints
            : adminProvider.attentionItems.map((item) {
                return ComplaintModel(
                  id: item.id,
                  title: item.title,
                  description: item.description,
                  category: 'Infrastructure',
                  department: item.department,
                  priority: item.priority,
                  status: item.isOverdue ? 'Overdue' : 'Submitted',
                  location: item.location,
                  latitude: 22.5645,
                  longitude: 72.9289,
                  citizenName: 'Purvesh Patel',
                  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
                );
              }).toList());

    final query = _searchController.text.toLowerCase().trim();

    final filteredItems = allComplaints.where((c) {
      final matchesSearch = query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.id.toLowerCase().contains(query) ||
          c.department.toLowerCase().contains(query) ||
          c.category.toLowerCase().contains(query) ||
          c.location.toLowerCase().contains(query) ||
          c.citizenName.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'High Priority') {
        return c.priority.toLowerCase() == 'high' ||
            c.priority.toLowerCase() == 'urgent';
      }
      return c.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'City Complaints Queue',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by ID, keyword, citizen, or department...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.outline),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _filterOptions.map((chip) {
                  final isSelected = _selectedFilter == chip;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        chip,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant.withAlpha(90),
                      ),
                      onSelected: (val) {
                        setState(() => _selectedFilter = chip);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Complaint list
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No complaints found matching criteria.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isHigh = item.priority.toLowerCase() == 'high' ||
                            item.priority.toLowerCase() == 'urgent';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isHigh
                                  ? AppColors.error.withAlpha(90)
                                  : AppColors.outlineVariant.withAlpha(80),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openComplaintDetailModal(context, item),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isHigh
                                                  ? AppColors.errorContainer
                                                  : AppColors.primaryContainer.withAlpha(30),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.priority.toUpperCase(),
                                              style: TextStyle(
                                                color: isHigh
                                                    ? AppColors.onErrorContainer
                                                    : AppColors.primary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(item.status).withAlpha(25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.status.toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(item.status),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _formatTimeAgo(item.createdAt),
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isHigh
                                              ? AppColors.error
                                              : AppColors.textSecondary,
                                          fontWeight: isHigh
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.id} • ${item.title}',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      if (item.assignedOfficerName != null &&
                                          item.assignedOfficerName!.isNotEmpty) ...[
                                        const Icon(Icons.badge_outlined,
                                            size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.assignedOfficerName!,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.department,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              minimumSize: const Size(60, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _openComplaintDetailModal(
                                                    context, item),
                                            child: const Text(
                                              'Details',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryContainer,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 6),
                                              minimumSize: const Size(60, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.adminAutoAssign,
                                                arguments: item.id,
                                              );
                                            },
                                            child: const Text(
                                              'Auto Assign',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'new':
        return AppColors.primary;
      case 'under review':
        return const Color(0xFF7C3AED);
      case 'assigned':
        return const Color(0xFF0284C7);
      case 'in progress':
      case 'working':
        return AppColors.statusInProgress;
      case 'resolved':
      case 'complete':
        return AppColors.success;
      case 'closed':
        return AppColors.onSurfaceVariant;
      default:
        return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _openComplaintDetailModal(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (ctx, scrollController) {
            return StatefulBuilder(
              builder: (sbContext, setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
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
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complaint.id,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                complaint.title,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(complaint.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              complaint.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(complaint.status),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Evidence Image (If available)
                      if ((complaint.imageUrl != null &&
                              complaint.imageUrl!.isNotEmpty) ||
                          complaint.attachments.isNotEmpty) ...[
                        Text(
                          'Complaint Evidence',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        EvidenceImageViewer(
                          imagePathOrUrl: complaint.imageUrl,
                          attachments: complaint.attachments,
                          height: 180,
                          title: '${complaint.id} - ${complaint.title}',
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      Text(
                        'Description',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complaint.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details Grid
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Citizen', complaint.citizenName),
                            const Divider(height: 16),
                            _buildInfoRow('Department', complaint.department),
                            const Divider(height: 16),
                            _buildInfoRow('Category', complaint.category),
                            const Divider(height: 16),
                            _buildInfoRow('Priority', complaint.priority),
                            const Divider(height: 16),
                            _buildInfoRow('Location', complaint.location),
                            if (complaint.assignedOfficerName != null) ...[
                              const Divider(height: 16),
                              _buildInfoRow(
                                'Assigned Officer',
                                complaint.assignedOfficerName!,
                                isHighlighted: true,
                              ),
                            ],
                            if (complaint.officerRemarks != null &&
                                complaint.officerRemarks!.isNotEmpty) ...[
                              const Divider(height: 16),
                              _buildInfoRow('Officer Remarks', complaint.officerRemarks!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action 1: Assign / Reassign Officer
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        label: Text(
                          complaint.assignedOfficerName != null
                              ? 'Reassign Field Officer'
                              : 'Assign Field Officer',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          _openAssignOfficerPicker(context, complaint);
                        },
                      ),
                      if (complaint.assignedOfficerName != null &&
                          complaint.assignedOfficerName!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.person_remove_rounded,
                              size: 18, color: AppColors.error),
                          label: const Text(
                            'Unassign / Remove Officer',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withAlpha(120),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            _confirmUnassignOfficer(context, complaint);
                          },
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Action 2: Update Status
                      OutlinedButton.icon(
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        label: const Text(
                          'Update Complaint Status',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          _openUpdateStatusDialog(context, complaint);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _openAssignOfficerPicker(BuildContext context, ComplaintModel complaint) {
    final adminProvider = context.read<AdminProvider>();
    final officers = adminProvider.officers;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Officer to ${complaint.id}',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select an officer from the active directory:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              ...officers.map((officer) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryFixed,
                    child: Text(
                      officer.name[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    officer.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${officer.department} • Tasks: ${officer.activeTasks}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.read<ComplaintProvider>().assignOfficer(
                            complaintId: complaint.id,
                            officerId: officer.id,
                            officerName: officer.name,
                            department: officer.department,
                          );
                      context.read<AdminProvider>().assignComplaint(
                            complaint.id,
                            officer.id,
                          );
                      Navigator.pop(pickerCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Assigned to ${officer.name} successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Assign'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmUnassignOfficer(BuildContext context, ComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unassign Officer?'),
        content: Text(
          'Are you sure you want to remove ${complaint.assignedOfficerName ?? "the assigned officer"} from ${complaint.id}? This will revert the complaint status back to Submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminProvider>().unassignComplaint(complaint.id);
              try {
                context.read<ComplaintProvider>().unassignOfficer(
                      complaintId: complaint.id,
                    );
              } catch (_) {}
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unassigned officer from ${complaint.id}.'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Unassign Work'),
          ),
        ],
      ),
    );
  }

  void _openUpdateStatusDialog(BuildContext context, ComplaintModel complaint) {
    final statuses = [
      'Submitted',
      'Under Review',
      'Assigned',
      'In Progress',
      'Resolved',
      'Closed',
    ];
    String selected = statuses.contains(complaint.status)
        ? complaint.status
        : 'In Progress';
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Update Status for ${complaint.id}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select new status:',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selected,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: statuses.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selected = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Remarks (optional):',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: remarksController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Tar crew scheduled for tomorrow 10 AM',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final remarks = remarksController.text.trim();
                    context.read<ComplaintProvider>().updateComplaintStatus(
                          id: complaint.id,
                          newStatus: selected,
                          remarks: remarks.isNotEmpty ? remarks : null,
                        );
                    context
                        .read<AdminProvider>()
                        .updateComplaintStatus(complaint.id, selected);

                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to $selected!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
