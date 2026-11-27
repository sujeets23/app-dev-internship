import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/verification/presentation/screens/biometric_verification_screen.dart';
import '../../features/verification/presentation/screens/companion_kyc_screen.dart';
import '../../features/verification/presentation/screens/government_id_verification_screen.dart';
import '../../features/verification/presentation/screens/security_check_intro_screen.dart';
import '../../features/profile/presentation/screens/personal_info_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/onboarding/presentation/screens/interests_selection_screen.dart';
import '../../features/onboarding/presentation/screens/matching_preferences_screen.dart';
import '../../features/games/presentation/screens/games_lobby_screen.dart';
import '../../features/companions/presentation/screens/companion_marketplace_screen.dart';
import '../../features/date_planner/presentation/screens/date_planner_screen.dart';
import '../../features/subscription/presentation/screens/subscription_pricing_screen.dart';
import '../../features/subscription/presentation/screens/billing_ledger_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../widgets/main_navigation_screen.dart';

/// Named route constants supporting deep-link & guarded navigation across all modules.
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String emailOtp = '/email-otp';
  static const String securityCheck = '/security-check';
  static const String faceScan = '/face-scan';
  static const String govId = '/gov-id';
  static const String personalInfo = '/personal-info';
  static const String personalDetails = '/profile/personal-info';
  static const String matchingPreferences = '/matching-preferences';
  static const String interestsSelection = '/interests-selection';
  static const String games = '/games';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String companionKyc = '/companion-kyc';
  static const String companions = '/companions';
  static const String datePlanner = '/date-planner';
  static const String subscriptions = '/subscriptions';
  static const String billing = '/billing';
  static const String settings = '/settings';
  static const String privacySettings = '/privacy-settings';
}

/// Centralized navigation and verification guard router.
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pushAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void goToHome(BuildContext context, {int initialIndex = 0}) {
    pushAndRemoveUntil(context, MainNavigationScreen(initialIndex: initialIndex));
  }

  /// Resolves the exact screen for the user's next unmet onboarding/verification gate.
  static Widget resolveNextRequiredScreen(AuthUserState authState) {
    if (!authState.isAuthenticated) {
      return const WelcomeScreen();
    }
    if (!authState.isEmailVerified) {
      return OtpVerificationScreen(
        contactTarget: authState.email ?? 'user@date2.app',
        isEmailVerification: true,
      );
    }
    if (!authState.isFaceVerified) {
      return const SecurityCheckIntroScreen();
    }
    if (!authState.isDocVerified) {
      return const GovernmentIdVerificationScreen();
    }
    if (!authState.isPersonalInfoCompleted) {
      return const OnboardingFlowScreen();
    }
    return const MainNavigationScreen(initialIndex: 0);
  }

  /// Central `onGenerateRoute` intercepting deep links and direct named navigation.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget target;
    switch (settings.name) {
      case AppRoutes.splash:
        target = const SplashScreen();
        break;
      case AppRoutes.welcome:
        target = const WelcomeScreen();
        break;
      case AppRoutes.signup:
        target = const SignUpScreen();
        break;
      case AppRoutes.login:
        target = const LoginScreen();
        break;
      case AppRoutes.forgotPassword:
        target = const ForgotPasswordScreen();
        break;
      case AppRoutes.emailOtp:
        final emailArg = settings.arguments as String? ?? 'user@date2.app';
        target = OtpVerificationScreen(
          contactTarget: emailArg,
          isEmailVerification: true,
        );
        break;
      case AppRoutes.securityCheck:
        target = const SecurityCheckIntroScreen();
        break;
      case AppRoutes.faceScan:
        target = const BiometricVerificationScreen();
        break;
      case AppRoutes.govId:
        target = const GovernmentIdVerificationScreen();
        break;
      case AppRoutes.personalInfo:
        target = const OnboardingFlowScreen();
        break;
      case AppRoutes.personalDetails:
        target = const PersonalInfoScreen();
        break;
      case AppRoutes.matchingPreferences:
        target = const MatchingPreferencesScreen();
        break;
      case AppRoutes.interestsSelection:
        target = const InterestsSelectionScreen();
        break;
      case AppRoutes.games:
        target = const GamesLobbyScreen();
        break;
      case AppRoutes.profile:
        target = const ProfileScreen();
        break;
      case AppRoutes.home:
        target = const MainNavigationScreen(initialIndex: 0);
        break;
      case AppRoutes.companionKyc:
        target = const CompanionKycScreen();
        break;
      case AppRoutes.companions:
        target = const CompanionMarketplaceScreen();
        break;
      case AppRoutes.datePlanner:
        target = const DatePlannerScreen();
        break;
      case AppRoutes.subscriptions:
        target = const SubscriptionPricingScreen();
        break;
      case AppRoutes.billing:
        target = const BillingLedgerScreen();
        break;
      case AppRoutes.settings:
        target = const SettingsScreen();
        break;
      case AppRoutes.privacySettings:
        target = const PrivacySettingsScreen();
        break;
      default:
        target = const WelcomeScreen();
        break;
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => target,
    );
  }
}

/// Declarative widget-level route guard that blocks unauthorized rendering of
/// protected Module 1, Personal Info, and Home screens (whether via back stack,
/// deep link, direct `Navigator.push`, or app restart).
class VerificationRouteGuard extends ConsumerWidget {
  final AuthFlowStep requiredStep;
  final Widget child;
  final bool bypassInLegacyUnitTest;

  const VerificationRouteGuard({
    super.key,
    required this.requiredStep,
    required this.child,
    this.bypassInLegacyUnitTest = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enforced = ref.watch(authGuardEnforcedProvider);
    if (!enforced || bypassInLegacyUnitTest) {
      return child;
    }

    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authNotifier.canAccessStep(requiredStep)) {
      return child;
    }

    // Intercept and strictly redirect UI to the earliest unmet gate!
    return AppRouter.resolveNextRequiredScreen(authState);
  }
}
