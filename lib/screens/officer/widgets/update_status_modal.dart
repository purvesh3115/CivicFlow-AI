import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/notification_provider.dart';

class UpdateStatusModal extends StatefulWidget {
  final String complaintId;
  final String currentStatus;

  const UpdateStatusModal({
    super.key,
    required this.complaintId,
    required this.currentStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required String complaintId,
    required String currentStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateStatusModal(
        complaintId: complaintId,
        currentStatus: currentStatus,
      ),
    );
  }

  @override
  State<UpdateStatusModal> createState() => _UpdateStatusModalState();
}

class _UpdateStatusModalState extends State<UpdateStatusModal> {
  late String _selectedStatus;
  final TextEditingController _remarksController = TextEditingController();

  final List<Map<String, String>> _statusOptions = [
    {
      'label': 'ACCEPTED',
      'value': 'Accepted',
      'desc': 'Acknowledge receipt and initial review.',
    },
    {
      'label': 'IN PROGRESS',
      'value': 'In Progress',
      'desc': 'Active investigation or intervention underway.',
    },
    {
      'label': 'WAITING FOR RESOURCES',
      'value': 'Waiting for Resources',
      'desc': 'Blocked pending additional personnel or equipment.',
    },
    {
      'label': 'ESCALATED',
      'value': 'Escalated',
      'desc': 'Transferred to a higher authority or specialized unit.',
    },
    {
      'label': 'RESOLUTION SUBMITTED',
      'value': 'Resolved',
      'desc': 'Issue addressed, awaiting final administrative closure.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Default to current status if matched, or In Progress
    final match = _statusOptions.firstWhere(
      (opt) => opt['value']?.toLowerCase() == widget.currentStatus.toLowerCase(),
      orElse: () => _statusOptions[1],
    );
    _selectedStatus = match['value']!;
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    final remarks = _remarksController.text.trim();
    context.read<ComplaintProvider>().updateComplaintStatus(
      id: widget.complaintId,
      newStatus: _selectedStatus,
      remarks: remarks.isNotEmpty ? remarks : null,
      officerName: 'Officer Rajesh Sharma',
    );

    // Also push notification to notification provider if available
    try {
      final notifProvider = context.read<NotificationProvider>();
      notifProvider.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Status Updated: ${widget.complaintId}',
          message:
              'Officer Rajesh Sharma updated status to $_selectedStatus${remarks.isNotEmpty ? ': $remarks' : '.'}',
          timestamp: DateTime.now(),
          type: NotificationType.complaintStatus,
          isRead: false,
          referenceId: widget.complaintId,
        ),
      );
    } catch (_) {}

    Navigator.pop(context); // dismiss modal

    // Navigate to confirmation screen
    Navigator.pushNamed(
      context,
      AppRoutes.statusUpdateConfirmed,
      arguments: {
        'complaintId': widget.complaintId,
        'status': _selectedStatus,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.outlineVariant),

              // Options
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._statusOptions.map((opt) {
                      final isSelected = _selectedStatus == opt['value'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStatus = opt['value']!;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF3F3FE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt['label']!,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        opt['desc']!,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Add Remark (Optional)
                    const Text(
                      'Add Remark (Optional)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarksController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Provide brief context for this status change...',
                        hintStyle: const TextStyle(
                          color: AppColors.outline,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Update Status Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('officer_modal_update_button'),
                        onPressed: _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'UPDATE STATUS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
