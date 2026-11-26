import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/features/auth/data/auth_repository.dart';
import 'package:inclusive_dating/features/auth/data/secure_token_storage.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/signup_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:inclusive_dating/features/verification/data/document_quality_analyzer.dart';
import 'package:inclusive_dating/features/verification/data/government_id_repository.dart';
import 'package:inclusive_dating/features/verification/domain/models/government_id_model.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/government_id_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Uint8List> _createTestPngBytes({
  required int width,
  required int height,
  required Color fillColor,
  bool drawTextGrid = true,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = fillColor,
  );
  if (drawTextGrid) {
    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    for (int x = 16; x < width - 16; x += 18) {
      canvas.drawLine(
        Offset(x.toDouble(), 14),
        Offset(x.toDouble(), height - 14.0),
        strokePaint,
      );
    }
    for (int y = 14; y < height - 14; y += 16) {
      canvas.drawLine(
        Offset(14, y.toDouble()),
        Offset(width - 14.0, y.toDouble()),
        strokePaint,
      );
    }
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return byteData!.buffer.asUint8List();
}

void main() {
  group('Module 1: Username, Password, Token Storage & Mock Auth Repository', () {
    late MockAuthRepository repo;

    setUp(() {
      repo = MockAuthRepository();
    });

    test('Configurable username validation normalizes lowercase & enforces rules', () {
      const cfg = UsernameValidationConfig(minLength: 4, maxLength: 15);
      expect(cfg.normalize('  Ananya_24 '), 'ananya_24');
      expect(cfg.validate('abc'), isNotNull); // too short for min 4
      expect(cfg.validate('a' * 16), isNotNull); // too long
      expect(cfg.validate('bad-char!'), isNotNull); // invalid punctuation
      expect(cfg.validate('Ananya_24'), isNull); // normalizes lowercase & passes
    });

    test('Password policy validates length, uppercase, digit, symbol & strength', () {
      const policy = PasswordValidationConfig();
      final noneSatisfied = policy.evaluate('abc');
      expect(noneSatisfied.isSatisfied, isFalse);
      expect(noneSatisfied.label, '');

      final weak = policy.evaluate('abcdefgh');
      expect(weak.isSatisfied, isFalse);
      expect(weak.label, 'Weak');

      final mod = policy.evaluate('Abcdefg1');
      expect(mod.isSatisfied, isFalse);
      expect(mod.label, 'Moderate');

      final strong = policy.evaluate('Date2Secure!2026');
      expect(strong.isSatisfied, isTrue);
      expect(strong.label, 'Strong');
    });

    test('Username availability detects taken, available & simulated network error', () async {
      expect(
        await repo.checkUsernameAvailability('admin'),
        UsernameAvailabilityStatus.taken,
      );
      expect(
        await repo.checkUsernameAvailability('ananya_star'),
        UsernameAvailabilityStatus.available,
      );
      expect(
        await repo.checkUsernameAvailability('hi'),
        UsernameAvailabilityStatus.none,
      );
      expect(
        () => repo.checkUsernameAvailability('error_check'),
        throwsException,
      );
    });

    test('Signup registers mock account, login validates password, reset updates password', () async {
      final registered = await repo.registerUser(
        username: 'maya_25',
        email: 'maya@date2.app',
        password: 'OldPassword!2026',
      );
      expect(registered, isTrue);

      // Duplicate username or email cannot overwrite existing/seeded account
      expect(
        await repo.registerUser(
          username: 'maya_25',
          email: 'other@date2.app',
          password: 'OldPassword!2026',
        ),
        isFalse,
      );
      expect(
        await repo.registerUser(
          username: 'new_handle',
          email: 'demo.verified@date2.app',
          password: 'OldPassword!2026',
        ),
        isFalse,
      );

      // Wrong password rejected
      expect(
        await repo.loginUser(identifier: 'maya@date2.app', password: 'WrongPass!1'),
        isFalse,
      );
      // Correct password accepted (by email or username)
      expect(
        await repo.loginUser(identifier: 'maya_25', password: 'OldPassword!2026'),
        isTrue,
      );

      // Reset password updates stored credential
      expect(
        await repo.resetPassword('maya@date2.app', 'NewPassword!2026'),
        isTrue,
      );
      expect(
        await repo.loginUser(identifier: 'maya@date2.app', password: 'OldPassword!2026'),
        isFalse,
      );
      expect(
        await repo.loginUser(identifier: 'maya@date2.app', password: 'NewPassword!2026'),
        isTrue,
      );
    });

    test('Email OTP generates dynamic 6-digit code, validates expiry, resend & error triggers', () async {
      final sendStatus = await repo.sendVerificationOtp('test@date2.app');
      expect(sendStatus, EmailOtpStatus.waiting);

      final firstSnapshot = repo.getDemoOtpSnapshot('test@date2.app');
      expect(firstSnapshot, isNotNull);
      expect(firstSnapshot!.code.length, 6);
      expect(RegExp(r'^\d{6}$').hasMatch(firstSnapshot.code), isTrue);

      // Incorrect code rejected (not matching generated OTP)
      expect(
        await repo.verifyEmailOtp('test@date2.app', '111111'),
        EmailOtpStatus.invalidOtp,
      );

      // Deterministic expiry check
      await repo.expireDemoOtpForTesting('test@date2.app');
      expect(
        await repo.verifyEmailOtp('test@date2.app', firstSnapshot.code),
        EmailOtpStatus.expiredOtp,
      );

      // Resend issues a fresh code that passes verification
      await repo.sendVerificationOtp('test@date2.app');
      final freshSnapshot = repo.getDemoOtpSnapshot('test@date2.app');
      expect(freshSnapshot, isNotNull);
      expect(
        await repo.verifyEmailOtp('test@date2.app', freshSnapshot!.code),
        EmailOtpStatus.success,
      );

      // QA failure simulation triggers remain intact
      expect(
        await repo.verifyEmailOtp('test@date2.app', '000000'),
        EmailOtpStatus.expiredOtp,
      );
      expect(
        await repo.verifyEmailOtp('test@date2.app', '888888'),
        EmailOtpStatus.serviceUnavailable,
      );
      expect(
        await repo.verifyEmailOtp('test@date2.app', '999999'),
        EmailOtpStatus.deliveryFailed,
      );
      expect(
        await repo.sendVerificationOtp('fail@date2.app'),
        EmailOtpStatus.deliveryFailed,
      );
    });

    test('Secure token storage boundary does not fabricate fake JWT tokens in mock mode', () async {
      final mockStorage = MockAuthSessionBoundary();
      expect(mockStorage.isHardwareEncryptedStorageAvailable, isFalse);
      expect(await mockStorage.readAccessToken(), isNull);
      expect(
        () => mockStorage.saveTokens(
          accessToken: 'fake_jwt',
          refreshToken: 'fake_refresh',
        ),
        throwsUnsupportedError,
      );

      final manager = ProductionAuthSessionManager(tokenStorage: mockStorage);
      expect(await manager.hasActiveSession(), isFalse);
      expect(() => manager.silentRefreshToken(), throwsStateError);
    });
  });

  group('Module 1: Centralized State, Restart Persistence & Navigation Guards', () {
    test('Navigation guards enforce sequential verification journey', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);

      expect(notifier.canAccessStep(AuthFlowStep.signup), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.login), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.emailOtp), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.govId), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      await notifier.signUp(
        username: 'ananya_24',
        email: 'ananya@date2.app',
        password: 'Date2Password!2026',
      );
      expect(notifier.canAccessStep(AuthFlowStep.emailOtp), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isFalse);

      final otpSnap = notifier.getDemoOtpSnapshot(email: 'ananya@date2.app');
      expect(otpSnap, isNotNull);
      await notifier.verifyEmailOtp(otpSnap!.code);
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.faceScan), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.govId), isFalse);

      notifier.setFaceVerified('VERIF-B3D-PROOF-123');
      expect(notifier.canAccessStep(AuthFlowStep.govId), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      notifier.setDocVerified(
        country: 'India',
        docType: 'Aadhaar Card',
        docId: 'DOC-IN-PROOF-456',
      );
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.completed), isFalse);
      notifier.setPersonalInfoCompleted(true);
      expect(notifier.canAccessStep(AuthFlowStep.completed), isTrue);
      expect(container.read(authProvider).isFullyVerified, isTrue);
    });

    test('Mock persistence restores verification state across simulated app restart and clears on logout', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container1 = ProviderContainer(
        overrides: [optionalSharedPreferencesProvider.overrideWithValue(prefs)],
      );
      final n1 = container1.read(authProvider.notifier);
      await n1.signUp(
        username: 'restart_user',
        email: 'restart@date2.app',
        password: 'Date2Password!2026',
      );
      final snap = n1.getDemoOtpSnapshot(email: 'restart@date2.app');
      expect(snap, isNotNull);
      await n1.verifyEmailOtp(snap!.code);
      n1.setFaceVerified('PROOF-FACE');
      container1.dispose();

      // Simulate fresh app launch container
      final container2 = ProviderContainer(
        overrides: [optionalSharedPreferencesProvider.overrideWithValue(prefs)],
      );
      final restoredState = container2.read(authProvider);
      expect(restoredState.isAuthenticated, isTrue);
      expect(restoredState.isEmailVerified, isTrue);
      expect(restoredState.isFaceVerified, isTrue);
      expect(restoredState.isDocVerified, isFalse);
      expect(
        container2.read(authProvider.notifier).getNextRequiredStep(),
        AuthFlowStep.govId,
      );

      // Logout wipes persisted dev state
      await container2.read(authProvider.notifier).logout();
      expect(container2.read(authProvider).isAuthenticated, isFalse);
      container2.dispose();
    });

    test('skipVerificationForDev immediately grants fully verified status for onboarding', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [optionalSharedPreferencesProvider.overrideWithValue(prefs)],
      );
      final notifier = container.read(authProvider.notifier);
      await notifier.signUp(
        username: 'dev_skipper',
        email: 'skipper@date2.app',
        password: 'Date2Password!2026',
      );

      expect(container.read(authProvider).isFullyVerified, isFalse);
      await notifier.skipVerificationForDev();

      final state = container.read(authProvider);
      expect(state.isFullyVerified, isTrue);
      expect(state.isEmailVerified, isTrue);
      expect(state.isFaceVerified, isTrue);
      expect(state.isDocVerified, isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isTrue);

      await notifier.skipAllToHomeForDev();
      expect(notifier.canAccessStep(AuthFlowStep.completed), isTrue);
      container.dispose();
    });

    testWidgets('Strict VerificationRouteGuard blocks unverified access to Personal Info and Home',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            optionalSharedPreferencesProvider.overrideWithValue(prefs),
            authGuardEnforcedProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(initialIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must redirect away from Home Dashboard back to Welcome when unauthenticated!
      expect(find.text('Meet someone who gets you.'), findsOneWidget);

      // Now try protected OnboardingFlowScreen directly
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            optionalSharedPreferencesProvider.overrideWithValue(prefs),
            authGuardEnforcedProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Meet someone who gets you.'), findsOneWidget);
    });
  });

  group('Module 1: Government ID Country Config, Quality Analyzer & Repository', () {
    test('Country model filters supported documents & back-side requirements', () {
      expect(
        GovernmentIdCountry.india.supportedDocuments,
        containsAll(['Aadhaar Card', 'PAN Card', 'Passport', 'Driving Licence', 'Voter ID']),
      );
      expect(
        GovernmentIdCountry.unitedStates.supportedDocuments,
        isNot(contains('Aadhaar Card')),
      );
      expect(GovernmentIdCountry.requiresBackSide('Aadhaar Card'), isTrue);
      expect(GovernmentIdCountry.requiresBackSide('Driving Licence'), isTrue);
      expect(GovernmentIdCountry.requiresBackSide('Passport'), isFalse);
      expect(GovernmentIdCountry.requiresBackSide('PAN Card'), isFalse);
    });

    test('DocumentQualityAnalyzer validates PDF header & rejects blank/dark/corrupt buffers', () async {
      const analyzer = DocumentQualityAnalyzer();

      final validPdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31]);
      final pdfRes = await analyzer.analyzeBytes(bytes: validPdf, isPdf: true);
      expect(pdfRes.isPdfUpload, isTrue);
      expect(pdfRes.isCompliant, isTrue);

      final corruptPdf = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
      final corruptRes = await analyzer.analyzeBytes(bytes: corruptPdf, isPdf: true);
      expect(corruptRes.isCompliant, isFalse);

      final darkPng = await _createTestPngBytes(
        width: 240,
        height: 150,
        fillColor: const Color(0xFF0A0A0A),
        drawTextGrid: false,
      );
      final darkRes = await analyzer.analyzeBytes(bytes: darkPng, isPdf: false);
      expect(darkRes.isLightingAdequate, isFalse);

      final sharpLandscapePng = await _createTestPngBytes(
        width: 280,
        height: 170,
        fillColor: const Color(0xFFDCDCDC),
        drawTextGrid: true,
      );
      final goodRes =
          await analyzer.analyzeBytes(bytes: sharpLandscapePng, isPdf: false);
      expect(goodRes.isLightingAdequate, isTrue);
      expect(goodRes.isOrientationCorrect, isTrue);
      expect(goodRes.isSharp, isTrue);
    });

    test('MockGovernmentIdRepository supports pending, rejected, retry & verified states and wipes buffers', () async {
      final repo = MockGovernmentIdRepository();

      for (final entry in <String, GovIdStatus>{
        'PENDING-123': GovIdStatus.pendingReview,
        'REJECT-123': GovIdStatus.rejected,
        'RETRY-123': GovIdStatus.retryRequired,
        'VALID-4921': GovIdStatus.verified,
      }.entries) {
        final data = GovernmentIdData(
          country: GovernmentIdCountry.india,
          documentType: 'Aadhaar Card',
          documentNumber: entry.key,
          frontImageBytes: Uint8List.fromList([1, 2, 3, 4]),
          backImageBytes: Uint8List.fromList([5, 6, 7, 8]),
        );

        final res = await repo.submitDocument(data);
        expect(res.status, entry.value);
        expect(data.frontImageBytes, isNull);
        expect(data.backImageBytes, isNull);
      }
    });
  });

  group('Module 1: UI Widget Tests for Auth, OTP, Security Check & Gov ID', () {
    testWidgets('Renders SignUpScreen with username checking and password strength',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Renders OtpVerificationScreen empty with Edit Email, Demo fill & 6 cells',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerificationScreen(
              contactTarget: 'ananya@date2.app',
              isEmailVerification: true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('ananya@date2.app'), findsOneWidget);
      expect(find.text('Edit Email'), findsOneWidget);
      expect(find.textContaining('Fill Demo OTP ('), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('Renders ForgotPasswordScreen & PasswordResetScreen cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PasswordResetScreen(emailTarget: 'ananya@date2.app'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Set New Password'), findsOneWidget);
      expect(find.text('Update Password & Sign In'), findsOneWidget);
    });

    testWidgets('Renders LoginScreen with QA demo helper chips', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Needs OTP'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Renders SecurityCheckIntroScreen with pipeline overview',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityCheckIntroScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Security Check'), findsOneWidget);
      expect(find.text('2. Live 3D Face Scan'), findsOneWidget);
      expect(find.text('3. Active Liveness Detection'), findsOneWidget);
      expect(find.text('4. Government ID Verification'), findsOneWidget);
      expect(find.text('Start Live Face Scan'), findsOneWidget);
    });

    testWidgets('Renders GovernmentIdVerificationScreen and advances country selection',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GovernmentIdVerificationScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Government ID Verification'), findsOneWidget);
      expect(find.text('Select Document Issuing Country'), findsOneWidget);
      expect(find.text('India'), findsOneWidget);

      await tester.tap(find.text('Continue to Document Selection'));
      await tester.pumpAndSettle();

      expect(find.text('Select Document for India'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Proceed to Document Capture'), findsOneWidget);
    });

    testWidgets('Completes interactive Login -> Email OTP -> Security Check flow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            optionalSharedPreferencesProvider.overrideWithValue(prefs),
            authGuardEnforcedProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();

      // Quick-fill unverified OTP persona & log in
      await tester.ensureVisible(find.text('Needs OTP'));
      await tester.tap(find.text('Needs OTP'));
      await tester.pump();
      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      // Should land cleanly on Email OTP Verification screen
      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('demo.otp@date2.app'), findsOneWidget);

      // Fill generated Demo OTP & Verify
      await tester.ensureVisible(find.textContaining('Fill Demo OTP ('));
      await tester.tap(find.textContaining('Fill Demo OTP ('));
      await tester.pump();
      await tester.ensureVisible(find.text('Verify Email'));
      await tester.tap(find.text('Verify Email'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      // Should advance cleanly into Security Check pipeline
      expect(find.text('Security Check'), findsOneWidget);
      expect(find.text('Start Live Face Scan'), findsOneWidget);
    });

    testWidgets('Signup routes directly to Email OTP Verification (never Login) and completes OTP',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            optionalSharedPreferencesProvider.overrideWithValue(prefs),
            authGuardEnforcedProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'kiran_26');
      await tester.pump(const Duration(milliseconds: 800));
      await tester.enterText(fields.at(1), 'kiran26@date2.app');
      await tester.enterText(fields.at(2), 'StrongPass!2026');
      await tester.enterText(fields.at(3), 'StrongPass!2026');
      await tester.pump();

      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      // MUST go directly to Email OTP Verification, NOT LoginScreen
      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('kiran26@date2.app'), findsOneWidget);
      expect(find.text('Welcome Back'), findsNothing);

      // Test Expiry button & Resend, then Fill Demo OTP & Verify
      await tester.ensureVisible(find.text('Expire OTP (Test)'));
      await tester.tap(find.text('Expire OTP (Test)'));
      await tester.pump();
      await tester.ensureVisible(find.textContaining('Fill Demo OTP ('));
      await tester.tap(find.textContaining('Fill Demo OTP ('));
      await tester.pump();
      await tester.ensureVisible(find.text('Verify Email'));
      await tester.tap(find.text('Verify Email'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('OTP has expired'), findsOneWidget);

      // Pump past 30s resend countdown, resend, fill fresh Demo OTP & advance to Security Check
      await tester.pump(const Duration(seconds: 31));
      await tester.ensureVisible(find.text('Resend Code'));
      await tester.tap(find.text('Resend Code'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.ensureVisible(find.textContaining('Fill Demo OTP ('));
      await tester.tap(find.textContaining('Fill Demo OTP ('));
      await tester.pump();
      await tester.ensureVisible(find.text('Verify Email'));
      await tester.tap(find.text('Verify Email'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Security Check'), findsOneWidget);
    });

    testWidgets('Completes Forgot Password -> Demo Reset OTP -> Set New Password at 390x844',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            optionalSharedPreferencesProvider.overrideWithValue(prefs),
            authGuardEnforcedProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField),
        'demo.otp@date2.app',
      );
      await tester.ensureVisible(find.text('Send Verification Code'));
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Verify Reset Code'), findsNWidgets(2));
      await tester.ensureVisible(find.textContaining('Fill Demo OTP ('));
      await tester.tap(find.textContaining('Fill Demo OTP ('));
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Verify Reset Code'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify Reset Code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Set New Password'), findsOneWidget);
      final resetFields = find.byType(TextFormField);
      await tester.enterText(resetFields.at(0), 'NewResetPass!2026');
      await tester.enterText(resetFields.at(1), 'NewResetPass!2026');
      await tester.pump();
      await tester.ensureVisible(find.text('Update Password & Sign In'));
      await tester.tap(find.text('Update Password & Sign In'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Password Updated!'), findsOneWidget);
      await tester.tap(find.text('Go to Log In'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Renders all Module 1 screens cleanly at tight 360x780 mobile viewport without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      for (final screen in const <Widget>[
        SignUpScreen(),
        LoginScreen(),
        OtpVerificationScreen(
          contactTarget: 'ananya_long_handle@date2.app',
          isEmailVerification: true,
        ),
        ForgotPasswordScreen(),
        PasswordResetScreen(emailTarget: 'ananya@date2.app'),
        SecurityCheckIntroScreen(),
        GovernmentIdVerificationScreen(),
      ]) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: screen),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }

      // Advance GovernmentIdVerificationScreen through Stage 2 & Stage 3 at 360x780
      await tester.ensureVisible(find.text('Continue to Document Selection'));
      await tester.tap(find.text('Continue to Document Selection'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Proceed to Document Capture'));
      await tester.tap(find.text('Proceed to Document Capture'));
      await tester.pumpAndSettle();
      expect(find.text('Capture Aadhaar Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
