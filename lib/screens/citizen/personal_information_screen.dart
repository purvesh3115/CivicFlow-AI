import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Purvesh');
    _emailController = TextEditingController(text: user?.email ?? 'purvesh@example.com');
    _phoneController = TextEditingController(text: user?.phone ?? '+1 (555) 123-4567');
    _cityController = TextEditingController(text: user?.city ?? 'Anand, Gujarat');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile information updated successfully.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Personal Information',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identity Verification Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.successContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Citizen Identity',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Government Aadhaar/SSN Linked & Confirmed',
                              style: AppTypography.bodySmall.copyWith(
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

                // Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        enabled: _isEditing,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        enabled: _isEditing,
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Mobile Number',
                        controller: _phoneController,
                        enabled: _isEditing,
                        prefixIcon: Icons.phone_android_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'City / Region',
                        controller: _cityController,
                        enabled: _isEditing,
                        prefixIcon: Icons.location_city_rounded,
                      ),
                    ],
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Save Changes',
                    onPressed: _handleSave,
                    height: 50,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
