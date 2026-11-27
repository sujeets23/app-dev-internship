import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/basic_profile_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/connection_preferences_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/gender_identity_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/interests_selection_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/matching_preferences_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/pronouns_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/review_profile_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/sexual_orientation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Renders Welcome Screen and navigates to Basic Profile',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: OnboardingFlowScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Welcome Screen Branding & Tagline
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started button
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Screen 2 (Basic Profile) is displayed
    expect(find.text('The Essentials'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('About You (Short Bio)'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tapping Continue without filling required fields shows validation
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your first name'), findsOneWidget);
    expect(find.text('Please select your date of birth'), findsOneWidget);
    expect(
      find.text('Please upload a photo or choose an avatar to continue'),
      findsOneWidget,
    );
  });

  testWidgets('Step back navigation returns to previous screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: OnboardingFlowScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Get Started to go to Step 1
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('The Essentials'), findsOneWidget);

    // On Step 1, tap the back button in AppBar
    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verifies returned to Welcome Screen (Step 0)
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('All 6 onboarding steps (including The Essentials) do not expose any Skip bypass',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final screens = <Widget>[
      const BasicProfileScreen(), // Step 1: The Essentials
      const GenderIdentityScreen(), // Step 2
      const PronounsScreen(), // Step 3
      const SexualOrientationScreen(), // Step 4
      const ConnectionPreferencesScreen(), // Step 5
      const ReviewProfileScreen(), // Step 6
      const InterestsSelectionScreen(),
      const MatchingPreferencesScreen(),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Skip'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
