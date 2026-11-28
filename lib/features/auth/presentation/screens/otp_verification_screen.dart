import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'password_reset_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String contactTarget;
  final bool isEmailVerification;
  final bool showAccountCreatedNotice;

  const OtpVerificationScreen({
    super.key,
    required this.contactTarget,
    this.isEmailVerification = true,
    this.showAccountCreatedNotice = false,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _listenerFocusNodes =
      List.generate(6, (_) => FocusNode(skipTraversal: true));

  late String _activeTarget;
  int _countdown = 30;
  Timer? _timer;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  bool _isSuccess = false;
  bool _showDevCode = true;

  @override
  void initState() {
    super.initState();
    _activeTarget = widget.contactTarget;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDemoOtpReady();
    });
  }

  Future<void> _ensureDemoOtpReady() async {
    if (!mounted) return;
    await ref.read(authProvider.notifier).ensureDemoOtpIssued(
          email: _activeTarget,
          isPasswordReset: !widget.isEmailVerification,
        );
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final lf in _listenerFocusNodes) {
      lf.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    setState(() => _errorMessage = null);

    if (value.isEmpty) return;

    if (value.length > 1) {
      _handlePastedCode(value);
      return;
    }

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  void _handlePastedCode(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    if (digits.length >= 6) {
      _focusNodes[5].unfocus();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, 5)].requestFocus();
    }
    setState(() {});
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _handlePastedCode(data.text!);
    }
  }

  Future<void> _showEditEmailDialog() async {
    final editController = TextEditingController(text: _activeTarget);
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Email Address'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: editController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Email Address',
              hintText: 'name@example.com',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, editController.text.trim());
              }
            },
            child: const Text('Update & Resend'),
          ),
        ],
      ),
    );

    editController.dispose();

    if (updated != null && updated.isNotEmpty && mounted) {
      setState(() {
        _activeTarget = updated;
        _isResending = true;
        _errorMessage = null;
      });

      final status = widget.isEmailVerification
          ? await ref.read(authProvider.notifier).editEmailAndResendOtp(updated)
          : (await ref.read(authRepositoryProvider).sendPasswordResetOtp(updated)
              ? EmailOtpStatus.waiting
              : EmailOtpStatus.deliveryFailed);

      if (!mounted) return;
      setState(() {
        _isResending = false;
        if (status == EmailOtpStatus.deliveryFailed) {
          _errorMessage = 'Mock delivery failed for $updated.';
        } else {
          _startTimer();
        }
      });
    }
  }

  Future<void> _resendCode() async {
    if (_countdown > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final status = widget.isEmailVerification
        ? await ref
            .read(authProvider.notifier)
            .sendOrResendOtp(overrideEmail: _activeTarget)
        : (await ref
                .read(authRepositoryProvider)
                .sendPasswordResetOtp(_activeTarget)
            ? EmailOtpStatus.waiting
            : EmailOtpStatus.deliveryFailed);

    if (!mounted) return;
    setState(() {
      _isResending = false;
      if (status == EmailOtpStatus.deliveryFailed) {
        _errorMessage =
            'Demo SMTP delivery failed for $_activeTarget. Edit email or retry.';
      } else if (status == EmailOtpStatus.serviceUnavailable) {
        _errorMessage = 'OTP delivery service temporarily unavailable.';
      } else {
        _startTimer();
      }
    });

    if (_errorMessage == null && mounted) {
      final refreshedOtp = ref.read(authRepositoryProvider).getDemoOtpSnapshot(
            _activeTarget,
            isPasswordReset: !widget.isEmailVerification,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refreshedOtp != null
                ? 'Demo Mode (No SMTP): New 6-digit demo OTP generated for $_activeTarget (${refreshedOtp.code}).'
                : 'Verification code resent to $_activeTarget.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_isLoading || _isResending || _isSuccess) return;
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

    final EmailOtpStatus status;
    if (widget.isEmailVerification) {
      status = await ref.read(authProvider.notifier).verifyEmailOtp(code);
    } else {
      status = await ref
          .read(authRepositoryProvider)
          .verifyPasswordResetOtp(_activeTarget, code);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (status) {
      case EmailOtpStatus.success:
        setState(() => _isSuccess = true);
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;

        if (widget.isEmailVerification) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const SecurityCheckIntroScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordResetScreen(emailTarget: _activeTarget),
            ),
          );
        }
        break;
      case EmailOtpStatus.expiredOtp:
        setState(() {
          _errorMessage =
              'This OTP has expired. Tap Resend Code to request a fresh code.';
        });
        break;
      case EmailOtpStatus.invalidOtp:
        setState(() {
          _errorMessage =
              'Invalid code entered. Check the 6-digit code in the Demo Testing box and try again.';
        });
        break;
      case EmailOtpStatus.serviceUnavailable:
        setState(() {
          _errorMessage =
              'Verification service temporarily unavailable. Please retry shortly.';
        });
        break;
      case EmailOtpStatus.deliveryFailed:
        setState(() {
          _errorMessage =
              'Delivery failed for $_activeTarget. Check address or edit email.';
        });
        break;
      case EmailOtpStatus.waiting:
      case EmailOtpStatus.otpEntered:
      case EmailOtpStatus.verifying:
      case EmailOtpStatus.resending:
        setState(() {
          _errorMessage = 'Verification could not complete. Please retry.';
        });
        break;
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

    final demoSnapshot = ref.read(authRepositoryProvider).getDemoOtpSnapshot(
          _activeTarget,
          isPasswordReset: !widget.isEmailVerification,
        );
    final now = DateTime.now();
    final int remainingValiditySec = demoSnapshot == null
        ? 0
        : demoSnapshot.expiresAt.difference(now).inSeconds.clamp(0, 3600);
    final bool isDemoExpired = demoSnapshot != null && demoSnapshot.isExpiredAt(now);

    final screen = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (widget.isEmailVerification && !Navigator.canPop(context))
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'Switch Account',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'EMAIL VERIFICATION',
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showAccountCreatedNotice) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.success.withValues(alpha: 0.14)
                        : AppColors.successLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account created! Verify your email using the local Demo OTP below to proceed to Security Check.',
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
                    Icons.mail_outline_rounded,
                    color: AppColors.figmaPrimary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'ONE QUICK CHECK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.accent : AppColors.figmaPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isEmailVerification
                    ? 'Verify Your Email'
                    : 'Verify Reset Code',
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
                'Check your inbox. Enter the six-digit code sent to',
                style: AppTypography.bodyMedium.copyWith(
                  color: mutedTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _activeTarget,
                      style: TextStyle(
                        color: isDark ? accent : AppColors.figmaPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isResending ? null : _showEditEmailDialog,
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text(
                      'Edit Email',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'VERIFICATION CODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? accent : AppColors.figmaPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // 6-Digit OTP Input Row with Figma 16px rounded cells
              Row(
                children: [
                  for (int index = 0; index < 6; index++) ...[
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: KeyboardListener(
                          focusNode: _listenerFocusNodes[index],
                          onKeyEvent: (event) => _onKeyEvent(index, event),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.figmaInk,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: cardBg,
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: _errorMessage != null
                                      ? AppColors.figmaError
                                      : (isDark
                                          ? AppColors.borderDark
                                          : const Color(0xFFE5DEE6)),
                                  width: 1.4,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDark ? accent : AppColors.figmaPrimary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _onDigitChanged(index, val),
                          ),
                        ),
                      ),
                    ),
                    if (index < 5) const SizedBox(width: 8),
                  ],
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded, size: 14),
                    label: const Text('Paste Code', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Normal status vs Error / Expired soft banner
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.error.withValues(alpha: 0.16)
                        : AppColors.figmaErrorBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.error : AppColors.figmaError,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.figmaError, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.figmaError,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Your code is valid for 10 minutes.',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Development / Demo Testing Helper Card (hidden in ProductionAuthRepository)
              if (demoSnapshot != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.glacierLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.glacierBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.science_outlined, color: accent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'DEMO / DEV TESTING (No Real SMTP Sent)',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.accent
                                    : AppColors.glacierInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                setState(() => _showDevCode = !_showDevCode),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                _showDevCode ? 'Hide' : 'Show',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _showDevCode
                            ? 'Generated Demo OTP: ${demoSnapshot.code} • ${isDemoExpired ? "EXPIRED — tap Resend" : "Valid for ${remainingValiditySec}s"}'
                            : 'Tap "Show" to view the locally generated 6-digit demo OTP.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.glacierInk,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'QA simulation triggers: 000000 (expired), 888888 (service outage), 999999 (delivery failed).',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () =>
                                _handlePastedCode(demoSnapshot.code),
                            child: Text(
                              'Fill Demo OTP (${demoSnapshot.code})',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          if (!isDemoExpired)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .expireDemoOtpForTesting(
                                      email: _activeTarget,
                                      isPasswordReset:
                                          !widget.isEmailVerification,
                                    );
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              child: const Text(
                                'Expire OTP (Test)',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              PrimaryButton(
                label: _isLoading
                    ? 'Verifying Code...'
                    : (_isSuccess
                        ? 'Verified ✓'
                        : (widget.isEmailVerification
                            ? 'Verify Email'
                            : 'Verify Reset Code')),
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                backgroundColor: _isSuccess
                    ? AppColors.success
                    : (isDark ? null : AppColors.figmaPrimary),
                onPressed: _isLoading ? null : _handleVerifyOtp,
              ),

              const SizedBox(height: 18),

              Center(
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _countdown > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 16, color: mutedTextColor),
                              const SizedBox(width: 6),
                              Text(
                                'Resend code in 00:${_countdown.toString().padLeft(2, '0')}',
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
                            label: Text(
                              'Resend Code',
                              style: TextStyle(
                                color: isDark ? accent : AppColors.figmaPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: _resendCode,
                          ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  "Can't find it? Check your spam folder.",
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isEmailVerification) {
      return VerificationRouteGuard(
        requiredStep: AuthFlowStep.emailOtp,
        child: screen,
      );
    }
    return screen;
  }
}
