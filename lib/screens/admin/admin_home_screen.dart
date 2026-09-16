import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/admin_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  final void Function(int)? onNavigateTab;

  const AdminHomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final metrics = adminProvider.metrics;
    final attentionList = adminProvider.attentionItems;
    final userName = authProvider.currentUser?.name ?? 'City Commissioner';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
          tooltip: 'Admin Portal',
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CitizenConnect',
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
            tooltip: 'Operational Analytics',
            onPressed: () => onNavigateTab?.call(4),
          ),
          IconButton(
            icon: const Icon(Icons.corporate_fare_rounded,
                color: AppColors.onSurfaceVariant),
            tooltip: 'Department Oversight',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminDepartments);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.primary),
            tooltip: 'Administrator Profile',
            onPressed: () => onNavigateTab?.call(5),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Welcome, $userName • City Operations',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer.withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'SLA 92%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Horizontal Scrollable Metric Counters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildMetricCard(
                      label: 'TOTAL',
                      value: '${metrics.total}',
                      accentColor: AppColors.onSurface,
                    ),
                    _buildMetricCard(
                      label: 'NEW',
                      value: '${metrics.newCount}',
                      accentColor: AppColors.primary,
                      trend: '+12%',
                    ),
                    _buildMetricCard(
                      label: 'IN PROGRESS',
                      value: '${metrics.inProgress}',
                      accentColor: AppColors.statusInProgress,
                    ),
                    _buildMetricCard(
                      label: 'HIGH PRIORITY',
                      value: '${metrics.highPriority}',
                      accentColor: AppColors.error,
                      isAlert: true,
                    ),
                    _buildMetricCard(
                      label: 'OVERDUE',
                      value: '${metrics.overdue}',
                      accentColor: AppColors.warning,
                      isAlert: true,
                    ),
                    _buildMetricCard(
                      label: 'RESOLVED',
                      value: '${metrics.resolved}',
                      accentColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // "Requires Attention" Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Requires Attention',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: Text(
                      'View All (${attentionList.length})',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Attention Items List
              if (attentionList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'All priority items have been dispatched! 🎉',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ),
                )
              else
                ...attentionList.map((item) => _buildAttentionCard(context, item)),

              const SizedBox(height: 24),

              // Complaint Trends (7-Day Volume Chart)
              Text(
                'Complaint Trends',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last 7 Days',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Total Volume',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Canvas Line Chart
                    SizedBox(
                      height: 90,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrendChartPainter(
                          volumes: adminProvider.weeklyVolumes,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Day Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: adminProvider.weeklyDays.map((d) {
                        return Text(
                          d,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color accentColor,
    String? trend,
    bool isAlert = false,
  }) {
    return Container(
      width: 126,
      height: 96,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.errorContainer.withAlpha(35)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert
              ? AppColors.error.withAlpha(70)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isAlert ? AppColors.error : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isAlert ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionCard(
      BuildContext context, AdminComplaintAttentionItem item) {
    final isOverdue = item.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withAlpha(90)
              : AppColors.outlineVariant.withAlpha(90),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag & Time Ago
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.errorContainer
                          : AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isOverdue
                            ? AppColors.onErrorContainer
                            : AppColors.error,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.id,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                item.timeAgo,
                style: AppTypography.labelSmall.copyWith(
                  color: isOverdue ? AppColors.error : AppColors.textSecondary,
                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Description
          Text(
            item.title,
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
          const SizedBox(height: 12),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    item.location,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                child: Text(
                  isOverdue ? 'Escalate' : 'Dispatch',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> volumes;
  final Color color;

  _TrendChartPainter({required this.volumes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (volumes.isEmpty) return;

    if (volumes.length == 1) {
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, dotPaint);
      return;
    }

    final maxVal = volumes.reduce((a, b) => a > b ? a : b);
    final minVal = volumes.reduce((a, b) => a < b ? a : b) * 0.8;
    final range = (maxVal - minVal) <= 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (volumes.length - 1);

    for (int i = 0; i < volumes.length; i++) {
      final x = i * stepX;
      final y = size.height - ((volumes[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill paint
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withAlpha(60),
          color.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Stroke paint
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Draw point dots
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < volumes.length; i++) {
      final x = i * stepX;
      final y = size.height - ((volumes[i] - minVal) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      canvas.drawCircle(
          Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => false;
}
