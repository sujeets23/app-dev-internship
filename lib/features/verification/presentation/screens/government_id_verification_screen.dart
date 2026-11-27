import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../data/government_id_repository.dart';
import '../../domain/models/government_id_model.dart';
import '../widgets/reusable_document_capture_widget.dart';

final governmentIdRepositoryProvider = Provider<IGovernmentIdRepository>((ref) {
  return MockGovernmentIdRepository();
});

class GovernmentIdVerificationScreen extends ConsumerStatefulWidget {
  const GovernmentIdVerificationScreen({super.key});

  @override
  ConsumerState<GovernmentIdVerificationScreen> createState() =>
      _GovernmentIdVerificationScreenState();
}

class _GovernmentIdVerificationScreenState
    extends ConsumerState<GovernmentIdVerificationScreen> {
  GovIdVerificationStage _currentStage =
      GovIdVerificationStage.countrySelection;

  GovernmentIdCountry _selectedCountry = GovernmentIdCountry.india;
  String _selectedDocType = 'Aadhaar Card';
  final TextEditingController _docNumberController = TextEditingController();

  CapturedDocumentSide? _frontSide;
  CapturedDocumentSide? _backSide;

  bool _consentAffirmed = false;
  bool _isSubmitting = false;
  bool _docNumberTouched = false;
  GovIdSubmissionResult? _submissionResult;

  String? get _docNumberError =>
      GovernmentIdValidator.validate(_selectedDocType, _docNumberController.text);

  bool get _hasValidDocNumber => _docNumberError == null;

  @override
  void dispose() {
    _docNumberController.dispose();
    _frontSide?.secureWipe();
    _backSide?.secureWipe();
    super.dispose();
  }

  Future<void> _handleSubmitDocument() async {
    final docError = _docNumberError;
    if (docError != null) {
      setState(() {
        _docNumberTouched = true;
        _currentStage = GovIdVerificationStage.documentSelection;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(docError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_consentAffirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please affirm the document privacy and authenticity consent.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = GovernmentIdData(
      country: _selectedCountry,
      documentType: _selectedDocType,
      documentNumber: _docNumberController.text.trim(),
      frontImageBytes: _frontSide?.bytes,
      backImageBytes: _backSide?.bytes,
      isFrontPdf: _frontSide?.isPdf ?? false,
      isBackPdf: _backSide?.isPdf ?? false,
      quality: _frontSide?.quality ?? const DocumentQualityFeedback(),
    );

    final repo = ref.read(governmentIdRepositoryProvider);
    final result = await repo.submitDocument(data);

    // Clear screen references immediately after repository wipe
    _frontSide?.secureWipe();
    _backSide?.secureWipe();

    if (!mounted) return;

    ref.read(authProvider.notifier).setDocStatus(
          result.status,
          country: _selectedCountry.countryName,
          docType: _selectedDocType,
          docId: result.referenceId,
        );

    setState(() {
      _isSubmitting = false;
      _submissionResult = result;
      _currentStage = GovIdVerificationStage.statusResult;
    });
  }

  Future<void> _refreshPendingStatus() async {
    final refId = _submissionResult?.referenceId;
    if (refId == null) return;
    setState(() => _isSubmitting = true);
    final result =
        await ref.read(governmentIdRepositoryProvider).fetchKycStatus(refId);
    if (!mounted) return;

    ref.read(authProvider.notifier).setDocStatus(
          result.status,
          country: _selectedCountry.countryName,
          docType: _selectedDocType,
          docId: result.referenceId,
        );

    setState(() {
      _isSubmitting = false;
      _submissionResult = result;
    });
  }

  void _retryFromCapture() {
    _frontSide?.secureWipe();
    _backSide?.secureWipe();
    setState(() {
      _frontSide = null;
      _backSide = null;
      _submissionResult = null;
      _currentStage = GovIdVerificationStage.documentCapture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    final bool canGoBackStage = _currentStage.index > 0 &&
        _currentStage != GovIdVerificationStage.statusResult;
    final bool showLeading = canGoBackStage || Navigator.canPop(context);

    final screen = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showLeading
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () {
                  if (canGoBackStage) {
                    setState(() {
                      _currentStage = GovIdVerificationStage
                          .values[_currentStage.index - 1];
                    });
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: Text(
          'Government ID Verification',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!Navigator.canPop(context))
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.adaptiveAccent(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStage != GovIdVerificationStage.statusResult)
              _buildStageProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: _buildCurrentStageView(),
              ),
            ),
          ],
        ),
      ),
    );

    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.govId,
      child: screen,
    );
  }

  Widget _buildStageProgress() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.adaptiveAccent(isDark);
    final currentIdx = _currentStage.index;
    const total = 5;
    final progress = (currentIdx + 1) / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'STAGE ${currentIdx + 1} OF $total: ${_getStageTitle(_currentStage).toUpperCase()}',
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
                '${(progress * 100).toInt()}%',
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
              value: progress,
              backgroundColor: accent.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  String _getStageTitle(GovIdVerificationStage stage) {
    switch (stage) {
      case GovIdVerificationStage.countrySelection:
        return 'Country Selection';
      case GovIdVerificationStage.documentSelection:
        return 'Document Selection';
      case GovIdVerificationStage.documentCapture:
        return 'Document Capture';
      case GovIdVerificationStage.qualityGuidance:
        return 'Quality Guidance';
      case GovIdVerificationStage.reviewAndSubmit:
        return 'Review & Submit';
      case GovIdVerificationStage.statusResult:
        return 'Verification Status';
    }
  }

  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case GovIdVerificationStage.countrySelection:
        return _buildStage1Country();
      case GovIdVerificationStage.documentSelection:
        return _buildStage2Document();
      case GovIdVerificationStage.documentCapture:
        return _buildStage3Capture();
      case GovIdVerificationStage.qualityGuidance:
        return _buildStage4Quality();
      case GovIdVerificationStage.reviewAndSubmit:
        return _buildStage5Review();
      case GovIdVerificationStage.statusResult:
        return _buildStage6Result();
    }
  }

  // STAGE 1: COUNTRY SELECTION
  Widget _buildStage1Country() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Document Issuing Country',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 6),
        const Text(
          'India is selected by default. Choose any supported issuing region to load eligible official documents.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        ...GovernmentIdCountry.values.map((country) {
          final isSelected = _selectedCountry == country;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.adaptiveHighlightBg(isDark)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.adaptiveAccent(isDark)
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Text(country.flag, style: const TextStyle(fontSize: 26)),
                title: Text(
                  country.countryName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.glacierInk)
                        : textColor,
                  ),
                ),
                subtitle: Text(
                  '${country.supportedDocuments.length} document types supported',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: AppColors.adaptiveAccent(isDark))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCountry = country;
                    _selectedDocType = country.supportedDocuments.first;
                    _frontSide = null;
                    _backSide = null;
                  });
                },
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue to Document Selection',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            setState(() {
              _currentStage = GovIdVerificationStage.documentSelection;
            });
          },
        ),
      ],
    );
  }

  // STAGE 2: DOCUMENT SELECTION
  Widget _buildStage2Document() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Document for ${_selectedCountry.countryName}',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a document valid in your selected region and enter its mandatory ID number.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        ..._selectedCountry.supportedDocuments.map((docType) {
          final isSelected = _selectedDocType == docType;
          final needsBack = GovernmentIdCountry.requiresBackSide(docType);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.adaptiveHighlightBg(isDark)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.adaptiveAccent(isDark)
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Icon(
                  Icons.badge_outlined,
                  color: isSelected
                      ? AppColors.adaptiveAccent(isDark)
                      : AppColors.textSecondary,
                ),
                title: Text(
                  docType,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.glacierInk)
                        : textColor,
                  ),
                ),
                subtitle: Text(
                  needsBack ? 'Requires Front & Back capture' : 'Front side only',
                  style: TextStyle(
                    fontSize: 11,
                    color: needsBack ? AppColors.textSecondary : AppColors.success,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: AppColors.adaptiveAccent(isDark))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDocType = docType;
                    _frontSide = null;
                    _backSide = null;
                  });
                },
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        TextField(
          controller: _docNumberController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() => _docNumberTouched = true),
          decoration: InputDecoration(
            labelText: '$_selectedDocType Number (Mandatory Proof) *',
            hintText: GovernmentIdValidator.hintForDocumentType(_selectedDocType),
            helperText: 'Mandatory proof • Demo: PENDING / REJECT / RETRY',
            helperMaxLines: 2,
            errorText: _docNumberTouched ? _docNumberError : null,
            errorMaxLines: 2,
            prefixIcon: const Icon(Icons.pin_outlined),
            suffixIcon: _hasValidDocNumber
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Proceed to Document Capture',
          icon: Icons.camera_alt_rounded,
          onPressed: () {
            setState(() => _docNumberTouched = true);
            if (_docNumberError != null) {
              return;
            }
            setState(() {
              _currentStage = GovIdVerificationStage.documentCapture;
            });
          },
        ),
      ],
    );
  }

  // STAGE 3: REAR CAMERA CAPTURE & PDF/IMAGE UPLOAD
  Widget _buildStage3Capture() {
    final needsBack = GovernmentIdCountry.requiresBackSide(_selectedDocType);
    final bool ready = _frontSide?.bytes != null &&
        (!needsBack || _backSide?.bytes != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture $_selectedDocType',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Use the rear camera with edge-alignment guides & flash, or upload a crisp JPG/PNG/PDF directly.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        ReusableDocumentSideCard(
          title: 'Front Side',
          documentType: _selectedDocType,
          capturedSide: _frontSide,
          onCameraCaptured: () {},
          onSidePicked: (side) {
            setState(() {
              _frontSide?.secureWipe();
              _frontSide = side;
            });
          },
          onClear: () {
            setState(() {
              _frontSide?.secureWipe();
              _frontSide = null;
            });
          },
        ),

        if (needsBack) ...[
          const SizedBox(height: 14),
          ReusableDocumentSideCard(
            title: 'Back Side',
            documentType: _selectedDocType,
            capturedSide: _backSide,
            onCameraCaptured: () {},
            onSidePicked: (side) {
              setState(() {
                _backSide?.secureWipe();
                _backSide = side;
              });
            },
            onClear: () {
              setState(() {
                _backSide?.secureWipe();
                _backSide = null;
              });
            },
          ),
        ],

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue to Quality Guidance',
          icon: Icons.fact_check_outlined,
          onPressed: ready
              ? () {
                  setState(() {
                    _currentStage = GovIdVerificationStage.qualityGuidance;
                  });
                }
              : null,
        ),
      ],
    );
  }

  // STAGE 4: GENUINE ON-DEVICE QUALITY GUIDANCE
  Widget _buildStage4Quality() {
    final frontQuality = _frontSide?.quality ?? const DocumentQualityFeedback();
    final backQuality = _backSide?.quality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'On-Device Quality Guidance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Real in-memory pixel checks evaluate sharpness, glare, lighting, framing, and orientation. OCR & government authenticity require backend APIs.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        ReusableDocumentQualitySection(
          quality: frontQuality,
          sideLabel: 'Front Side Quality',
        ),

        if (backQuality != null) ...[
          const SizedBox(height: 16),
          ReusableDocumentQualitySection(
            quality: backQuality,
            sideLabel: 'Back Side Quality',
          ),
        ],

        if (!frontQuality.isCompliant ||
            (backQuality != null && !backQuality.isCompliant)) ...[
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Retake Document Photos',
            icon: Icons.camera_alt_outlined,
            onPressed: _retryFromCapture,
          ),
        ],

        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Proceed to Review & Submit',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            setState(() {
              _currentStage = GovIdVerificationStage.reviewAndSubmit;
            });
          },
        ),
      ],
    );
  }

  // STAGE 5: REVIEW & SUBMIT
  Widget _buildStage5Review() {
    final needsBack = GovernmentIdCountry.requiresBackSide(_selectedDocType);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Confirm Submission',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Inspect your document previews and privacy consent before submitting.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow(
                  'Country', '${_selectedCountry.flag} ${_selectedCountry.countryName}'),
              const Divider(height: 20),
              _buildReviewRow('Document Type', _selectedDocType),
              const Divider(height: 20),
              _buildReviewRow(
                'ID Proof Number',
                _docNumberController.text.trim(),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Front Side Preview',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textTertiaryDark : AppColors.textTertiary)),
                  TextButton(
                    onPressed: () => setState(() {
                      _currentStage = GovIdVerificationStage.documentCapture;
                    }),
                    child: const Text('Edit / Retake'),
                  ),
                ],
              ),
              if (_frontSide != null && !_frontSide!.isPdf && _frontSide!.bytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _frontSide!.bytes!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_frontSide != null && _frontSide!.isPdf)
                Text('PDF: ${_frontSide!.fileName ?? "front.pdf"}'),
              if (needsBack) ...[
                const Divider(height: 20),
                Text('Back Side Preview',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textTertiaryDark : AppColors.textTertiary)),
                const SizedBox(height: 8),
                if (_backSide != null && !_backSide!.isPdf && _backSide!.bytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _backSide!.bytes!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_backSide != null && _backSide!.isPdf)
                  Text('PDF: ${_backSide!.fileName ?? "back.pdf"}'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          value: _consentAffirmed,
          activeColor: AppColors.adaptiveAccent(isDark),
          checkColor: AppColors.adaptiveOnAccent(isDark),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I confirm this government ID belongs to me and consent to transient verification processing under Date² privacy standards.',
            style: TextStyle(fontSize: 12, height: 1.3),
          ),
          onChanged: (val) => setState(() => _consentAffirmed = val ?? false),
        ),
        const SizedBox(height: 20),

        PrimaryButton(
          label: _isSubmitting
              ? 'Submitting (Demo)...'
              : 'Submit Document for Verification',
          icon: Icons.check_circle_rounded,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _handleSubmitDocument,
        ),
      ],
    );
  }

  // STAGE 6: ALL STATUS RESULTS (VERIFIED, PENDING, REJECTED, RETRY)
  Widget _buildStage6Result() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _submissionResult;
    final status = res?.status ?? GovIdStatus.pendingReview;
    final bool isVerified = status == GovIdStatus.verified;
    final bool isPending = status == GovIdStatus.pendingReview ||
        status == GovIdStatus.submitted;
    final bool isRetry = status == GovIdStatus.retryRequired;

    final Color statusColor = isVerified
        ? AppColors.success
        : (isPending
            ? AppColors.adaptiveAccent(isDark)
            : (isRetry ? AppColors.warning : AppColors.error));

    final IconData statusIcon = isVerified
        ? Icons.verified_user_rounded
        : (isPending
            ? Icons.hourglass_top_rounded
            : (isRetry ? Icons.refresh_rounded : Icons.gpp_bad_rounded));

    final String title = isVerified
        ? 'Government ID Checked (Demo)'
        : (isPending
            ? 'Verification Pending Review'
            : (isRetry ? 'Retry Capture Required' : 'Document Rejected'));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2.2),
          ),
          child: Icon(statusIcon, color: statusColor, size: 50),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          res?.message ?? 'Document verification status unavailable.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        if (res?.referenceId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.encreElevated : AppColors.glacierLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Reference ID: ${res!.referenceId}',
              style: TextStyle(
                color: AppColors.adaptiveAccent(isDark),
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.adaptiveBorder(isDark)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.success, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Privacy Notice: Temporary document captures and local byte buffers have been cleared. Backend OCR & official KYC matching require live API integration.',
                  style: TextStyle(fontSize: 11, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        if (isVerified)
          PrimaryButton(
            label: 'Proceed to Personal Info',
            icon: Icons.person_outline_rounded,
            onPressed: () {
              if (ref.read(onboardingProvider).currentStep == 0) {
                ref.read(onboardingProvider.notifier).startOnboarding();
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                (route) => false,
              );
            },
          )
        else if (isPending) ...[
          PrimaryButton(
            label: _isSubmitting ? 'Checking Status...' : 'Check KYC Status',
            icon: Icons.refresh_rounded,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _refreshPendingStatus,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Edit & Resubmit Document',
            onPressed: _retryFromCapture,
          ),
        ] else
          PrimaryButton(
            label: 'Retake & Resubmit Document',
            icon: Icons.camera_alt_rounded,
            onPressed: _retryFromCapture,
          ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary, fontSize: 12)),
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
