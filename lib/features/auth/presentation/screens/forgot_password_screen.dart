import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _contactController.text.trim().toLowerCase();
    final sent =
        await ref.read(authRepositoryProvider).sendPasswordResetOtp(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (sent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            contactTarget: email,
            isEmailVerification: false,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage =
            'Unable to send mock reset OTP to $email. Please verify the address.';
      });
    }
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
                'ACCOUNT RECOVERY',
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.figmaPrimary.withValues(alpha: 0.18)
                        : const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.figmaPrimary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "LET'S GET YOU BACK",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.accent : AppColors.figmaPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Forgot your\npassword?',
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
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "It happens. Enter your email and we'll send a six-digit verification code.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: mutedTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'EMAIL ADDRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? accent : AppColors.figmaPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'maya.rose@email.com',
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: isDark ? accent : AppColors.figmaPrimary,
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your registered email';
                    }
                    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                // Figma Reassurance Card: "Check your inbox"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceMutedDark : AppColors.figmaSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE5DEE6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check your inbox',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "If an account exists for this email, you'll receive a code. It may take a moment to arrive.",
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedTextColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.error.withValues(alpha: 0.16)
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
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

                const SizedBox(height: 28),

                PrimaryButton(
                  label: _isLoading
                      ? 'Sending Code...'
                      : 'Send Verification Code',
                  icon: Icons.mark_email_read_outlined,
                  backgroundColor: AppColors.figmaPrimary,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSendOtp,
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Remember it now? Log In',
                      style: TextStyle(
                        color: isDark ? AppColors.adaptiveAccent(isDark) : AppColors.figmaPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
