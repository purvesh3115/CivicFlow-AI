import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/admin_model.dart';
import '../../models/complaint_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/complaint_provider.dart';

class ManageOfficersScreen extends StatelessWidget {
  const ManageOfficersScreen({super.key});

  void _showAddOfficerSheet(BuildContext context) {
    final nameController = TextEditingController();
    String selectedDept = 'Roads & Public Works';
    OfficerAvailabilityStatus selectedStatus = OfficerAvailabilityStatus.available;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Field Officer',
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Officer Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Inspector Ramesh Kumar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedDept,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Roads & Public Works',
                          child: Text('Roads & Public Works')),
                      DropdownMenuItem(
                          value: 'Sanitation & Waste',
                          child: Text('Sanitation & Waste')),
                      DropdownMenuItem(
                          value: 'Water Supply & Sewerage',
                          child: Text('Water Supply & Sewerage')),
                      DropdownMenuItem(
                          value: 'Electrical & Lighting',
                          child: Text('Electrical & Lighting')),
                      DropdownMenuItem(
                          value: 'Parks & Recreation',
                          child: Text('Parks & Recreation')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedDept = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Status Dropdown
                  DropdownButtonFormField<OfficerAvailabilityStatus>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Initial Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: OfficerAvailabilityStatus.values.map((st) {
                      return DropdownMenuItem(
                        value: st,
                        child: Text(st.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedStatus = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        context.read<AdminProvider>().addOfficer(
                              name: nameController.text.trim(),
                              department: selectedDept,
                              status: selectedStatus,
                            );
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Officer "${nameController.text.trim()}" added to directory.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text(
                        'ADD OFFICER',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final officers = adminProvider.filteredOfficers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Officer Directory',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOfficerSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Add Officer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                onChanged: (val) {
                  adminProvider.searchOfficers(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search officers or department...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.outline),
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
                children: ['All Status', 'Available', 'On Task', 'Offline']
                    .map((status) {
                  final isSelected =
                      adminProvider.officerStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        status,
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
                        adminProvider.setOfficerStatusFilter(status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Officers List
            Expanded(
              child: officers.isEmpty
                  ? Center(
                      child: Text(
                        'No personnel found in directory.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: officers.length,
                      itemBuilder: (context, index) {
                        final off = officers[index];
                        return _buildOfficerCard(context, off);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerCard(BuildContext context, AdminOfficerModel off) {
    Color statusBg;
    Color statusColor;

    switch (off.status) {
      case OfficerAvailabilityStatus.available:
        statusBg = AppColors.secondary.withAlpha(25);
        statusColor = AppColors.secondary;
        break;
      case OfficerAvailabilityStatus.onTask:
        statusBg = AppColors.warning.withAlpha(25);
        statusColor = AppColors.warning;
        break;
      case OfficerAvailabilityStatus.offline:
        statusBg = AppColors.outline.withAlpha(25);
        statusColor = AppColors.outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showOfficerWorkAndProfileSheet(context, off),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryFixed,
                          child: Text(
                            off.name.isNotEmpty ? off.name[0].toUpperCase() : 'O',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                off.name,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                off.department,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withAlpha(60)),
                        ),
                        child: Text(
                          off.status.label.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'work') {
                            _showOfficerWorkAndProfileSheet(context, off);
                          } else if (val == 'assign') {
                            _showAssignWorkModal(context, off);
                          } else if (val == 'status_available') {
                            context.read<AdminProvider>().updateOfficerStatus(
                                off.id, OfficerAvailabilityStatus.available);
                          } else if (val == 'status_ontask') {
                            context.read<AdminProvider>().updateOfficerStatus(
                                off.id, OfficerAvailabilityStatus.onTask);
                          } else if (val == 'status_offline') {
                            context.read<AdminProvider>().updateOfficerStatus(
                                off.id, OfficerAvailabilityStatus.offline);
                          } else if (val == 'delete') {
                            _confirmDeleteOfficer(context, off);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'work',
                            child: Row(
                              children: [
                                Icon(Icons.assignment_ind_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Manage Work & Tasks'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'assign',
                            child: Row(
                              children: [
                                Icon(Icons.add_task_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Assign New Work'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'status_available',
                            child: Text('Set Available'),
                          ),
                          const PopupMenuItem(
                            value: 'status_ontask',
                            child: Text('Set On Task'),
                          ),
                          const PopupMenuItem(
                            value: 'status_offline',
                            child: Text('Set Offline'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Remove Officer', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2-Column Workload Stats
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.outlineVariant.withAlpha(70)),
                    bottom: BorderSide(color: AppColors.outlineVariant.withAlpha(70)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Active Tasks',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${off.activeTasks}',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.outlineVariant.withAlpha(70),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Completed',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${off.completedTasks}',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.assignment_ind_rounded, size: 16),
                      label: Text(
                        'Manage Work (${off.activeTasks})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () =>
                          _showOfficerWorkAndProfileSheet(context, off),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withAlpha(90),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Assign',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () => _showAssignWorkModal(context, off),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfficerWorkAndProfileSheet(
      BuildContext context, AdminOfficerModel officer) {
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
            return Consumer2<AdminProvider, ComplaintProvider>(
              builder: (consumerCtx, adminProvider, complaintProvider, _) {
                // Find up-to-date officer model from provider
                final currentOfficer = adminProvider.officers.firstWhere(
                  (o) => o.id == officer.id,
                  orElse: () => officer,
                );

                // Combine complaints assigned to this officer from both providers
                final List<ComplaintModel> assignedComplaints = [];
                final seenIds = <String>{};

                for (final c in adminProvider.getOfficerWork(
                    currentOfficer.id, currentOfficer.name)) {
                  if (seenIds.add(c.id)) {
                    assignedComplaints.add(c);
                  }
                }
                for (final c in complaintProvider.complaints) {
                  final isAssigned = (c.assignedOfficerId == currentOfficer.id) ||
                      (c.assignedOfficerName != null &&
                          c.assignedOfficerName!.toLowerCase() ==
                              currentOfficer.name.toLowerCase());
                  if (isAssigned && seenIds.add(c.id)) {
                    assignedComplaints.add(c);
                  }
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
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

                      // Officer Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryFixed,
                            child: Text(
                              currentOfficer.name.isNotEmpty
                                  ? currentOfficer.name[0].toUpperCase()
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
                                  currentOfficer.name,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentOfficer.department,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 16, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${currentOfficer.rating} Rating • ${currentOfficer.completedTasks} Resolved',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Availability Status Selector
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Availability Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children:
                                  OfficerAvailabilityStatus.values.map((status) {
                                final isSelected = currentOfficer.status == status;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      status.label,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.primary,
                                    onSelected: (val) {
                                      if (val) {
                                        adminProvider.updateOfficerStatus(
                                            currentOfficer.id, status);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Assigned Work Section Header & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Assigned Work',
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${assignedComplaints.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add_task_rounded, size: 16),
                            label: const Text(
                              'Assign Work',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () =>
                                _showAssignWorkModal(context, currentOfficer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Assigned Complaints List
                      if (assignedComplaints.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outlineVariant.withAlpha(80),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 40,
                                color: AppColors.outline,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No work currently assigned to this officer.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Assign Work Now'),
                                onPressed: () => _showAssignWorkModal(
                                    context, currentOfficer),
                              ),
                            ],
                          ),
                        )
                      else
                        ...assignedComplaints.map((c) {
                          final isHigh = c.priority.toLowerCase() == 'high' ||
                              c.priority.toLowerCase() == 'urgent';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isHigh
                                    ? AppColors.error.withAlpha(70)
                                    : AppColors.outlineVariant.withAlpha(80),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      c.id,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isHigh
                                                ? AppColors.errorContainer
                                                : AppColors.primaryContainer
                                                    .withAlpha(25),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            c.priority.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: isHigh
                                                  ? AppColors.onErrorContainer
                                                  : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7)
                                                .withAlpha(20),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            c.status.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  c.location,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      c.department,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: BorderSide(
                                          color: AppColors.error.withAlpha(90),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        minimumSize: const Size(50, 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.person_remove_rounded,
                                          size: 14),
                                      label: const Text(
                                        'Unassign Work',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onPressed: () {
                                        _confirmUnassignWork(
                                            context, c, currentOfficer);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Danger Zone: Delete Officer
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                            color: AppColors.error.withAlpha(120),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.person_off_rounded, size: 18),
                        label: const Text(
                          'Remove Officer from Directory',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          _confirmDeleteOfficer(context, currentOfficer);
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

  void _showAssignWorkModal(BuildContext context, AdminOfficerModel officer) {
    final adminProvider = context.read<AdminProvider>();
    ComplaintProvider? complaintProvider;
    try {
      complaintProvider = context.read<ComplaintProvider>();
    } catch (_) {}

    // Combine unassigned or available complaints
    final List<ComplaintModel> availableComplaints = [];
    final seen = <String>{};

    for (final c in adminProvider.getUnassignedComplaints()) {
      if (seen.add(c.id)) availableComplaints.add(c);
    }
    if (complaintProvider != null) {
      for (final c in complaintProvider.complaints) {
        final isUnassigned =
            c.assignedOfficerId == null || c.assignedOfficerId!.isEmpty;
        final isResolved = c.status.toLowerCase() == 'resolved' ||
            c.status.toLowerCase() == 'closed';
        if (isUnassigned && !isResolved && seen.add(c.id)) {
          availableComplaints.add(c);
        }
      }
    }

    // Fallback: If zero unassigned exist, offer all pending complaints in system
    if (availableComplaints.isEmpty) {
      final all = adminProvider.allComplaints.isNotEmpty
          ? adminProvider.allComplaints
          : (complaintProvider?.complaints ?? []);
      for (final c in all) {
        if (c.status.toLowerCase() != 'resolved' &&
            c.status.toLowerCase() != 'closed' &&
            seen.add(c.id)) {
          availableComplaints.add(c);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (ctx, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Assign Work to ${officer.name}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a pending civic complaint to dispatch to this officer:',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: availableComplaints.isEmpty
                        ? const Center(
                            child: Text(
                              'No pending complaints available to assign.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: availableComplaints.length,
                            itemBuilder: (itemCtx, index) {
                              final c = availableComplaints[index];
                              final isDeptMatch = c.department
                                  .toLowerCase()
                                  .contains(officer.department
                                      .split(' ')
                                      .first
                                      .toLowerCase());

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDeptMatch
                                      ? AppColors.primaryFixed.withAlpha(20)
                                      : AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDeptMatch
                                        ? AppColors.primary.withAlpha(60)
                                        : AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                c.id,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                c.priority.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: c.priority
                                                              .toLowerCase() ==
                                                          'high'
                                                      ? AppColors.error
                                                      : AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            c.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${c.department} • ${c.location}',
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
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryContainer,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        minimumSize: const Size(60, 32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<AdminProvider>()
                                            .assignComplaint(c.id, officer.id);
                                        try {
                                          context
                                              .read<ComplaintProvider>()
                                              .assignOfficer(
                                                complaintId: c.id,
                                                officerId: officer.id,
                                                officerName: officer.name,
                                                department: officer.department,
                                              );
                                        } catch (_) {}
                                        Navigator.pop(modalCtx);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Assigned ${c.id} to ${officer.name}!'),
                                            backgroundColor: AppColors.success,
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Assign',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmUnassignWork(BuildContext context, ComplaintModel complaint,
      AdminOfficerModel officer) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Work from Officer?'),
        content: Text(
          'Are you sure you want to remove ${complaint.id} ("${complaint.title}") from ${officer.name}? The complaint will return to the unassigned queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<AdminProvider>()
                  .unassignComplaint(complaint.id);
              try {
                context.read<ComplaintProvider>().unassignOfficer(
                      complaintId: complaint.id,
                    );
              } catch (_) {}
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${complaint.id} from ${officer.name}.'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOfficer(BuildContext context, AdminOfficerModel officer) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Officer from Directory?'),
        content: Text(
          'Are you sure you want to remove ${officer.name} (${officer.department})? Any active tasks assigned to this officer will be automatically returned to the unassigned queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AdminProvider>().removeOfficer(officer.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Officer ${officer.name} removed and tasks unassigned.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Remove Officer'),
          ),
        ],
      ),
    );
  }
}

