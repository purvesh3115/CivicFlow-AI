import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/models/auth_response.dart';
import 'package:citizen_connect/models/user_model.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/repositories/auth_repository.dart';
import 'package:citizen_connect/screens/auth/otp_verification_screen.dart';
import 'package:citizen_connect/services/auth_service.dart';

class MockAuthRepository extends AuthRepository {
  bool sendOtpCalled = false;
  bool verifyOtpCalled = false;
  String? lastPhoneSent;
  String? lastOtpVerified;

  @override
  Future<void> sendPhoneOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
    required void Function(dynamic credential) onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    sendOtpCalled = true;
    lastPhoneSent = phone;
    onCodeSent('test_verification_id_123', 9999);
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    String? verificationId,
    UserModel? pendingUser,
  }) async {
    verifyOtpCalled = true;
    lastOtpVerified = otp;

    if (otp == '123456') {
      return AuthResponse(
        success: true,
        message: 'Verified',
        token: 'test_token',
        user: pendingUser ??
            UserModel(
              id: 'usr_test_verified',
              name: 'Test Citizen',
              phone: phone,
              email: 'test@citizenconnect.gov.in',
              role: UserRole.citizen,
              createdAt: DateTime.now(),
            ),
      );
    } else {
      return AuthResponse(
        success: false,
        message: 'Invalid OTP code',
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 13: Phone Auth Service Unit Tests', () {
    test('formatPhoneNumber formats local 10-digit and international numbers',
        () {
      final authService = AuthService();

      expect(authService.formatPhoneNumber('9876543210'), '+919876543210');
      expect(
          authService.formatPhoneNumber('+91 98765 43210'), '+919876543210');
      expect(
          authService.formatPhoneNumber('+1 (555) 123-4567'), '+15551234567');
      expect(authService.formatPhoneNumber('  9123456789 '), '+919123456789');
    });

    test('sendPhoneOtp dispatches codeSent with verificationId in test/offline',
        () async {
      final authService = AuthService();
      String? receivedVid;

      await authService.sendPhoneOtp(
        phone: '9876543210',
        onCodeSent: (vid, token) {
          receivedVid = vid;
        },
        onVerificationFailed: (err) {},
        onVerificationCompleted: (cred) {},
      );

      expect(receivedVid, isNotNull);
      expect(receivedVid!.startsWith('simulated_vid_'), true);
    });

    test('verifyOtp returns successful AuthResponse and saves session',
        () async {
      final authService = AuthService();
      final pendingUser = UserModel(
        id: 'usr_new_99',
        name: 'Aarav Patel',
        phone: '+919876543210',
        email: 'aarav@example.com',
        role: UserRole.citizen,
        city: 'Anand, Gujarat',
        createdAt: DateTime.now(),
      );

      final response = await authService.verifyOtp(
        phone: '9876543210',
        otp: '123456',
        pendingUser: pendingUser,
      );

      expect(response.success, true);
      expect(response.user?.name, 'Aarav Patel');
      expect(response.token, isNotNull);

      // Verify session was saved in prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_logged_in'), true);
    });
  });

  group('Phase 13: AuthProvider Phone Auth Integration Tests', () {
    test('sendPhoneOtp populates verificationId and resendToken', () async {
      final mockRepo = MockAuthRepository();
      final provider = AuthProvider(repository: mockRepo);

      expect(provider.verificationId, isNull);
      expect(provider.isPhoneAuthSending, false);

      await provider.sendPhoneOtp(phone: '+919876543210');

      expect(mockRepo.sendOtpCalled, true);
      expect(mockRepo.lastPhoneSent, '+919876543210');
      expect(provider.verificationId, 'test_verification_id_123');
      expect(provider.resendToken, 9999);
      expect(provider.isPhoneAuthSending, false);
    });

    test('verifyOtp authenticates user and updates state', () async {
      final mockRepo = MockAuthRepository();
      final provider = AuthProvider(repository: mockRepo);

      final success = await provider.verifyOtp(
        phone: '+919876543210',
        otp: '123456',
        verificationId: 'test_verification_id_123',
      );

      expect(success, true);
      expect(mockRepo.verifyOtpCalled, true);
      expect(mockRepo.lastOtpVerified, '123456');
      expect(provider.currentUser?.name, 'Test Citizen');
      expect(provider.isAuthenticated, true);
    });

    test('verifyOtp handles failure gracefully', () async {
      final mockRepo = MockAuthRepository();
      final provider = AuthProvider(repository: mockRepo);

      final success = await provider.verifyOtp(
        phone: '+919876543210',
        otp: '000000',
      );

      expect(success, false);
      expect(provider.errorMessage, 'Invalid OTP code');
      expect(provider.isAuthenticated, false);
    });
  });

  group('Phase 13: OtpVerificationScreen Widget Tests', () {
    testWidgets('OtpVerificationScreen triggers sendPhoneOtp on mount and renders UI',
        (tester) async {
      final mockRepo = MockAuthRepository();
      final provider = AuthProvider(repository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const OtpVerificationScreen(
              phone: '+91 98765 43210',
              userName: 'Test Citizen',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(mockRepo.sendOtpCalled, true);
      expect(find.text('Verification'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is RichText &&
            w.text.toPlainText().contains('+91 98765 43210')),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('Verify'), findsOneWidget);
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen enters OTP and verifies successfully',
        (tester) async {
      final mockRepo = MockAuthRepository();
      final provider = AuthProvider(repository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home': (_) => const Scaffold(body: Text('Home Screen')),
            '/admin/dashboard': (_) => const Scaffold(body: Text('Admin Dashboard')),
            '/officer/dashboard': (_) => const Scaffold(body: Text('Officer Dashboard')),
          },
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: provider,
            child: const OtpVerificationScreen(
              phone: '+91 98765 43210',
              userName: 'Test Citizen',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter 6-digit OTP code into the 6 CustomOtpField digit boxes
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');
      await tester.enterText(textFields.at(4), '5');
      await tester.enterText(textFields.at(5), '6');
      await tester.pumpAndSettle();

      // Entering all 6 digits triggers onCompleted -> auto-submits verification
      expect(mockRepo.verifyOtpCalled, true);
      expect(mockRepo.lastOtpVerified, '123456');
      expect(provider.isAuthenticated, true);
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
