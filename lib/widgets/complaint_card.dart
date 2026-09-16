import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/complaint_model.dart';
import 'status_chip.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water':
      case 'water supply':
        return Icons.water_drop_rounded;
      case 'roads':
      case 'roads & infrastructure':
      case 'road':
        return Icons.add_road_rounded;
      case 'electricity':
      case 'streetlight':
      case 'street lights':
        return Icons.lightbulb_rounded;
      case 'garbage':
      case 'sanitation':
        return Icons.delete_outline_rounded;
      case 'drainage':
        return Icons.waves_rounded;
      default:
        return Icons.report_problem_outlined;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withAlpha(80),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(complaint.category),
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        complaint.title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID: ${complaint.id} • ${_formatTimeAgo(complaint.createdAt)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Chip & Rating Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusChip(
                      status: complaint.status,
                      isCompact: true,
                    ),
                    if (complaint.status.toLowerCase() == 'resolved') ...[
                      const SizedBox(height: 4),
                      if (complaint.citizenRating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withAlpha(120),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${complaint.citizenRating}.0',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withAlpha(100),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_outline_rounded,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Rate',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
