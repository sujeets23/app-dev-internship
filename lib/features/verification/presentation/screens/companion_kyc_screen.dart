import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import '../../data/biometric_verification_service.dart';
import '../../domain/models/biometric_verification_model.dart';
import '../../domain/models/government_id_model.dart';
import '../widgets/reusable_document_capture_widget.dart';
import 'biometric_verification_screen.dart';

/// Reusable Companion KYC Wizard decoupled from Consumer Onboarding Gate.
/// Reuses country-aware document capture, quality guidance, and live camera
/// biometric liveness verification without marketplace/escrow coupling.
class CompanionKycScreen extends ConsumerStatefulWidget {
  const CompanionKycScreen({super.key});

  @override
  ConsumerState<CompanionKycScreen> createState() => _CompanionKycScreenState();
}

class _CompanionKycScreenState extends ConsumerState<CompanionKycScreen> {
  int _currentStep = 0; // 0: Intro, 1: Gov ID, 2: Selfie, 3: Review, 4: Result

  GovernmentIdCountry _selectedCountry = GovernmentIdCountry.india;
  String _selectedIdType = 'Aadhaar Card';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();

  CapturedDocumentSide? _frontSide;
  CapturedDocumentSide? _backSide;

  String? _biometricProofId;
  bool _policeClearanceChecked = false;
  bool _isSubmitting = false;
  bool _docNumberTouched = false;
  String? _kycReferenceId;
  String? _kycStatusMessage;
  CompanionKycStatus _resultStatus = CompanionKycStatus.notStarted;

