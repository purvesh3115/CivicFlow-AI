import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/ai_guided_flow_model.dart';
import '../../../providers/ai_assistant_provider.dart';

class CivicSafetyAlertsScreen extends StatelessWidget {
  const CivicSafetyAlertsScreen({super.key});

  void _callHelpline(BuildContext context, String number, String name) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Helpline $name ($number) copied to dialer.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiAssistantProvider>();
    final alerts = ai.safetyAlerts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Civic Safety & Advisories',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Hotlines Strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFDAD6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBA1A1A).withAlpha(12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.phone_in_talk_rounded, color: Color(0xFFBA1A1A), size: 20),
                        SizedBox(width: 8),
                        Text(
                          '24x7 Municipal Emergency Helplines',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBA1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickHelpline(
                          context,
                          label: 'Disaster',
                          number: '1077',
                          icon: Icons.flood_outlined,
                        ),
                        _buildQuickHelpline(
                          context,
                          label: 'Police',
                          number: '100',
                          icon: Icons.local_police_outlined,
                        ),
                        _buildQuickHelpline(
                          context,
                          label: 'Fire',
                          number: '101',
                          icon: Icons.fire_truck_outlined,
                        ),
                        _buildQuickHelpline(
                          context,
                          label: 'Municipal',
                          number: '1913',
                          icon: Icons.location_city_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Active Civic Bulletins & Warnings',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Alerts list
              ...alerts.map((alert) => _buildAlertCard(context, alert)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpline(
    BuildContext context, {
    required String label,
    required String number,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _callHelpline(context, number, label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFE4E6)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFBA1A1A)),
            const SizedBox(height: 4),
            Text(
              number,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBA1A1A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF9E1B1B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, CivicSafetyAlertModel alert) {
    Color bannerBg;
    Color bannerBorder;
    Color badgeColor;
    String badgeText;
    IconData icon;

    switch (alert.severity) {
      case SafetyAlertSeverity.urgent:
        bannerBg = const Color(0xFFFFF5F5);
        bannerBorder = const Color(0xFFFFDAD6);
        badgeColor = const Color(0xFFBA1A1A);
        badgeText = 'URGENT ADVISORY';
        icon = Icons.warning_rounded;
        break;
      case SafetyAlertSeverity.warning:
        bannerBg = const Color(0xFFFFFBEB);
        bannerBorder = const Color(0xFFFDE68A);
        badgeColor = const Color(0xFFB45309);
        badgeText = 'TRAFFIC DIVERSION';
        icon = Icons.traffic_rounded;
        break;
      case SafetyAlertSeverity.advisory:
        bannerBg = const Color(0xFFF0FDF4);
        bannerBorder = const Color(0xFFBBF7D0);
        badgeColor = const Color(0xFF15803D);
        badgeText = 'MAINTENANCE NOTICE';
        icon = Icons.info_outline_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bannerBorder),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: bannerBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  alert.area,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alert.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              alert.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Bullet points
            ...alert.advisoryPoints.map(
              (pt) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        pt,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Issued by: ${alert.issuedBy}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (alert.helplineNumber != null)
                  TextButton.icon(
                    onPressed: () => _callHelpline(context, alert.helplineNumber!, alert.title),
                    icon: const Icon(Icons.phone, size: 14),
                    label: Text(
                      'Dial ${alert.helplineNumber}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
