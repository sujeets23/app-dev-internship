import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import 'basic_profile_screen.dart';
import 'connection_preferences_screen.dart';
import 'gender_identity_screen.dart';
import 'profile_completion_success_screen.dart';
import 'pronouns_screen.dart';
import 'review_profile_screen.dart';
import 'sexual_orientation_screen.dart';
import 'welcome_screen.dart';

/// Top-level flow orchestrator for onboarding
class OnboardingFlowScreen extends ConsumerWidget {
  const OnboardingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    Widget currentScreen;
    switch (state.currentStep) {
      case 0:
        currentScreen = const WelcomeScreen(
          key: ValueKey('step_0_welcome'),
          isInsideFlow: true,
        );
        break;
      case 1:
        currentScreen = const BasicProfileScreen(key: ValueKey('step_1_basic'));
        break;
      case 2:
        currentScreen = const GenderIdentityScreen(key: ValueKey('step_2_gender'));
        break;
      case 3:
        currentScreen = const PronounsScreen(key: ValueKey('step_3_pronouns'));
        break;
      case 4:
        currentScreen =
            const SexualOrientationScreen(key: ValueKey('step_4_orientation'));
        break;
      case 5:
        currentScreen =
            const ConnectionPreferencesScreen(key: ValueKey('step_5_preferences'));
        break;
      case 6:
        currentScreen = const ReviewProfileScreen(key: ValueKey('step_6_review'));
        break;
      case 7:
      default:
        currentScreen =
            const ProfileCompletionSuccessScreen(key: ValueKey('step_7_success'));
        break;
    }

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.currentStep > 0) {
          notifier.previousStep();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: currentScreen,
      ),
    );
  }
}
