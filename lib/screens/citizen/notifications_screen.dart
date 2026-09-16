import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/notification_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _filterOnlyUnread = false;

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.complaintStatus:
        return Icons.assignment_outlined;
      case NotificationType.officerRemark:
        return Icons.comment_outlined;
      case NotificationType.schemeAlert:
        return Icons.campaign_outlined;
      case NotificationType.announcement:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.complaintStatus:
        return AppColors.primary;
      case NotificationType.officerRemark:
        return const Color(0xFF7C3AED);
      case NotificationType.schemeAlert:
        return AppColors.secondary;
      case NotificationType.announcement:
        return const Color(0xFF0D9488);
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final allNotifs = notifProvider.notifications;
    final displayedNotifs = _filterOnlyUnread
        ? allNotifs.where((n) => !n.isRead).toList()
        : allNotifs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${allNotifs.length})'),
                    selected: !_filterOnlyUnread,
                    onSelected: (selected) {
                      setState(() => _filterOnlyUnread = false);
                    },
                    selectedColor: AppColors.primaryContainer.withAlpha(40),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: !_filterOnlyUnread
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Unread (${notifProvider.unreadCount})'),
                    selected: _filterOnlyUnread,
                    onSelected: (selected) {
                      setState(() => _filterOnlyUnread = true);
                    },
                    selectedColor: AppColors.primaryContainer.withAlpha(40),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: _filterOnlyUnread
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: displayedNotifs.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No Notifications',
                      message: 'You are all caught up with your civic updates.',
                      icon: Icons.notifications_none_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: displayedNotifs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif = displayedNotifs[index];
                        final typeColor = _getColorForType(notif.type);

                        return Container(
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? AppColors.surfaceContainerLowest
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: notif.isRead
                                  ? AppColors.outlineVariant.withAlpha(60)
                                  : AppColors.primary.withAlpha(70),
                              width: notif.isRead ? 0.8 : 1.2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () {
                                notifProvider.markAsRead(notif.id);
                                if (notif.type == NotificationType.schemeAlert) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.serviceDetails,
                                    arguments: notif.referenceId ?? notif.title,
                                  );
                                } else if (notif.type ==
                                        NotificationType.complaintStatus ||
                                    notif.type ==
                                        NotificationType.officerRemark) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.complaintsList,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Type Icon Badge
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: typeColor.withAlpha(25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getIconForType(notif.type),
                                        color: typeColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notif.title,
                                                  style: AppTypography.labelLarge
                                                      .copyWith(
                                                    fontWeight: notif.isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.w800,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _formatTimestamp(
                                                  notif.timestamp,
                                                ),
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.onSurfaceVariant,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif.message,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Unread indicator dot
                                    if (!notif.isRead) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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
}
