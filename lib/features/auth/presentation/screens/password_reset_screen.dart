import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  final String? emailTarget;
  const PasswordResetScreen({super.key, this.emailTarget});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;
  String? _errorMessage;

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
    _passwordController.addListener(_evaluateStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluateStrength() {
    final config = ref.read(authRepositoryProvider).passwordConfig;
    setState(() {
      _strength = config.evaluate(_passwordController.text);
    });
  }

  Color get _strengthColor {
    if (_strength.score <= 0.5) return AppColors.error;
    if (_strength.score < 1.0) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _handleResetPassword() async {
    if (_isLoading) return;
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_strength.isSatisfied) {
      setState(() {
        _errorMessage = 'Please meet all password security requirements.';
      });
      return;
    }

    setState(() => _isLoading = true);
    final updated = await ref.read(authRepositoryProvider).resetPassword(
          widget.emailTarget ?? '',
          _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!updated) {
      setState(() {
        _errorMessage = 'Unable to update password. Please retry.';
      });
      return;
    }

    _passwordController.clear();
    _confirmPasswordController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final dialogDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Password Updated!')),
            ],
          ),
          content: const Text(
            'Demo Mode: Your mock account password has been updated. Return to Log In with your new password.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.adaptiveAccent(dialogDark),
                foregroundColor: AppColors.adaptiveOnAccent(dialogDark),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      initialIdentifier: widget.emailTarget,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Go to Log In'),
            ),
          ],
        );
      },
    );
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
    final config = ref.read(authRepositoryProvider).passwordConfig;

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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.adaptiveHighlightBg(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.key_rounded,
                    color: accent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Set New Password',
                  style: AppTypography.displayMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a strong, unique password for ${widget.emailTarget ?? "your Date² account"}.',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'NEW PASSWORD',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure1,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Minimum ${config.minLength} characters',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: accent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: mutedTextColor,
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (!_strength.isSatisfied) {
                      return 'Password does not meet all security criteria';
                    }
                    return null;
                  },
                ),

                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _strength.score,
                            backgroundColor:
                                AppColors.border.withValues(alpha: 0.5),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_strengthColor),
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
                          color: _strengthColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Minimum ${config.minLength} characters',
                    _strength.hasMinLength,
                  ),
                  _buildCheckItem(
                    'At least one uppercase letter (A-Z)',
                    _strength.hasUppercase,
                  ),
                  _buildCheckItem(
                    'At least one number (0-9)',
                    _strength.hasNumber,
                  ),
                  _buildCheckItem(
                    'At least one special character (!@#\$...)',
                    _strength.hasSpecialChar,
                  ),
                ],

                const SizedBox(height: 20),

                Text(
                  'CONFIRM NEW PASSWORD',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscure2,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Re-enter your new password',
                    prefixIcon: Icon(
                      Icons.lock_reset_rounded,
                      color: accent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: mutedTextColor,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                PrimaryButton(
                  label: _isLoading
                      ? 'Updating Password...'
                      : 'Update Password & Sign In',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 13,
            color: ok ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: ok ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
