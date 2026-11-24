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
  bool _agreedToTerms = true;
  bool _isLoading = false;

  // Password criteria flags
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

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
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasNumber = text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  int get _satisfiedRequirementsCount {
    int count = 0;
    if (_hasMinLength) count++;
    if (_hasUppercase) count++;
    if (_hasNumber) count++;
    if (_hasSpecialChar) count++;
    return count;
  }

  double get _passwordStrengthScore => _satisfiedRequirementsCount / 4.0;

  String get _passwordStrengthLabel {
    final count = _satisfiedRequirementsCount;
    if (count == 0) return '';
    if (count <= 2) return 'Weak';
    if (count == 3) return 'Moderate';
    return 'Strong';
  }

  Color get _passwordStrengthColor {
    final count = _satisfiedRequirementsCount;
    if (count <= 2) return AppColors.error;
    if (count == 3) return Colors.orangeAccent;
    return const Color(0xFF22C55E);
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Affirming Community Guidelines.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_satisfiedRequirementsCount < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please satisfy all password security requirements.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim().toLowerCase();
    final email = _emailController.text.trim();

    final success = await ref.read(authProvider.notifier).signUp(
          username: username,
          email: email,
          password: _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Sequential Flow: Directly navigate to Email OTP Verification
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              contactTarget: email,
              isEmailVerification: true,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header with Date² Logo
                const Center(
                  child: Date2LogoWidget(
                    height: 42,
                    showContainer: true,
                  ),
                ),
                const SizedBox(height: 18),

                // Welcome Heading
                Text(
                  'Create Your Account',
                  style: AppTypography.displayMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Begin your verified, affirming journey on Date².',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),

                // USERNAME INPUT WITH DEBOUNCED AVAILABILITY
                Text(
                  'USERNAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : AppColors.primary,
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
                    prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                    suffixIcon: _buildUsernameStatusIndicator(authState.usernameStatus),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (val) {
                    authNotifier.checkUsername(val);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    final clean = value.trim().toLowerCase();
                    if (clean.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (clean.length > 20) {
                      return 'Username cannot exceed 20 characters';
                    }
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(clean)) {
                      return 'Only letters, numbers, and underscores allowed';
                    }
                    if (authState.usernameStatus == UsernameAvailabilityStatus.taken) {
                      return 'Username is already taken';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                _buildUsernameStatusText(authState.usernameStatus),

                const SizedBox(height: 16),

                // EMAIL INPUT
                Text(
                  'EMAIL ADDRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : AppColors.primary,
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
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,4}$').hasMatch(value.trim())) {
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
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter a strong password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (_satisfiedRequirementsCount < 4) {
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
                            value: _passwordStrengthScore,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _passwordStrengthLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _passwordStrengthColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRequirementItem('Minimum 8 characters', _hasMinLength),
                  _buildRequirementItem('At least one uppercase letter (A-Z)', _hasUppercase),
                  _buildRequirementItem('At least one number (0-9)', _hasNumber),
                  _buildRequirementItem('At least one special character (!@#\$...)', _hasSpecialChar),
                ],

                const SizedBox(height: 16),

                // CONFIRM PASSWORD INPUT
                Text(
                  'CONFIRM PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I accept the Terms of Service & Affirming Guidelines.',
                        style: TextStyle(fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // CREATE ACCOUNT BUTTON
                PrimaryButton(
                  label: _isLoading ? 'Creating Account...' : 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: _isLoading ? null : _handleSignUp,
                ),

                const SizedBox(height: 18),

                // LINK TO LOGIN
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Log In',
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

  Widget? _buildUsernameStatusIndicator(UsernameAvailabilityStatus status) {
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
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20);
      case UsernameAvailabilityStatus.taken:
        return const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
      case UsernameAvailabilityStatus.error:
        return const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 20);
      case UsernameAvailabilityStatus.none:
        return null;
    }
  }

  Widget _buildUsernameStatusText(UsernameAvailabilityStatus status) {
    switch (status) {
      case UsernameAvailabilityStatus.checking:
        return const Text(
          'Checking availability...',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        );
      case UsernameAvailabilityStatus.available:
        return const Text(
          '✓ Username available',
          style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.bold),
        );
      case UsernameAvailabilityStatus.taken:
        return const Text(
          '✗ Username already taken. Try another.',
          style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold),
        );
      case UsernameAvailabilityStatus.error:
        return const Text(
          'Unable to check availability right now',
          style: TextStyle(fontSize: 11, color: Colors.orange),
        );
      case UsernameAvailabilityStatus.none:
        return const Text(
          '3-20 characters: letters, numbers, and underscores',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        );
    }
  }

  Widget _buildRequirementItem(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 13,
            color: isSatisfied ? const Color(0xFF22C55E) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSatisfied ? const Color(0xFF22C55E) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
