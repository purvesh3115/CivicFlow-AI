import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'officer_alerts_screen.dart';
import 'officer_complaints_list_screen.dart';
import 'officer_dashboard_screen.dart';
import 'officer_field_map_screen.dart';
import 'officer_profile_screen.dart';

class OfficerMainScreen extends StatefulWidget {
  final int initialTab;

  const OfficerMainScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<OfficerMainScreen> createState() => _OfficerMainScreenState();
}

class _OfficerMainScreenState extends State<OfficerMainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    OfficerDashboardScreen(),
    OfficerComplaintsListScreen(),
    OfficerFieldMapScreen(),
    OfficerAlertsScreen(),
    OfficerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.list_alt, 'Complaints'),
                _buildNavItem(2, Icons.map, 'Map'),
                _buildNavItem(3, Icons.notifications, 'Alerts', hasBadge: true),
                _buildNavItem(4, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool hasBadge = false}) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF99EFE5) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? const Color(0xFF006F67) : AppColors.textSecondary,
                  ),
                  if (hasBadge)
                    Positioned(
                      top: -1,
                      right: -3,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBA1A1A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
