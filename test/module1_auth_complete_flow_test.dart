import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/features/auth/data/auth_repository.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/signup_screen.dart';
import 'package:inclusive_dating/features/verification/domain/models/government_id_model.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/government_id_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';

void main() {
  group('Module 1: Complete Authentication & Username Validation', () {
    late MockAuthRepository repo;

    setUp(() {
      repo = MockAuthRepository();
    });

    test('Username availability check detects taken and available handles', () async {
      // Reserved / taken handles
      final statusAdmin = await repo.checkUsernameAvailability('admin');
      expect(statusAdmin, UsernameAvailabilityStatus.taken);

      final statusWaseem = await repo.checkUsernameAvailability('waseem');
      expect(statusWaseem, UsernameAvailabilityStatus.taken);

      // Available handles
      final statusFresh = await repo.checkUsernameAvailability('ananya_star');
      expect(statusFresh, UsernameAvailabilityStatus.available);

      // Short handles
      final statusShort = await repo.checkUsernameAvailability('hi');
      expect(statusShort, UsernameAvailabilityStatus.none);
    });

    test('Email OTP verification handles success, expired, and invalid codes', () async {
      // Valid demo OTP
      final success = await repo.verifyEmailOtp('test@date2.app', MockAuthRepository.demoOtp);
      expect(success, EmailOtpStatus.success);

      // Alternative demo OTP
      final successAlt = await repo.verifyEmailOtp('test@date2.app', '123456');
      expect(successAlt, EmailOtpStatus.success);

      // Expired OTP trigger
      final expired = await repo.verifyEmailOtp('test@date2.app', '000000');
      expect(expired, EmailOtpStatus.expiredOtp);

      // Invalid OTP trigger
      final invalid = await repo.verifyEmailOtp('test@date2.app', '111111');
      expect(invalid, EmailOtpStatus.invalidOtp);
    });
  });

  group('Module 1: Centralized State Management & Navigation Guards', () {
    test('Navigation guards enforce sequential verification journey', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);

      // Initial state: Unregistered user
      expect(notifier.canAccessStep(AuthFlowStep.signup), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.login), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.emailOtp), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.govId), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      // Step 1: After Signup (Authenticated, but email unverified)
      await notifier.signUp(
        username: 'ananya_24',
        email: 'ananya@date2.app',
        password: 'Date2Password!2026',
      );
      expect(notifier.canAccessStep(AuthFlowStep.emailOtp), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.govId), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      // Step 2: Email OTP Verified -> Security Check / Face Scan Unlocked
      await notifier.verifyEmailOtp('492186');
      expect(notifier.canAccessStep(AuthFlowStep.securityCheck), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.faceScan), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.govId), isFalse);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      // Step 3: Face Verified -> Government ID Unlocked
      notifier.setFaceVerified('VERIF-B3D-PROOF-123');
      expect(notifier.canAccessStep(AuthFlowStep.govId), isTrue);
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isFalse);

      // Step 4: Government ID Verified -> Personal Info Unlocked!
      notifier.setDocVerified(
        country: 'India',
        docType: 'Aadhaar Card',
        docId: 'DOC-IN-PROOF-456',
      );
      expect(notifier.canAccessStep(AuthFlowStep.personalInfo), isTrue);
      expect(container.read(authProvider).isFullyVerified, isTrue);
    });
  });

  group('Module 1: Country-Aware Government ID Model & Security', () {
    test('Country model returns appropriate document types', () {
      // India
      expect(
        GovernmentIdCountry.india.supportedDocuments,
        containsAll(['Aadhaar Card', 'PAN Card', 'Passport', 'Driving Licence', 'Voter ID']),
      );

      // Back side requirements
      expect(GovernmentIdCountry.requiresBackSide('Aadhaar Card'), isTrue);
      expect(GovernmentIdCountry.requiresBackSide('Driving Licence'), isTrue);
      expect(GovernmentIdCountry.requiresBackSide('Passport'), isFalse);
      expect(GovernmentIdCountry.requiresBackSide('PAN Card'), isFalse);
    });

    test('GovernmentIdData securely wipes raw document buffers from memory', () {
      final front = Uint8List.fromList([1, 2, 3, 4]);
      final back = Uint8List.fromList([5, 6, 7, 8]);

      final doc = GovernmentIdData(
        country: GovernmentIdCountry.india,
        documentType: 'Aadhaar Card',
        documentNumber: 'XXXX-XXXX-4921',
        frontImageBytes: front,
        backImageBytes: back,
      );

      expect(doc.frontImageBytes, isNotNull);
      expect(doc.backImageBytes, isNotNull);

      doc.secureWipe();

      expect(doc.frontImageBytes, isNull);
      expect(doc.backImageBytes, isNull);
    });
  });

  group('Module 1: UI Widget Tests for Sequential Flow', () {
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

    testWidgets('Renders OtpVerificationScreen with 6-digit boxes and resend timer',
        (tester) async {
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

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('ananya@date2.app'), findsOneWidget);
      expect(find.text('Verify Email'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
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
      expect(find.text('Live 3D Face Scan'), findsOneWidget);
      expect(find.text('Active Liveness Detection'), findsOneWidget);
      expect(find.text('Government ID Verification'), findsOneWidget);
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

      // Tap Continue to Document Selection
      await tester.tap(find.text('Continue to Document Selection'));
      await tester.pumpAndSettle();

      expect(find.text('Select Document for India'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Proceed to Document Capture'), findsOneWidget);
    });
  });
}
