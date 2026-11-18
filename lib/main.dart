import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_flow_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent local storage
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const KindredApp(),
    ),
  );
}

class KindredApp extends StatelessWidget {
  const KindredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingFlowScreen(),
    );
  }
}
