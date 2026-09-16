import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/bento_action_card.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/complaint_detail_modal.dart';
import '../../widgets/metric_counter_card.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final user = authProvider.currentUser;
    final complaints = complaintProvider.complaints.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.location_on, color: AppColors.primary),
          tooltip: 'Select Location',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Current Location: Anand, Gujarat (GPS Locked)'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        title: RichText(
          text: TextSpan(
            text: 'Citizen',
            style: AppTypography.brandTitle.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
            ),
            children: [
              TextSpan(
                text: 'Connect',
                style: AppTypography.brandTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          // Notification Bell with unread dot
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onSurface,
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // User Avatar Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => onNavigateTab?.call(4), // Navigate to Profile tab
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerHigh,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : 'P')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getTimeGreeting()}, ${user?.name ?? 'Purvesh'} 👋',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_rounded,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user?.city ?? 'Anand, Gujarat',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Offline sync banner if complaints are queued offline
              if (complaintProvider.inMemoryOfflineQueuedCount > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withAlpha(100)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          color: Color(0xFFB45309), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Complaints Queued',
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              '${complaintProvider.inMemoryOfflineQueuedCount} issue(s) waiting to upload.',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(60, 34),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                                          ? 'Synchronized $count offline complaint(s)!'
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
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sync Now',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004AC6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(75),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Ambient decorative circle
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How can we help you today?',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Report local issues quickly and track their resolution process in real-time.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryFixed,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.selectCategory,
                            );
                          },
                          icon: const Icon(
                            Icons.report_problem_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Report an Issue',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Bento Quick Action Cards
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 126,
                      child: BentoActionCard(
                        title: 'Track Complaint',
                        subtitle: 'Check status updates',
                        icon: Icons.track_changes_rounded,
                        iconColor: AppColors.primary,
                        onTap: () => onNavigateTab?.call(1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 126,
                      child: BentoActionCard(
                        title: 'Government Services',
                        subtitle: 'Apply for certificates',
                        icon: Icons.account_balance_rounded,
                        iconColor: AppColors.secondary,
                        onTap: () => onNavigateTab?.call(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bento Wide Card: AI Civic Assistant
              BentoActionCard(
                title: 'Ask AI Assistant',
                subtitle: 'Get instant answers to policy and process queries.',
                icon: Icons.smart_toy_rounded,
                iconColor: AppColors.tertiary,
                isWide: true,
                onTap: () => onNavigateTab?.call(3),
              ),
              const SizedBox(height: 26),

              // Complaint Status Section
              Text(
                'Complaint Status',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    MetricCounterCard(
                      label: 'Active',
                      count: complaintProvider.activeCount
                          .toString()
                          .padLeft(2, '0'),
                      icon: Icons.error_outline_rounded,
                      accentColor: AppColors.error,
                      badgeText: '+1 new',
                      badgeColor: AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    MetricCounterCard(
                      label: 'In Progress',
                      count: complaintProvider.inProgressCount
                          .toString()
                          .padLeft(2, '0'),
                      icon: Icons.hourglass_top_rounded,
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    MetricCounterCard(
                      label: 'Resolved',
                      count: complaintProvider.resolvedCount
                          .toString()
                          .padLeft(2, '0'),
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.primary,
                      badgeText: 'Total',
                      badgeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Recent Complaints List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Complaints',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: Text(
                      'View All',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Recent Complaints Cards
              ...complaints.map((c) => ComplaintCard(
                    complaint: c,
                    onTap: () => ComplaintDetailModal.show(context, c),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
