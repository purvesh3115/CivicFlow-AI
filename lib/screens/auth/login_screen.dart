import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'purvesh@example.com');
  final _passwordController = TextEditingController(text: 'citizen123');
  UserRole _selectedRole = UserRole.citizen;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.citizen:
          _identifierController.text = 'purvesh@example.com';
          _passwordController.text = 'citizen123';
          break;
        case UserRole.officer:
          _identifierController.text = 'officer.rajesh@citizenconnect.gov.in';
          _passwordController.text = 'officer123';
          break;
        case UserRole.admin:
          _identifierController.text = 'admin@citizenconnect.gov.in';
          _passwordController.text = 'admin123';
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${authProvider.currentUser?.name}!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleContinueWithOtp() {
    final rawInput = _identifierController.text.trim();
    final phone = rawInput.isNotEmpty && !rawInput.contains('@')
        ? rawInput
        : '+91 98765 43210';
    Navigator.pushNamed(
      context,
      AppRoutes.otpVerification,
      arguments: {'phone': phone},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(120),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Civic Location Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Brand Header
                      Text(
                        'CitizenConnect',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back. Please log in to continue.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Role Selector for easy testing
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _RoleTab(
                              title: 'Citizen',
                              isSelected: _selectedRole == UserRole.citizen,
                              onTap: () => _onRoleChanged(UserRole.citizen),
                            ),
                            _RoleTab(
                              title: 'Officer',
                              isSelected: _selectedRole == UserRole.officer,
                              onTap: () => _onRoleChanged(UserRole.officer),
                            ),
                            _RoleTab(
                              title: 'Admin',
                              isSelected: _selectedRole == UserRole.admin,
                              onTap: () => _onRoleChanged(UserRole.admin),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Address Field
                      CustomTextField(
                        label: 'Email Address',
                        hintText: 'Enter your email address',
                        controller: _identifierController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        trailingLabelAction: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      PrimaryButton(
                        text: 'Login',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleLogin,
                        height: 50,
                      ),
                      const SizedBox(height: 18),

                      // OR Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.outline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Continue with OTP Button
                      SecondaryButton(
                        text: 'Continue with OTP',
                        icon: Icons.sms_outlined,
                        onPressed: _handleContinueWithOtp,
                        height: 50,
                        borderColor: AppColors.primary,
                      ),
                      const SizedBox(height: 24),

                      // Register Link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: Text(
                                'Register',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _RoleTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
