import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/government_id_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController =
      TextEditingController(text: 'ananya@date2.app');
  final _passwordController =
      TextEditingController(text: 'Date2Secure!2026');

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(
          identifier: identifier,
          password: password,
        );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        final authState = ref.read(authProvider);

        // Enforce sequential verification rules:
        if (!authState.isEmailVerified) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                contactTarget: authState.email ?? identifier,
                isEmailVerification: true,
              ),
            ),
          );
        } else if (!authState.isFaceVerified) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const SecurityCheckIntroScreen(),
            ),
          );
        } else if (!authState.isDocVerified) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const GovernmentIdVerificationScreen(),
            ),
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 0),
            ),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username/email or password.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header with Date² Logo
                const Center(
                  child: Date2LogoWidget(
                    height: 44,
                    showContainer: true,
                  ),
                ),
                const SizedBox(height: 22),

                // Welcome Back Title
                Text(
                  'Welcome Back',
                  style: AppTypography.displayMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log in with your username or registered email.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: mutedTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),

                // USERNAME OR EMAIL INPUT
                Text(
                  'USERNAME OR EMAIL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _identifierController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'e.g. ananya_24 or name@example.com',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username or email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // PASSWORD INPUT
                Text(
                  'PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // LOG IN BUTTON
                PrimaryButton(
                  label: _isLoading ? 'Authenticating...' : 'Log In',
                  icon: Icons.login_rounded,
                  onPressed: _isLoading ? null : _handleLogin,
                ),

                const SizedBox(height: 24),

                // SIGNUP LINK
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: mutedTextColor,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
