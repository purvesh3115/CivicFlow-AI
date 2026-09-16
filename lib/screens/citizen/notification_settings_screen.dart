import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final settings = notifProvider.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Notification Settings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Preferences',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage how and when you receive alerts from CitizenConnect.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Category 1: Complaint Status Updates
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assignment_late_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Complaint Status Updates',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingToggle(
                      title: 'Push Notifications',
                      subtitle: 'Receive instant alerts on your mobile device when complaint status changes.',
                      value: settings['push'] ?? true,
                      onChanged: (val) => notifProvider.updateSetting('push', val),
                    ),
                    const Divider(height: 1),
                    _SettingToggle(
                      title: 'Email Notifications',
                      subtitle: 'Get detailed updates and resolution certificates sent to your email.',
                      value: settings['email'] ?? true,
                      onChanged: (val) => notifProvider.updateSetting('email', val),
                    ),
                    const Divider(height: 1),
                    _SettingToggle(
                      title: 'SMS Alerts',
                      subtitle: 'Receive text message alerts for urgent complaint escalations.',
                      value: settings['sms'] ?? false,
                      onChanged: (val) => notifProvider.updateSetting('sms', val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category 2: Municipal Services & Schemes
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.campaign_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Services & Civic Alerts',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingToggle(
                      title: 'Government Scheme Announcements',
                      subtitle: 'Get notified when new subsidies, welfare benefits, or schemes launch.',
                      value: settings['schemes'] ?? true,
                      onChanged: (val) => notifProvider.updateSetting('schemes', val),
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

class _SettingToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
