import 'package:flutter/material.dart';
import '../widgets/main_navigation_screen.dart';

/// Centralized navigation and routing keys
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
}
