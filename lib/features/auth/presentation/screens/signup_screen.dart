import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _submitErrorMessage;

  PasswordStrengthEvaluation _strength = const PasswordStrengthEvaluation(
    hasMinLength: false,
    hasUppercase: false,
    hasNumber: false,
    hasSpecialChar: false,
    satisfiedCount: 0,
    totalCount: 4,
  );

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength() {
    final config = ref.read(authRepositoryProvider).passwordConfig;
    setState(() {
      _strength = config.evaluate(_passwordController.text);
    });
  }

  Color get _passwordStrengthColor {
    if (_strength.score <= 0.5) return AppColors.error;
    if (_strength.score < 1.0) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) return;
    setState(() => _submitErrorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    if (authState.usernameStatus == UsernameAvailabilityStatus.checking) {
      setState(() {
        _submitErrorMessage =
            'Please wait until username availability check completes.';
      });
      return;
    }
    if (authState.usernameStatus == UsernameAvailabilityStatus.taken) {
      setState(() {
        _submitErrorMessage =
            'This username is unavailable. Choose a different username.';
      });
      return;
    }
    if (authState.usernameStatus == UsernameAvailabilityStatus.error) {
      setState(() {
        _submitErrorMessage =
            'Username availability check failed. Tap retry on username first.';
      });
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _submitErrorMessage =
            'Please accept the Terms of Service & Affirming Community Guidelines.';
      });
      return;
    }

    if (!_strength.isSatisfied) {
      setState(() {
        _submitErrorMessage =
            'Please satisfy all password security requirements.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final normalizedUsername =
        repo.usernameConfig.normalize(_usernameController.text);
    final email = _emailController.text.trim().toLowerCase();

    if (authState.usernameStatus == UsernameAvailabilityStatus.none) {
      try {
        final availability =
            await repo.checkUsernameAvailability(normalizedUsername);
        if (!mounted) return;
        if (availability == UsernameAvailabilityStatus.taken) {
          setState(() {
            _isLoading = false;
            _submitErrorMessage =
                'This username is unavailable. Choose a different username.';
          });
          return;
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _submitErrorMessage =
              'Unable to verify username availability. Please retry.';
        });
        return;
      }
    }

    final success = await ref.read(authProvider.notifier).signUp(
          username: normalizedUsername,
          email: email,
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Clear sensitive password buffers from form controllers before leaving
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Sequential Flow (Module 1):
      // Signup -> Account Created -> Email OTP Verification -> Security Check -> Face Scan -> Gov ID -> Personal Info
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            contactTarget: email,
            isEmailVerification: true,
            showAccountCreatedNotice: true,
          ),
        ),
      );
    } else {
      setState(() {
        _submitErrorMessage = ref.read(authProvider).lastErrorMessage ??
            'Could not create account. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final repo = ref.read(authRepositoryProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    final normalizedPreview =
        repo.usernameConfig.normalize(_usernameController.text);

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Date2LogoWidget(
                    height: 42,
                    showContainer: true,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Create Your Account',
                  style: AppTypography.displayMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Begin your verified, affirming journey on Date².',
                  style: AppTypography.bodyMedium.copyWith(
                    color: mutedTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),

                // Clear Frontend Mock Mode Notice
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.adaptiveHighlightBg(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.glacierBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Frontend Demo Mode: Accounts use mock local auth until backend endpoints go live.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.glacierInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // USERNAME INPUT WITH DEBOUNCED AVAILABILITY & NORMALIZATION
                Text(
                  'USERNAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    hintText: 'e.g. ananya_24',
                    prefixIcon:
                        const Icon(Icons.alternate_email_rounded, size: 20),
                    suffixIcon: _buildUsernameStatusIndicator(
                      authState.usernameStatus,
                      onRetry: () =>
                          authNotifier.checkUsername(_usernameController.text),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    authNotifier.checkUsername(val);
                  },
                  validator: (value) {
                    final configErr = repo.usernameConfig.validate(value);
                    if (configErr != null) return configErr;
                    if (authState.usernameStatus ==
                        UsernameAvailabilityStatus.taken) {
                      return 'Username is already taken';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _buildUsernameStatusText(
                        authState.usernameStatus,
                        repo.usernameConfig,
                      ),
                    ),
                    if (_usernameController.text.isNotEmpty &&
                        _usernameController.text != normalizedPreview)
                      Text(
                        'Normalized: @$normalizedPreview',
                        style: TextStyle(
                          fontSize: 11,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // EMAIL INPUT
                Text(
                  'EMAIL ADDRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'your.name@example.com',
                    prefixIcon:
                        const Icon(Icons.mail_outline_rounded, size: 20),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                    hintText: 'Enter a strong password',
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
                      return 'Password is required';
                    }
                    if (!_strength.isSatisfied) {
                      return 'Password does not meet all security criteria';
                    }
                    return null;
                  },
                ),

                // Live Strength Meter & Checklist
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _strength.score,
                            backgroundColor:
                                AppColors.border.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _passwordStrengthColor,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _strength.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _passwordStrengthColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRequirementItem(
                    'Minimum ${repo.passwordConfig.minLength} characters',
                    _strength.hasMinLength,
                  ),
                  if (repo.passwordConfig.requireUppercase)
                    _buildRequirementItem(
                      'At least one uppercase letter (A-Z)',
                      _strength.hasUppercase,
                    ),
                  if (repo.passwordConfig.requireNumber)
                    _buildRequirementItem(
                      'At least one number (0-9)',
                      _strength.hasNumber,
                    ),
                  if (repo.passwordConfig.requireSpecialChar)
                    _buildRequirementItem(
                      'At least one special character (!@#\$...)',
                      _strength.hasSpecialChar,
                    ),
                ],

                const SizedBox(height: 16),

                // CONFIRM PASSWORD INPUT
                Text(
                  'CONFIRM PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon:
                        const Icon(Icons.lock_reset_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // TERMS & CONDITIONS CHECKBOX
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: accent,
                      checkColor: AppColors.adaptiveOnAccent(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Text(
                          'I accept the Terms of Service & Affirming Guidelines.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_submitErrorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                            _submitErrorMessage!,
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

                const SizedBox(height: 18),

                // CREATE ACCOUNT BUTTON
                PrimaryButton(
                  label: _isLoading ? 'Creating Account...' : 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSignUp,
                ),

                const SizedBox(height: 18),

                // LINK TO LOGIN
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Log In',
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

  Widget? _buildUsernameStatusIndicator(
    UsernameAvailabilityStatus status, {
    required VoidCallback onRetry,
  }) {
    switch (status) {
      case UsernameAvailabilityStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case UsernameAvailabilityStatus.available:
        return const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 20);
      case UsernameAvailabilityStatus.taken:
        return const Icon(Icons.cancel_rounded,
            color: AppColors.error, size: 20);
      case UsernameAvailabilityStatus.error:
        return IconButton(
          tooltip: 'Retry check',
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.warning, size: 20),
          onPressed: onRetry,
        );
      case UsernameAvailabilityStatus.none:
        return null;
    }
  }

  Widget _buildUsernameStatusText(
    UsernameAvailabilityStatus status,
    UsernameValidationConfig cfg,
  ) {
    switch (status) {
      case UsernameAvailabilityStatus.checking:
        return const Text(
          'Checking availability...',
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        );
      case UsernameAvailabilityStatus.available:
        return const Text(
          '✓ Username available',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        );
      case UsernameAvailabilityStatus.taken:
        return const Text(
          '✗ Username already taken. Try another.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        );
      case UsernameAvailabilityStatus.error:
        return const Text(
          'Network error checking handle. Tap retry.',
          style: TextStyle(fontSize: 11, color: AppColors.warning),
        );
      case UsernameAvailabilityStatus.none:
        return Text(
          '${cfg.minLength}-${cfg.maxLength} chars: lowercase letters, numbers & _',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        );
    }
  }

  Widget _buildRequirementItem(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isSatisfied
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 13,
            color: isSatisfied ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSatisfied ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
