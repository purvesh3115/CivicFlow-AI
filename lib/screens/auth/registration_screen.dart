import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCity = 'Downtown District';
  String? _selectedLocationType = 'Residential Area';

  final List<String> _cities = [
    'Downtown District',
    'Northside Borough',
    'East End',
    'West Hills',
    'South Suburbs',
    'Anand Central',
  ];

  final List<String> _locationTypes = [
    'Residential Area',
    'Commercial District',
    'Industrial Zone',
    'Suburban Ward',
    'Rural / Gram Panchayat',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      city: _selectedCity ?? 'Downtown District',
      locationType: _selectedLocationType,
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please verify your mobile number.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushNamed(
        context,
        AppRoutes.otpVerification,
        arguments: {
          'phone': _mobileController.text.trim(),
          'userName': _nameController.text.trim(),
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBrandLogo: true,
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Sign In',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Create Account',
                              style: AppTypography.headlineLarge.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Join CitizenConnect to engage with your local government.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full Name
                      CustomTextField(
                        label: 'Full Name',
                        isRequired: true,
                        hintText: 'Jane Doe',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) =>
                            Validators.validateRequired(val, 'Full Name'),
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number
                      CustomTextField(
                        label: 'Mobile Number',
                        isRequired: true,
                        hintText: '(555) 123-4567',
                        controller: _mobileController,
                        prefixIcon: Icons.phone_iphone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validateMobile,
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      CustomTextField(
                        label: 'Email Address',
                        isRequired: true,
                        hintText: 'jane.doe@example.com',
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // City / Region Dropdown
                      Row(
                        children: [
                          Text(
                            'City / Region',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            ' *',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCity,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onSurface,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select a City / Region'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.map_outlined,
                            color: AppColors.outline,
                            size: 20,
                          ),
                          fillColor: AppColors.surfaceContainerLowest,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: _cities
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(
                                    city,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location Type Dropdown
                      Row(
                        children: [
                          Text(
                            'Location Type',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            ' *',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedLocationType,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onSurface,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please select a Location Type'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.location_city_rounded,
                            color: AppColors.outline,
                            size: 20,
                          ),
                          fillColor: AppColors.surfaceContainerLowest,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: _locationTypes
                            .map((loc) => DropdownMenuItem(
                                  value: loc,
                                  child: Text(
                                    loc,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedLocationType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        label: 'Password',
                        isRequired: true,
                        hintText: 'Create password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      CustomTextField(
                        label: 'Confirm Password',
                        isRequired: true,
                        hintText: 'Re-enter password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_clock_outlined,
                        validator: (val) => Validators.validateConfirmPassword(
                          val,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      PrimaryButton(
                        text: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleRegister,
                        height: 52,
                      ),
                      const SizedBox(height: 20),

                      // Sign In link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
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