  final IBiometricVerificationService _service =
      MockBiometricVerificationService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _docNumberController.dispose();
    _frontSide?.secureWipe();
    _backSide?.secureWipe();
    super.dispose();
  }

  Future<void> _startLiveBiometricSelfie() async {
    final proofId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BiometricVerificationScreen(isCompanionFlow: true),
      ),
    );

    if (!mounted) return;

    if (proofId != null && proofId.isNotEmpty) {
      setState(() {
        _biometricProofId = proofId;
      });
    } else {
      // Strictly never synthesize a passed biometric proof on cancel/failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Live biometric liveness selfie was cancelled or incomplete.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _submitKyc() async {
    final docError = GovernmentIdValidator.validate(
      _selectedIdType,
      _docNumberController.text,
    );
    if (docError != null) {
      setState(() {
        _docNumberTouched = true;
        _currentStep = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(docError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_policeClearanceChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please affirm the background & safety standards check.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final submission = CompanionKycSubmission(
      countryName: _selectedCountry.countryName,
      idType: _selectedIdType,
      frontIdBytes: _frontSide?.bytes,
      backIdBytes: _backSide?.bytes,
      selfieVerificationProofId: _biometricProofId,
      policeClearanceAffirmed: _policeClearanceChecked,
      legalFullName: _fullNameController.text.trim(),
      documentNumber: _docNumberController.text.trim(),
    );

    final res = await _service.submitCompanionKyc(submission);

    _frontSide?.secureWipe();
    _backSide?.secureWipe();

    if (!mounted) return;

    final docUpper = _docNumberController.text.trim().toUpperCase();
    final bool isSuccess = res['success'] == true;
    final CompanionKycStatus finalStatus;
    if (!isSuccess) {
      finalStatus = CompanionKycStatus.rejected;
    } else if (docUpper.startsWith('APPROVE')) {
      finalStatus = CompanionKycStatus.approved;
    } else if (docUpper.startsWith('REJECT')) {
      finalStatus = CompanionKycStatus.rejected;
    } else {
      finalStatus = CompanionKycStatus.pendingVerification;
    }

    final refId = res['kyc_reference_id'] as String?;
    ref.read(authProvider.notifier).setCompanionKycState(
          finalStatus,
          referenceId: refId,
        );

    setState(() {
      _isSubmitting = false;
      _kycReferenceId = refId;
      _resultStatus = finalStatus;
      _kycStatusMessage = finalStatus == CompanionKycStatus.rejected
          ? 'Demo Companion KYC rejected. Please retake clear ID photos and retry.'
          : (res['message'] as String? ?? 'Submitted.');
      _currentStep = 4;
    });
  }

  void _retryFlow() {
    _frontSide?.secureWipe();
    _backSide?.secureWipe();
    setState(() {
      _frontSide = null;
      _backSide = null;
      _biometricProofId = null;
      _resultStatus = CompanionKycStatus.inProgress;
      _currentStep = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 4) {
              setState(() => _currentStep--);
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Companion KYC Verification',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 4) _buildStepProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: _buildCurrentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgress() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.adaptiveAccent(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'STEP ${_currentStep + 1} OF 4: ${_getStepTitle(_currentStep).toUpperCase()}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${((_currentStep + 1) * 25)}%',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 4.0,
              backgroundColor: accent.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Introduction';
      case 1:
        return 'Government ID';
      case 2:
        return 'Live Biometric Selfie';
      case 3:
        return 'Review & Submit';
      default:
        return 'Verification Result';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 0:
        return _buildScreen1Intro();
      case 1:
        return _buildScreen2GovId();
      case 2:
        return _buildScreen3LiveSelfie();
      case 3:
        return _buildScreen4Review();
      case 4:
      default:
        return _buildScreen5Result();
    }
  }

  Widget _buildScreen1Intro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.encrePrismGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.primaryShadow,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.accent, size: 32),
                  SizedBox(width: 10),
                  Text(
                    'Trust & Safety Escrow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Companion KYC is independent of regular dating onboarding. Applicants pair an eligible Government ID with an active camera liveness selfie.',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'COMPANION KYC REQUIREMENTS',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.adaptiveAccent(
              Theme.of(context).brightness == Brightness.dark,
            ),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _buildRequirementCard(
          icon: Icons.badge_outlined,
          title: '1. Country-Aware Government ID Capture',
          subtitle:
              'Capture crisp front (and back where required) views or upload PDF/image.',
        ),
        _buildRequirementCard(
          icon: Icons.face_retouching_natural_rounded,
          title: '2. Live Biometric Liveness Selfie',
          subtitle:
              'Completed via real front-camera oval & randomized anti-spoofing challenges.',
        ),
        _buildRequirementCard(
          icon: Icons.policy_outlined,
          title: '3. Background & Safety Affirmation',
          subtitle:
              'Explicit safety consent before companion KYC submission.',
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue to ID Capture',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            ref
                .read(authProvider.notifier)
                .setCompanionKycState(CompanionKycStatus.inProgress);
            setState(() => _currentStep = 1);
          },
        ),
      ],
    );
  }

  Widget _buildScreen2GovId() {
    final needsBack = GovernmentIdCountry.requiresBackSide(_selectedIdType);
    final bool hasDocs =
        _frontSide?.bytes != null && (!needsBack || _backSide?.bytes != null);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Government ID',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select issuing region and ID type, then capture or upload legible photos.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Country selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GovernmentIdCountry>(
              value: _selectedCountry,
              isExpanded: true,
              items: GovernmentIdCountry.values.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text('${country.flag} ${country.countryName}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedIdType = val.supportedDocuments.first;
                    _frontSide = null;
                    _backSide = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Document Type selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedIdType,
              isExpanded: true,
              items: _selectedCountry.supportedDocuments.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedIdType = val;
                    _frontSide = null;
                    _backSide = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Legal Full Name (matching ID)',
            hintText: 'Enter legal full name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _docNumberController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() => _docNumberTouched = true),
          decoration: InputDecoration(
            labelText: '$_selectedIdType Number (Mandatory Proof) *',
            hintText: GovernmentIdValidator.hintForDocumentType(_selectedIdType),
            helperText: 'Mandatory proof • Demo: APPROVE / REJECT',
            helperMaxLines: 2,
            errorText: _docNumberTouched
                ? GovernmentIdValidator.validate(
                    _selectedIdType,
                    _docNumberController.text,
                  )
                : null,
            errorMaxLines: 2,
            prefixIcon: const Icon(Icons.pin_outlined),
            suffixIcon: GovernmentIdValidator.validate(
                      _selectedIdType,
                      _docNumberController.text,
                    ) ==
                    null
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                : null,
          ),
        ),
        const SizedBox(height: 16),

        ReusableDocumentSideCard(
          title: 'Front View of $_selectedIdType',
          documentType: _selectedIdType,
          capturedSide: _frontSide,
          onCameraCaptured: () {},
          onSidePicked: (side) {
            setState(() {
              _frontSide?.secureWipe();
              _frontSide = side;
            });
          },
          onClear: () => setState(() {
            _frontSide?.secureWipe();
            _frontSide = null;
          }),
        ),

        if (needsBack) ...[
          const SizedBox(height: 12),
          ReusableDocumentSideCard(
            title: 'Back View of $_selectedIdType',
            documentType: _selectedIdType,
            capturedSide: _backSide,
            onCameraCaptured: () {},
            onSidePicked: (side) {
              setState(() {
                _backSide?.secureWipe();
                _backSide = side;
              });
            },
            onClear: () => setState(() {
              _backSide?.secureWipe();
              _backSide = null;
            }),
          ),
        ],

        if (_frontSide != null) ...[
          const SizedBox(height: 16),
          ReusableDocumentQualitySection(
            quality: _frontSide!.quality,
            sideLabel: 'Front View Quality',
          ),
        ],

        const SizedBox(height: 22),

        PrimaryButton(
          label: 'Proceed to Biometric Selfie',
          icon: Icons.arrow_forward_rounded,
          onPressed: hasDocs
              ? () {
                  setState(() => _docNumberTouched = true);
                  if (GovernmentIdValidator.validate(
                        _selectedIdType,
                        _docNumberController.text,
                      ) !=
                      null) {
                    return;
                  }
                  setState(() => _currentStep = 2);
                }
              : null,
        ),
        if (!hasDocs) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              needsBack
                  ? 'Capture or upload both Front and Back views to continue'
                  : 'Capture or upload Front view to continue',
              style: const TextStyle(color: AppColors.error, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScreen3LiveSelfie() {
    final bool hasSelfie = _biometricProofId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Biometric Liveness Selfie',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Complete the front-camera oval alignment and active liveness challenge to pair your selfie.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: hasSelfie
                ? AppColors.successLight
                : (isDark ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: hasSelfie
                  ? AppColors.success
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: hasSelfie
                      ? AppColors.success.withValues(alpha: 0.18)
                      : AppColors.adaptiveHighlightBg(isDark),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSelfie
                      ? Icons.verified_rounded
                      : Icons.camera_front_rounded,
                  color: hasSelfie
                      ? AppColors.success
                      : AppColors.adaptiveAccent(isDark),
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasSelfie
                    ? 'On-Device Liveness Confirmed!'
                    : 'Camera Ready for Live Scan',
                style: TextStyle(
                  color: hasSelfie
                      ? AppColors.success
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasSelfie
                    ? 'Proof ID: $_biometricProofId'
                    : 'Tap below to launch the front-camera alignment and active liveness flow.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              if (!hasSelfie)
                PrimaryButton(
                  label: 'Launch Biometric Camera',
                  icon: Icons.camera_alt_rounded,
                  onPressed: _startLiveBiometricSelfie,
                )
              else
                SecondaryButton(
                  label: 'Retake Biometric Selfie',
                  icon: Icons.refresh_rounded,
                  onPressed: _startLiveBiometricSelfie,
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        PrimaryButton(
          label: 'Proceed to Review & Submit',
          icon: Icons.arrow_forward_rounded,
          onPressed: hasSelfie ? () => setState(() => _currentStep = 3) : null,
        ),
      ],
    );
  }

  Widget _buildScreen4Review() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Application Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Verify your uploaded documents, live selfie proof, and background consent before submission.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: Column(
            children: [
              _buildReviewRow(
                  'Region', '${_selectedCountry.flag} ${_selectedCountry.countryName}'),
              const Divider(height: 20),
              _buildReviewRow(
                'Legal Full Name',
                _fullNameController.text.isEmpty
                    ? '(Not provided)'
                    : _fullNameController.text,
              ),
              const Divider(height: 20),
              _buildReviewRow('Document Type', _selectedIdType),
              const Divider(height: 20),
              _buildReviewRow(
                'ID Proof Number',
                _docNumberController.text.trim(),
              ),
              const Divider(height: 20),
              _buildReviewRow(
                'ID Front/Back',
                _backSide != null ? 'Both sides ready' : 'Front ready',
              ),
              const Divider(height: 20),
              _buildReviewRow(
                'Liveness Selfie',
                _biometricProofId != null ? 'Completed ✓' : 'Incomplete',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        CheckboxListTile(
          value: _policeClearanceChecked,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I affirm that I have no criminal record and consent to official background verification under Date² safety guidelines.',
            style: TextStyle(fontSize: 12, height: 1.35),
          ),
          onChanged: (val) =>
              setState(() => _policeClearanceChecked = val ?? false),
        ),
        const SizedBox(height: 24),

        PrimaryButton(
          label: _isSubmitting ? 'Submitting...' : 'Submit Companion KYC',
          icon: Icons.check_circle_rounded,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitKyc,
        ),
      ],
    );
  }

  Widget _buildScreen5Result() {
    final bool isApproved = _resultStatus == CompanionKycStatus.approved;
    final bool isPending =
        _resultStatus == CompanionKycStatus.pendingVerification ||
            _resultStatus == CompanionKycStatus.submitted;

    final Color color = isApproved
        ? AppColors.success
        : (isPending ? AppColors.primary : AppColors.error);

    final IconData icon = isApproved
        ? Icons.verified_user_rounded
        : (isPending ? Icons.hourglass_top_rounded : Icons.gpp_bad_rounded);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 52),
        ),
        const SizedBox(height: 20),
        Text(
          'Companion KYC: ${_resultStatus.label}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          _kycStatusMessage ?? 'Companion KYC status updated.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        if (_kycReferenceId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.encreElevated
                  : AppColors.glacierLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Reference ID: $_kycReferenceId',
              style: TextStyle(
                color: AppColors.adaptiveAccent(
                    Theme.of(context).brightness == Brightness.dark),
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.adaptiveBorder(
                  Theme.of(context).brightness == Brightness.dark),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.success),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Privacy Hygiene: Local document image buffers have been cleared. Backend OCR & police verification require live API integration.',
                  style: TextStyle(fontSize: 12, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (_resultStatus == CompanionKycStatus.rejected ||
            _resultStatus == CompanionKycStatus.retryRequired) ...[
          PrimaryButton(
            label: 'Retry Companion KYC',
            icon: Icons.refresh_rounded,
            onPressed: _retryFlow,
          ),
          const SizedBox(height: 12),
        ],
        if (isPending) ...[
          PrimaryButton(
            label: 'Approve Demo Status',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              ref.read(authProvider.notifier).setCompanionKycState(
                    CompanionKycStatus.approved,
                    referenceId: _kycReferenceId,
                  );
              setState(() {
                _resultStatus = CompanionKycStatus.approved;
                _kycStatusMessage =
                    'Demo Mode: Companion KYC status updated to Approved.';
              });
            },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Resubmit / Retry',
            onPressed: _retryFlow,
          ),
          const SizedBox(height: 12),
        ],
        SecondaryButton(
          label: 'Done • Return',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildRequirementCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.adaptiveHighlightBg(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: AppColors.adaptiveAccent(isDark), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
