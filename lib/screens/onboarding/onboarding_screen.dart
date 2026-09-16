import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.cell_tower_rounded,
      secondaryIcon: Icons.report_problem_rounded,
      badgeText: 'INSTANT CIVIC REPORTING',
      title: 'Report Civic Issues Easily',
      description:
          'Report problems in your area—potholes, garbage, water leaks—and help improve your community in just a few taps.',
      tagColor: AppColors.primaryContainer,
    ),
    _OnboardingPageData(
      icon: Icons.timeline_rounded,
      secondaryIcon: Icons.verified_rounded,
      badgeText: 'REAL-TIME TRANSPARENCY',
      title: 'Track Every Complaint',
      description:
          'Stay informed with real-time status updates from submission, officer dispatch, to complete resolution with photo proof.',
      tagColor: Color(0xFF7C3AED),
    ),
    _OnboardingPageData(
      icon: Icons.account_balance_rounded,
      secondaryIcon: Icons.verified_user_rounded,
      badgeText: 'MUNICIPAL BENEFITS',
      title: 'Access Government Services',
      description:
          'Discover municipal schemes, check eligibility criteria, and manage digital identity certificates securely.',
      tagColor: Color(0xFF0D9488),
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await context.read<AuthProvider>().markOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decorative visual card / illustration badge
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: page.tagColor.withAlpha(50),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.tagColor.withAlpha(35),
                                  blurRadius: 36,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Inner subtle glowing circle
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: page.tagColor.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Primary Hero Icon
                                Icon(
                                  page.icon,
                                  size: 72,
                                  color: page.tagColor,
                                ),
                                // Secondary Accent Badge
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      page.secondaryIcon,
                                      size: 22,
                                      color: page.tagColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: page.tagColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              page.badgeText,
                              style: AppTypography.labelSmall.copyWith(
                                color: page.tagColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Title
                          Text(
                            page.title,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            page.description,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom controls: Indicators and Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Get Started button
                  PrimaryButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _onNext,
                    height: 54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final IconData secondaryIcon;
  final String badgeText;
  final String title;
  final String description;
  final Color tagColor;

  const _OnboardingPageData({
    required this.icon,
    required this.secondaryIcon,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.tagColor,
  });
}
