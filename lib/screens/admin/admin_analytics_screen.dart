import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/admin_provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final metrics = adminProvider.metrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Operational Analytics',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                'Performance Metrics',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time municipal operations and AI triage efficiency.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // 2 Top KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'TOTAL RESOLUTION RATE',
                      value: '${metrics.resolutionRate.toStringAsFixed(0)}%',
                      trendText: '+2.4%',
                      isPositiveTrend: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'AVG. RESPONSE TIME',
                      value: '${metrics.avgResponseHours}h',
                      trendText: '-0.3h',
                      isPositiveTrend: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Volume Trends Card (7 Days)
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaint Volume (Last 7 Days)',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Bar Chart
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          adminProvider.weeklyVolumes.length,
                          (i) {
                            final vol = adminProvider.weeklyVolumes[i];
                            final day = i < adminProvider.weeklyDays.length
                                ? adminProvider.weeklyDays[i]
                                : 'D${i + 1}';
                            final heightPct = (vol / 80).clamp(0.15, 1.0);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${vol.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: 80 * heightPct,
                                  decoration: BoxDecoration(
                                    color: i == 4
                                        ? AppColors.primary
                                        : AppColors.primaryContainer
                                            .withAlpha(150),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  day,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Distribution
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryProgress('Roads & Infrastructure', 42,
                        AppColors.primaryContainer),
                    _buildCategoryProgress(
                        'Sanitation & Waste', 28, AppColors.secondary),
                    _buildCategoryProgress(
                        'Water Supply & Sewerage', 18, AppColors.tertiary),
                    _buildCategoryProgress(
                        'Street Lighting', 12, AppColors.warning),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI Model Performance Benchmark Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.aiSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.aiBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppColors.aiAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'AI Civic Assistant Performance',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.aiDarkText,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAiStat('Triage Accuracy', '94%', 'Target >92%'),
                        _buildAiStat('Duplicate Drop', '-35%', 'Computer Vision'),
                        _buildAiStat('Filing Time', '<45s', 'Gov Benchmark'),
                      ],
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trendText,
    required bool isPositiveTrend,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
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
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: [
                  Icon(
                    isPositiveTrend
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 13,
                    color: AppColors.success,
                  ),
                  Text(
                    trendText,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, int pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              Text(
                '$pct%',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiStat(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.aiDarkText,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.aiAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
