import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateAfterDelay();
      }
    });
  }

  Future<void> _navigateAfterDelay() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();

    // Ensure splash has at least 2.2 seconds for branding
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      switch (authProvider.currentUser!.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case UserRole.officer:
          Navigator.pushReplacementNamed(context, AppRoutes.officerDashboard);
          break;
        case UserRole.citizen:
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          break;
      }
    } else if (authProvider.hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background skyline silhouette overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _CitySkylinePainter(),
              ),
            ),
          ),

          // Main Center Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Container
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          Container(
                            width: 110 * _pulseAnimation.value,
                            height: 110 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withAlpha(60),
                                width: 2,
                              ),
                            ),
                          ),
                          // Inner circle with icon
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(40),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_city_rounded,
                              size: 46,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Brand Name
                  RichText(
                    text: TextSpan(
                      text: 'Citizen',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: 'Connect',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Your Voice. Your City. Your Connection.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ),

          // Bottom Bouncing Loading Dots
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BouncingDot(delay: 0, controller: _animController),
                const SizedBox(width: 8),
                _BouncingDot(delay: 150, controller: _animController),
                const SizedBox(width: 8),
                _BouncingDot(delay: 300, controller: _animController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatelessWidget {
  final int delay;
  final AnimationController controller;

  const _BouncingDot({required this.delay, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double sinVal = (controller.value * 2 * 3.14159) + (delay / 100);
        final double offsetY = 4 * (1 - (sinVal.abs() % 1.0));
        return Transform.translate(
          offset: Offset(0, -offsetY),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _CitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.lineTo(size.width * 0.15, size.height * 0.55);
    path.lineTo(size.width * 0.3, size.height * 0.55);
    path.lineTo(size.width * 0.3, size.height * 0.65);
    path.lineTo(size.width * 0.45, size.height * 0.65);
    path.lineTo(size.width * 0.45, size.height * 0.48);
    path.lineTo(size.width * 0.6, size.height * 0.48);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.52);
    path.lineTo(size.width * 0.9, size.height * 0.52);
    path.lineTo(size.width * 0.9, size.height * 0.68);
    path.lineTo(size.width, size.height * 0.68);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
