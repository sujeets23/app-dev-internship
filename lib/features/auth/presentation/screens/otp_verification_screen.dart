import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'password_reset_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String contactTarget;
  final bool isEmailVerification;

  const OtpVerificationScreen({
    super.key,
    required this.contactTarget,
    this.isEmailVerification = true,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 30;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Pre-populate with mock demo OTP for smooth developer testing
    _controllers[0].text = '4';
    _controllers[1].text = '9';
    _controllers[2].text = '2';
    _controllers[3].text = '1';
    _controllers[4].text = '8';
    _controllers[5].text = '6';
  }

  void _startTimer() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // Handle clipboard paste
        _handlePastedCode(value);
        return;
      }
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handlePastedCode(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6 && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    if (digits.length >= 6) {
      _focusNodes[5].unfocus();
    }
  }

  void _resendCode() async {
    if (_countdown > 0) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _startTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A fresh 6-digit mock code was sent to ${widget.contactTarget}.'),
          backgroundColor: const Color(0xFF1B6A45),
        ),
      );
    }
  }

  void _handleVerifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the verification code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.isEmailVerification) {
      final status =
          await ref.read(authProvider.notifier).verifyEmailOtp(code);

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (status) {
        case EmailOtpStatus.success:
          setState(() => _isSuccess = true);
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;
          // Sequential Flow: Move immediately to Security Check Introduction Screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const SecurityCheckIntroScreen(),
            ),
          );
          break;
        case EmailOtpStatus.expiredOtp:
          setState(() {
            _errorMessage = 'This OTP has expired. Please tap Resend to receive a fresh code.';
          });
          break;
        case EmailOtpStatus.invalidOtp:
          setState(() {
            _errorMessage = 'Invalid verification code. Use demo code: 492186.';
          });
          break;
        case EmailOtpStatus.serviceUnavailable:
          setState(() {
            _errorMessage = 'Verification service temporarily unavailable. Please retry shortly.';
          });
          break;
        case EmailOtpStatus.deliveryFailed:
          setState(() {
            _errorMessage = 'Failed to deliver OTP to ${widget.contactTarget}. Check address.';
          });
          break;
        default:
          setState(() {
            _errorMessage = 'Verification error. Please retry.';
          });
      }
    } else {
      // Password reset verification
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (code == '492186' || code == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PasswordResetScreen(emailTarget: widget.contactTarget),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid reset code. Use demo code: 492186.';
        });
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Verify Your Email',
                style: AppTypography.displayMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We sent a 6-digit confirmation code to:',
                style: AppTypography.bodyMedium.copyWith(
                  color: mutedTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.contactTarget,
                style: TextStyle(
                  color: isDark ? AppColors.neonLime : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // 6-Digit OTP Field Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: cardBg,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? AppColors.error
                                : AppColors.border,
                            width: 1.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (val) => _onDigitChanged(index, val),
                    ),
                  );
                }),
              ),

              // Error feedback
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Demo Testing Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Testing Mode: Pre-filled with demo OTP 492186. (Test expired state using 000000).',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Verify Button
              PrimaryButton(
                label: _isLoading
                    ? 'Verifying Code...'
                    : (_isSuccess ? 'Verified ✓' : 'Verify Email'),
                icon: Icons.check_circle_rounded,
                backgroundColor: _isSuccess
                    ? const Color(0xFF22C55E)
                    : AppColors.primary,
                onPressed: _isLoading ? null : _handleVerifyOtp,
              ),

              const SizedBox(height: 24),

              // Resend Timer Row
              Center(
                child: _countdown > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16, color: mutedTextColor),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${_countdown}s',
                            style: TextStyle(
                              color: mutedTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: _resendCode,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
