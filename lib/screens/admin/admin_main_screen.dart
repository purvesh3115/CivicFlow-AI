import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'admin_analytics_screen.dart';
import 'admin_auto_assign_screen.dart';
import 'admin_complaints_screen.dart';
import 'admin_home_screen.dart';
import 'admin_profile_screen.dart';
import 'manage_officers_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialTab;

  const AdminMainScreen({super.key, this.initialTab = 0});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      AdminHomeScreen(onNavigateTab: _onTabSelected),
      const AdminComplaintsScreen(),
      const AdminAutoAssignScreen(),
      const ManageOfficersScreen(),
      const AdminAnalyticsScreen(),
      const AdminProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withAlpha(70),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
                _buildNavItem(1, Icons.assignment_outlined, 'Complaints'),
                _buildNavItem(2, Icons.smart_toy_rounded, 'Auto Assign'),
                _buildNavItem(3, Icons.badge_outlined, 'Officers'),
                _buildNavItem(4, Icons.analytics_outlined, 'Analytics'),
                _buildNavItem(5, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
