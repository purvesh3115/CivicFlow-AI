import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/evidence_image_viewer.dart';
import 'widgets/update_status_modal.dart';

class OfficerComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const OfficerComplaintDetailsScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        final complaint = provider.complaints.firstWhere(
          (c) => c.id.toLowerCase() == complaintId.toLowerCase(),
          orElse: () => ComplaintModel(
            id: complaintId,
            title: 'Pothole',
            description: 'Large pothole near college entrance.',
            category: 'Roads',
            department: 'Roads & Public Works',
            priority: 'High',
            status: 'In Progress',
            location: 'University Road',
            citizenName: 'Student Union',
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Complaint Details',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.outlineVariant, height: 1),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Preview Card with High Priority badge & Expand
                    _buildImageHero(context, complaint),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bento Grid: Location (col-span-2), Category, Department
                    _buildBentoGrid(complaint),
                    const SizedBox(height: 16),

                    // Citizen Description
                    _buildCitizenDescription(complaint),
                    const SizedBox(height: 16),

                    // AI Analysis Result Card
                    _buildAiAnalysisCard(complaint),
                  ],
                ),
              ),

              // Sticky Bottom Action Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        key: const Key('officer_update_status_button'),
                        onPressed: () {
                          UpdateStatusModal.show(
                            context,
                            complaintId: complaint.id,
                            currentStatus: complaint.status,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(Icons.update, size: 20),
                        label: const Text(
                          'UPDATE STATUS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageHero(BuildContext context, ComplaintModel complaint) {
    final isHigh = complaint.priority.toLowerCase() == 'high' ||
        complaint.priority.toLowerCase() == 'urgent';

    return EvidenceImageViewer(
      imagePathOrUrl: complaint.imageUrl,
      attachments: complaint.attachments,
      height: 220,
      title: '${complaint.id} - ${complaint.title}',
      borderRadius: BorderRadius.circular(16),
      overlay: isHigh
          ? Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withAlpha(242),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFBA1A1A).withAlpha(76)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Color(0xFFBA1A1A), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'HIGH PRIORITY',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBA1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBentoGrid(ComplaintModel complaint) {
    return Column(
      children: [
        // Location card (full width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                complaint.location,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Row of 2: Category & Department
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.category, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Category',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.category == 'Roads' ? 'Road Infrastructure' : complaint.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.domain, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Department',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCitizenDescription(ComplaintModel complaint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'CITIZEN DESCRIPTION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.outlineVariant, width: 2),
              ),
            ),
            child: Text(
              '"${complaint.description}"',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisCard(ComplaintModel complaint) {
    const tealPrimary = Color(0xFF0F766E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tealPrimary.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tealPrimary.withAlpha(64)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Robot icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: tealPrimary.withAlpha(51)),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: tealPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Analysis Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Analysis Result',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tealPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Text(
                        'AUTO',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tealPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Table rows
                _buildAnalysisRow('Detected Issue', complaint.title.contains('Pothole') ? 'Pothole' : complaint.category),
                const Divider(height: 16, color: Color(0x200F766E)),
                _buildAnalysisRow('Confidence', '94%', valueColor: tealPrimary, isBold: true),
                const Divider(height: 16, color: Color(0x200F766E)),
                _buildAnalysisRow(
                  'Rec. Priority',
                  'High',
                  valueColor: const Color(0xFFBA1A1A),
                  isBold: true,
                  trailingIcon: const Icon(Icons.arrow_upward, color: Color(0xFFBA1A1A), size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    Widget? trailingIcon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 2),
              trailingIcon,
            ],
          ],
        ),
      ],
    );
  }
}
