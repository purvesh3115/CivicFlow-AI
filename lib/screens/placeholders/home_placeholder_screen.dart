import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';

class HomePlaceholderScreen extends StatelessWidget {
  final UserRole role;

  const HomePlaceholderScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    String title;
    Color headerColor;
    IconData icon;

    switch (role) {
      case UserRole.admin:
        title = 'City Administration Console';
        headerColor = const Color(0xFF1E293B);
        icon = Icons.admin_panel_settings_rounded;
        break;
      case UserRole.officer:
        title = 'Officer Field Suite';
        headerColor = const Color(0xFF0F766E);
        icon = Icons.engineering_rounded;
        break;
      case UserRole.citizen:
        title = 'CitizenConnect Dashboard';
        headerColor = AppColors.primary;
        icon = Icons.location_city_rounded;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: title,
        showBrandLogo: role == UserRole.citizen,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.onSurface),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: headerColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 38, color: headerColor),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Welcome, ${user?.name ?? 'User'}!',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: headerColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user?.role.displayName.toUpperCase() ??
                              role.displayName.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: headerColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Phase 1 Authentication & Routing Verified Successfully.\nReady for Phase 2 implementation.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Phone / ID', value: user?.phone ?? 'N/A'),
                            const SizedBox(height: 6),
                            _InfoRow(label: 'Email', value: user?.email ?? 'N/A'),
                            const SizedBox(height: 6),
                            _InfoRow(label: 'City / Ward', value: user?.city ?? 'N/A'),
                            if (user?.department != null) ...[
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Department',
                                value: user!.department!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Sign Out to Test Another Role',
                        backgroundColor: headerColor,
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        },
                        height: 48,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
