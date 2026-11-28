import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/government_id_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialIdentifier;
  final bool showPostSignupNotice;

  const LoginScreen({
    super.key,
    this.initialIdentifier,
    this.showPostSignupNotice = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _identifierController =
        TextEditingController(text: widget.initialIdentifier ?? '');
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _loginError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(
          identifier: identifier,
          password: password,
        );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        _loginError = ref.read(authProvider).lastErrorMessage ??
            'Invalid username/email or password.';
      });
      return;
    }

    _passwordController.clear();
    final authState = ref.read(authProvider);

    if (!authState.isEmailVerified) {
      await ref.read(authProvider.notifier).sendOrResendOtp();
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            contactTarget: authState.email ?? identifier,
            isEmailVerification: true,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = false);

    if (!authState.isFaceVerified) {
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
    } else if (!authState.isPersonalInfoCompleted) {
      if (ref.read(onboardingProvider).currentStep == 0) {
        ref.read(onboardingProvider.notifier).startOnboarding();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingFlowScreen(),
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
  }

  void _fillDemoCredentials(String email) {
    setState(() {
      _identifierController.text = email;
      _passwordController.text = 'Date2Secure!2026';
      _loginError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.figmaPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Date2LogoWidget(
                    height: 48,
                    showContainer: false,
                  ),
                ),
                const SizedBox(height: 18),

                if (widget.showPostSignupNotice) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.success.withValues(alpha: 0.14)
                          : AppColors.successLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.45)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Account created! Log in with your credentials to trigger your 6-digit Email OTP verification.',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Text(
                  'GOOD TO SEE YOU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.accent : AppColors.figmaPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your people\nare out there.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Log in and pick up where you left off.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: mutedTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // USERNAME OR EMAIL INPUT
                Text(
                  'USERNAME OR EMAIL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _identifierController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'e.g. ananya_24 or name@example.com',
                    prefixIcon:
                        const Icon(Icons.person_outline_rounded, size: 20),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

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
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: isDark ? accent : AppColors.figmaPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Figma Reassurance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(top: 6, bottom: 18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceMutedDark : AppColors.figmaSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE5DEE6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: isDark ? AppColors.accent : AppColors.figmaPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A space for genuine connection.\nYour details stay private.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_loginError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.error.withValues(alpha: 0.16)
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _loginError!,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // LOG IN BUTTON
                PrimaryButton(
                  label: _isLoading ? 'Authenticating...' : 'Log In',
                  icon: Icons.login_rounded,
                  backgroundColor: AppColors.figmaPrimary,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleLogin,
                ),

                const SizedBox(height: 20),

                // Dev QA Quick-Fill Demo Personas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.glacierLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.glacierBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QA DEMO ACCOUNTS (FRONTEND MOCK)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.accent
                              : AppColors.glacierInk,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildDemoChip('Needs OTP', 'demo.otp@date2.app', isDark),
                          _buildDemoChip('Needs Face', 'demo.face@date2.app', isDark),
                          _buildDemoChip('Needs ID', 'demo.doc@date2.app', isDark),
                          _buildDemoChip(
                              'Verified', 'demo.verified@date2.app', isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // SIGNUP LINK
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: accent,
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

  Widget _buildDemoChip(String label, String email, bool isDark) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
        ),
      ),
      backgroundColor: isDark ? AppColors.encreElevated : AppColors.surface,
      side: BorderSide(color: AppColors.adaptiveBorder(isDark)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () => _fillDemoCredentials(email),
    );
  }
}
