import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';

class OfficerProfileScreen extends StatefulWidget {
  const OfficerProfileScreen({super.key});

  @override
  State<OfficerProfileScreen> createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  bool _isOnDuty = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final complaintProvider = context.watch<ComplaintProvider>();

    final officerName = user?.name ?? 'Officer Rajesh Sharma';
    final officerBadge = user?.badgeNumber ?? 'OFF-RD-402';
    final officerDept = user?.department ?? 'Roads & Infrastructure';

    final assignedCount = complaintProvider.complaints
        .where((c) =>
            c.assignedOfficerName?.contains('Rajesh') == true ||
            c.status.toLowerCase() == 'in progress' ||
            c.status.toLowerCase() == 'submitted')
        .length;
    final inProgressCount = complaintProvider.inProgressCount;
    final resolvedCount = complaintProvider.resolvedCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Officer Profile',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Officer Badge Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004AC6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004AC6).withAlpha(64),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.badge, color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              officerName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Senior Field Inspector',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDBE1FF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              officerDept,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFFDBE1FF),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Badge ID: #$officerBadge',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  // Duty Status Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _isOnDuty ? const Color(0xFF4ADE80) : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isOnDuty ? 'ON ACTIVE DUTY' : 'OFF DUTY',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOnDuty,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF4ADE80),
                        onChanged: (val) => setState(() => _isOnDuty = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Performance Stats Grid
            Row(
              children: [
                _buildStatBox('Assigned', (assignedCount > 0 ? assignedCount : 12).toString(), AppColors.primary),
                const SizedBox(width: 10),
                _buildStatBox('In Progress', (inProgressCount > 0 ? inProgressCount : 7).toString(), const Color(0xFFBC4800)),
                const SizedBox(width: 10),
                _buildStatBox('Resolved', (resolvedCount > 0 ? resolvedCount : 48).toString(), const Color(0xFF006A63)),
              ],
            ),

            const SizedBox(height: 20),

            // Details List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: const Column(
                children: [
                  _OfficerDetailRow(
                    icon: Icons.domain,
                    label: 'Department',
                    value: 'Roads & Public Infrastructure',
                  ),
                  Divider(height: 20, color: AppColors.outlineVariant),
                  _OfficerDetailRow(
                    icon: Icons.map,
                    label: 'Assigned Zone',
                    value: 'Sector A - Central Anand',
                  ),
                  Divider(height: 20, color: AppColors.outlineVariant),
                  _OfficerDetailRow(
                    icon: Icons.timer,
                    label: 'SLA Compliance',
                    value: '96.4% on-time',
                  ),
                  Divider(height: 20, color: AppColors.outlineVariant),
                  _OfficerDetailRow(
                    icon: Icons.phone,
                    label: 'Direct Dispatch',
                    value: '+91 98765 43210',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Demo Persona Switcher Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Demo Persona Switcher',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Instantly simulate app behavior from another municipal user persona:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('persona_switch_citizen'),
                          onPressed: () {
                            authProvider.switchPersona(UserRole.citizen);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.person, size: 16),
                          label: const Text('Citizen'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
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

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                key: const Key('officer_logout_button'),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBA1A1A),
                  side: const BorderSide(color: Color(0xFFBA1A1A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OfficerDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
