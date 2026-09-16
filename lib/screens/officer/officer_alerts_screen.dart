import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';

class OfficerAlertsScreen extends StatelessWidget {
  const OfficerAlertsScreen({super.key});

  final List<Map<String, dynamic>> _alerts = const [
    {
      'id': 'ALR-101',
      'title': 'SLA Breach Warning: #CMP-8492',
      'desc': 'Pothole complaint on University Road will exceed 24-hour resolution window in 2 hours.',
      'priority': 'CRITICAL',
      'time': '10 mins ago',
      'complaintId': '#CMP-8492',
      'icon': Icons.warning_amber_rounded,
      'isUnread': true,
    },
    {
      'id': 'ALR-102',
      'title': 'Emergency Signal Dispatch: #CMP-8493',
      'desc': 'Intersection traffic signal failure causing gridlock. Priority dispatch requested by City Police.',
      'priority': 'URGENT',
      'time': '45 mins ago',
      'complaintId': '#CMP-8493',
      'icon': Icons.fmd_bad,
      'isUnread': true,
    },
    {
      'id': 'ALR-103',
      'title': 'Resource Approved',
      'desc': 'Asphalt patcher crew #4 has been assigned to your sector queue.',
      'priority': 'INFO',
      'time': '3 hours ago',
      'complaintId': null,
      'icon': Icons.info_outline,
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Officer Alerts & SLA',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant, height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final isCritical = alert['priority'] == 'CRITICAL';
          final isUrgent = alert['priority'] == 'URGENT';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                if (alert['complaintId'] != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.officerComplaintDetails,
                    arguments: alert['complaintId'],
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCritical
                        ? const Color(0xFFBA1A1A).withAlpha(128)
                        : AppColors.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCritical
                            ? const Color(0xFFFFDAD6)
                            : isUrgent
                                ? const Color(0xFFFFDBCD)
                                : const Color(0xFFF3F3FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        alert['icon'] as IconData,
                        color: isCritical
                            ? const Color(0xFFBA1A1A)
                            : isUrgent
                                ? const Color(0xFFBC4800)
                                : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCritical
                                      ? const Color(0xFFFFDAD6)
                                      : isUrgent
                                          ? const Color(0xFFFFDBCD)
                                          : const Color(0xFFEDEDF9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  alert['priority'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCritical
                                        ? const Color(0xFFBA1A1A)
                                        : isUrgent
                                            ? const Color(0xFFBC4800)
                                            : AppColors.primary,
                                  ),
                                ),
                              ),
                              Text(
                                alert['time'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alert['title'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['desc'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
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
        },
      ),
    );
  }
}
