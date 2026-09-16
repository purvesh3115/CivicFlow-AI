import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_otp_field.dart';
import '../../widgets/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String? userName;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.userName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';
  int _countdownSeconds = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp(isResend: false);
    });
  }

  void _startTimer() {
    setState(() {
      _countdownSeconds = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendPhoneOtp(
      phone: widget.phone,
      isResend: isResend,
      onCodeSent: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Verification code sent via SMS to ${widget.phone}.'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToDashboard(UserRole? role) {
    if (role == UserRole.admin) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.adminDashboard,
        (route) => false,
      );
    } else if (role == UserRole.officer) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.officerDashboard,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  Future<void> _handleVerify() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the verification code.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      phone: widget.phone,
      otp: _otp,
      verificationId: authProvider.verificationId,
      pendingUser: authProvider.pendingUser ??
          (widget.userName != null && widget.userName!.isNotEmpty
              ? UserModel(
                  id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                  name: widget.userName!,
                  phone: widget.phone,
                  email:
                      '${widget.userName!.toLowerCase().replaceAll(' ', '')}@citizenconnect.gov.in',
                  role: UserRole.citizen,
                  city: 'Anand, Gujarat',
                  createdAt: DateTime.now(),
                )
              : null),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _navigateToDashboard(authProvider.currentUser?.role);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Verification failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleResend() {
    if (!_canResend) return;
    _startTimer();
    _sendOtp(isResend: true);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAutoVerified && authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateToDashboard(authProvider.currentUser?.role);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phonelink_lock_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      'Verification',
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle with Phone
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            'Enter the 6-digit code sent to your mobile number\n',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: widget.phone,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SMS Sending Indicator
                    if (authProvider.isPhoneAuthSending)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sending SMS verification code...',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 6-digit OTP Field
                    CustomOtpField(
                      length: 6,
                      onChanged: (val) => _otp = val,
                      onCompleted: (val) {
                        _otp = val;
                        _handleVerify();
                      },
                    ),
                    const SizedBox(height: 28),

                    // Verify Button
                    PrimaryButton(
                      text: 'Verify',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleVerify,
                      height: 52,
                    ),
                    const SizedBox(height: 22),

                    // Resend Timer
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: _canResend ? _handleResend : null,
                          child: Text(
                            _canResend
                                ? 'Resend OTP'
                                : 'Resend OTP (${_countdownSeconds.toString().padLeft(2, '0')}s)',
                            style: AppTypography.labelMedium.copyWith(
                              color: _canResend
                                  ? AppColors.primary
                                  : AppColors.outline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Change Number
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Change number',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
