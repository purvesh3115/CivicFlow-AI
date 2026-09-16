import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _currentUser;
  UserModel? _pendingUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;

  // Firebase Phone Auth State
  String? _verificationId;
  int? _resendToken;
  bool _isPhoneAuthSending = false;
  bool _isAutoVerified = false;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  UserModel? get currentUser => _currentUser;
  UserModel? get pendingUser => _pendingUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isAuthenticated => _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.citizen;

  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;
  bool get isPhoneAuthSending => _isPhoneAuthSending;
  bool get isAutoVerified => _isAutoVerified;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasSeenOnboarding = await _repository.hasSeenOnboarding();
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    await _repository.setOnboardingSeen(true);
    notifyListeners();
  }

  Future<bool> login({
    required String identifier,
    required String password,
    UserRole? role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.login(
        mobileOrEmail: identifier,
        password: password,
        role: role,
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String mobile,
    required String email,
    required String city,
    required String password,
    String? locationType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.register(
        name: name,
        mobile: mobile,
        email: email,
        city: locationType != null ? '$city ($locationType)' : city,
        password: password,
      );

      if (response.success) {
        _pendingUser = response.user?.copyWith(locationType: locationType) ??
            UserModel(
              id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              phone: mobile,
              email: email,
              city: city,
              locationType: locationType,
              role: UserRole.citizen,
              createdAt: DateTime.now(),
            );
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Dispatches real SMS OTP via Firebase Phone Auth
  Future<void> sendPhoneOtp({
    required String phone,
    VoidCallback? onCodeSent,
    void Function(String error)? onError,
    bool isResend = false,
  }) async {
    _isPhoneAuthSending = true;
    _isAutoVerified = false;
    _clearError();
    notifyListeners();

    try {
      await _repository.sendPhoneOtp(
        phone: phone,
        forceResendingToken: isResend ? _resendToken : null,
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isPhoneAuthSending = false;
          notifyListeners();
          onCodeSent?.call();
        },
        onVerificationFailed: (error) {
          _errorMessage = error;
          _isPhoneAuthSending = false;
          notifyListeners();
          onError?.call(error);
        },
        onVerificationCompleted: (credential) async {
          _isPhoneAuthSending = false;
          _isAutoVerified = true;
          // Auto sign in on Android device
          try {
            final authResp = await _repository.signInWithPhoneCredential(
              credential: credential,
              phone: phone,
              pendingUser: _pendingUser,
            );
            if (authResp.success && authResp.user != null) {
              _currentUser = authResp.user;
              _pendingUser = null;
            }
          } catch (_) {}
          notifyListeners();
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isPhoneAuthSending = false;
      notifyListeners();
      onError?.call(e.toString());
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    String? verificationId,
    UserModel? pendingUser,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final targetPending = pendingUser ?? _pendingUser;
      final targetVerificationId = verificationId ?? _verificationId;

      final response = await _repository.verifyOtp(
        phone: phone,
        otp: otp,
        verificationId: targetVerificationId,
        pendingUser: targetPending,
      );

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _pendingUser = null;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void switchPersona(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        _currentUser = UserModel(
          id: 'cit_303',
          name: _currentUser?.role == UserRole.citizen ? _currentUser!.name : 'Purvesh',
          phone: _currentUser?.phone ?? '+91 98765 43210',
          email: _currentUser?.email ?? 'purvesh@example.com',
          role: UserRole.citizen,
          city: _currentUser?.city ?? 'Anand, Gujarat',
          createdAt: DateTime.now(),
        );
        break;
      case UserRole.officer:
        _currentUser = UserModel(
          id: 'off_202',
          name: 'Officer Rajesh Sharma',
          phone: '+91 98765 00001',
          email: 'officer.rajesh@citizenconnect.gov.in',
          role: UserRole.officer,
          city: 'Zone 4, Anand',
          department: 'Roads & Infrastructure',
          badgeNumber: 'OFF-RD-402',
          createdAt: DateTime.now(),
        );
        break;
      case UserRole.admin:
        _currentUser = UserModel(
          id: 'adm_101',
          name: 'Dr. Neha Patel',
          phone: '+91 98765 11111',
          email: 'admin@citizenconnect.gov.in',
          role: UserRole.admin,
          city: 'Central Municipal HQ',
          department: 'Municipal Administration',
          badgeNumber: 'ADM-EXEC-001',
          createdAt: DateTime.now(),
        );
        break;
    }
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String identifier) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.sendPasswordReset(identifier);
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _repository.logout();
    _currentUser = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
