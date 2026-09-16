import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'queued offline':
      case 'offline queued':
      case 'offline':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        icon = Icons.cloud_off_rounded;
        break;
      case 'submitted':
        bg = AppColors.primaryFixed;
        text = AppColors.onPrimaryFixedVariant;
        icon = Icons.send_rounded;
        break;
      case 'under review':
      case 'review':
        bg = AppColors.warningContainer;
        text = AppColors.warning;
        icon = Icons.visibility_rounded;
        break;
      case 'assigned':
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF6D28D9);
        icon = Icons.assignment_ind_rounded;
        break;
      case 'in progress':
      case 'progress':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0369A1);
        icon = Icons.engineering_rounded;
        break;
      case 'resolved':
        bg = AppColors.successContainer;
        text = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'closed':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
        icon = Icons.archive_rounded;
        break;
      default:
        bg = AppColors.surfaceContainerHigh;
        text = AppColors.onSurfaceVariant;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: text),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTypography.labelSmall.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
