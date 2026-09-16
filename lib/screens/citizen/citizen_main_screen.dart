import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'ai/ai_assistant_home_screen.dart';
import 'complaints/complaints_list_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'services/government_services_screen.dart';

class CitizenMainScreen extends StatefulWidget {
  final int initialTab;

  const CitizenMainScreen({super.key, this.initialTab = 0});

  @override
  State<CitizenMainScreen> createState() => _CitizenMainScreenState();
}

class _CitizenMainScreenState extends State<CitizenMainScreen> {
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
      HomeScreen(onNavigateTab: _onTabSelected),
      const ComplaintsListScreen(),
      const GovernmentServicesScreen(),
      const AiAssistantHomeScreen(),
      const ProfileScreen(),
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
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: AppColors.outlineVariant.withAlpha(60),
            width: 0.8,
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabSelected(0),
                ),
                _NavBarItem(
                  icon: Icons.report_problem_outlined,
                  label: 'Complaints',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabSelected(1),
                ),
                _NavBarItem(
                  icon: Icons.account_balance_outlined,
                  label: 'Services',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabSelected(2),
                ),
                _NavBarItem(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabSelected(3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 4,
                  onTap: () => _onTabSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

