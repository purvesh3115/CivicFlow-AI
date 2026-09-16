import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of CitizenConnect?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notificationSettings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Profile Header Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceContainerLowest,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty == true ? user!.name[0] : 'P')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surfaceContainerLowest,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Purvesh',
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user?.city ?? 'Central District, Cityville',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demo Persona Switcher Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Persona Switcher',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Instantly test the app experience across different municipal user roles:',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('persona_switch_officer'),
                            onPressed: () {
                              authProvider.switchPersona(UserRole.officer);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.officerDashboard,
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.shield_outlined, size: 16),
                            label: const Text('Officer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF006A63),
                              side: const BorderSide(color: Color(0xFF006A63)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('persona_switch_admin'),
                            onPressed: () {
                              authProvider.switchPersona(UserRole.admin);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.adminDashboard,
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                            label: const Text('Admin'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF004AC6),
                              side: const BorderSide(color: Color(0xFF004AC6)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                    width: 0.8,
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
                    // Personal Information
                    _ProfileMenuItem(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      iconBgColor: AppColors.primaryFixed,
                      iconColor: AppColors.onPrimaryFixedVariant,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.personalInfo);
                      },
                    ),
                    const Divider(height: 1),

                    // My Documents & Certificates
                    _ProfileMenuItem(
                      title: 'My Documents & Certificates',
                      icon: Icons.description_outlined,
                      iconBgColor: AppColors.secondaryFixed,
                      iconColor: AppColors.secondary,
                      badgeText: '5 Verified',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.myDocuments);
                      },
                    ),
                    const Divider(height: 1),

                    // Notification Settings
                    _ProfileMenuItem(
                      title: 'Notification Settings',
                      icon: Icons.notifications_outlined,
                      iconBgColor: AppColors.tertiaryFixed,
                      iconColor: AppColors.tertiary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notificationSettings);
                      },
                    ),
                    const Divider(height: 1),

                    // Security & Privacy
                    _ProfileMenuItem(
                      title: 'Security & Privacy',
                      icon: Icons.security_outlined,
                      iconBgColor: AppColors.surfaceVariant,
                      iconColor: AppColors.onSurfaceVariant,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Security & Biometrics: All civic data encrypted with AES-256.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Help & Support
                    _ProfileMenuItem(
                      title: 'Help & Support',
                      icon: Icons.help_outline_rounded,
                      iconBgColor: AppColors.surfaceContainerHigh,
                      iconColor: AppColors.onSurfaceVariant,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Civic Helpline: 1800-11-2026 (Toll-Free, 24x7)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Logout
                    _ProfileMenuItem(
                      title: 'Log Out',
                      icon: Icons.logout_rounded,
                      iconBgColor: AppColors.errorContainer,
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      showChevron: false,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color? textColor;
  final String? badgeText;
  final bool showChevron;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.textColor,
    this.badgeText,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: textColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText!,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (showChevron)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
              size: 20,
            ),
        ],
      ),
    );
  }
}
