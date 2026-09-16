import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<bool> hasSeenOnboarding() => _authService.hasSeenOnboarding();
  Future<void> setOnboardingSeen(bool seen) => _authService.setOnboardingSeen(seen);
  Future<UserModel?> getCurrentUser() => _authService.getCurrentUser();
  Future<String?> getAuthToken() => _authService.getAuthToken();

  Future<AuthResponse> login({
    required String mobileOrEmail,
    required String password,
    UserRole? role,
  }) =>
      _authService.login(
        mobileOrEmail: mobileOrEmail,
        password: password,
        requestedRole: role,
      );

  Future<AuthResponse> register({
    required String name,
    required String mobile,
    required String email,
    required String city,
    required String password,
  }) =>
      _authService.register(
        name: name,
        mobile: mobile,
        email: email,
        city: city,
        password: password,
      );

  Future<void> sendPhoneOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
    required void Function(dynamic credential) onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) =>
      _authService.sendPhoneOtp(
        phone: phone,
        onCodeSent: onCodeSent,
        onVerificationFailed: onVerificationFailed,
        onVerificationCompleted: onVerificationCompleted,
        onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        forceResendingToken: forceResendingToken,
      );

  Future<AuthResponse> signInWithPhoneCredential({
    required dynamic credential,
    required String phone,
    UserModel? pendingUser,
  }) =>
      _authService.signInWithPhoneCredential(
        credential: credential,
        phone: phone,
        pendingUser: pendingUser,
      );

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    String? verificationId,
    UserModel? pendingUser,
  }) =>
      _authService.verifyOtp(
        phone: phone,
        otp: otp,
        verificationId: verificationId,
        pendingUser: pendingUser,
      );

  Future<bool> sendPasswordReset(String identifier) =>
      _authService.sendPasswordReset(identifier: identifier);

  Future<void> logout() => _authService.logout();
}
