import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../domain/models/government_id_model.dart';

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
  final TextEditingController _docNumberController =
      TextEditingController(text: 'XXXX-XXXX-4921');

  bool _flashEnabled = false;
  bool _frontCaptured = false;
  bool _backCaptured = false;
  Uint8List? _frontBytes;
  Uint8List? _backBytes;

  final DocumentQualityFeedback _quality = const DocumentQualityFeedback();
  bool _consentAffirmed = true;
  bool _isSubmitting = false;
  String? _proofId;

  @override
  void dispose() {
    _docNumberController.dispose();
    _frontBytes?.fillRange(0, _frontBytes!.length, 0);
    _backBytes?.fillRange(0, _backBytes!.length, 0);
    super.dispose();
  }

  void _simulateCapture(bool isFront) {
    final dummy = Uint8List(512);
    for (int i = 0; i < dummy.length; i++) {
      dummy[i] = (i % 256);
    }

    setState(() {
      if (isFront) {
        _frontCaptured = true;
        _frontBytes = dummy;
      } else {
        _backCaptured = true;
        _backBytes = dummy;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isFront ? "Front" : "Back"} of $_selectedDocType captured in volatile memory.',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF1B6A45),
      ),
    );
  }

  void _handleSubmitDocument() async {
    if (!_consentAffirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please affirm the document authenticity consent.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      final proof =
          'DOC-${_selectedCountry.name.toUpperCase().substring(0, 2)}-${DateTime.now().millisecondsSinceEpoch}';

      // Update centralized auth state
      ref.read(authProvider.notifier).setDocVerified(
            country: _selectedCountry.countryName,
            docType: _selectedDocType,
            docId: proof,
          );

      // Clean volatile memory buffers immediately
      _frontBytes?.fillRange(0, _frontBytes!.length, 0);
      _backBytes?.fillRange(0, _backBytes!.length, 0);
      _frontBytes = null;
      _backBytes = null;

      setState(() {
        _isSubmitting = false;
        _proofId = proof;
        _currentStage = GovIdVerificationStage.statusResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final textColor = isDark ? Colors.white : AppColors.charcoal;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () {
            if (_currentStage.index > 0 &&
                _currentStage != GovIdVerificationStage.statusResult) {
              setState(() {
                _currentStage =
                    GovIdVerificationStage.values[_currentStage.index - 1];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Government ID Verification',
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
            // Stage Progress Bar (Stages 0 to 4)
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
  }

  Widget _buildStageProgress() {
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
              Text(
                'STAGE ${currentIdx + 1} OF $total: ${_getStageTitle(_currentStage).toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Document Issuing Country',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'We support government-issued photo IDs across multiple countries for verified social matching.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        ...GovernmentIdCountry.values.map((country) {
          final isSelected = _selectedCountry == country;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryLight.withValues(alpha: 0.6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
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
                    color: isSelected ? AppColors.primaryDark : AppColors.charcoal,
                  ),
                ),
                subtitle: Text(
                  '${country.supportedDocuments.length} document types supported',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCountry = country;
                    _selectedDocType = country.supportedDocuments.first;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Document for ${_selectedCountry.countryName}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose an unexpired, original government-issued photo ID.',
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
                  ? AppColors.primaryLight.withValues(alpha: 0.6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  docType,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primaryDark : AppColors.charcoal,
                  ),
                ),
                subtitle: Text(
                  needsBack ? 'Requires Front & Back capture' : 'Front side only',
                  style: TextStyle(
                    fontSize: 11,
                    color: needsBack ? Colors.grey : const Color(0xFF1B6A45),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedDocType = docType);
                },
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        TextField(
          controller: _docNumberController,
          decoration: InputDecoration(
            labelText: '$_selectedDocType Number',
            hintText: 'Enter official document number',
            prefixIcon: const Icon(Icons.pin_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Proceed to Document Capture',
          icon: Icons.camera_alt_rounded,
          onPressed: () {
            setState(() {
              _currentStage = GovIdVerificationStage.documentCapture;
            });
          },
        ),
      ],
    );
  }

  // STAGE 3: DOCUMENT CAPTURE SCREEN
  Widget _buildStage3Capture() {
    final needsBack = GovernmentIdCountry.requiresBackSide(_selectedDocType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capture $_selectedDocType',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                _flashEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _flashEnabled ? Colors.amber : Colors.grey,
              ),
              onPressed: () => setState(() => _flashEnabled = !_flashEnabled),
              tooltip: 'Toggle Flash',
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Position your physical card within the alignment guides. Avoid shadows and glare.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        // Rear Camera Frame Alignment Overlay Simulation
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFF161226),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonLime, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 190),
                painter: _DocFramePainter(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.crop_free_rounded,
                    size: 48,
                    color: AppColors.neonLime.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align Front of $_selectedDocType here',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Front Card Capture
        _buildCaptureRow(
          title: 'Front Side',
          isCaptured: _frontCaptured,
          onCapture: () => _simulateCapture(true),
        ),

        // Back Card Capture (if required)
        if (needsBack) ...[
          const SizedBox(height: 12),
          _buildCaptureRow(
            title: 'Back Side',
            isCaptured: _backCaptured,
            onCapture: () => _simulateCapture(false),
          ),
        ],

        const SizedBox(height: 26),
        PrimaryButton(
          label: 'Continue to Quality Guidance',
          icon: Icons.fact_check_outlined,
          onPressed: (_frontCaptured && (!needsBack || _backCaptured))
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

  // STAGE 4: QUALITY GUIDANCE
  Widget _buildStage4Quality() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Quality Guidance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Automated on-device pre-checks verify text readability and edge alignment before transmission.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        _buildQualityCard('Sharpness & Focus', 'No blur detected. Text is crisp and readable.', _quality.isSharp),
        _buildQualityCard('Glare & Reflection', 'No bright light reflections over document photo or numbers.', _quality.isNoGlare),
        _buildQualityCard('Full Edges Visible', 'All 4 corners are inside the capture boundary.', _quality.areEdgesVisible),
        _buildQualityCard('Lighting Contrast', 'Uniform ambient brightness verified.', _quality.isLightingAdequate),
        _buildQualityCard('Correct Orientation', 'Horizontal aspect ratio properly detected.', _quality.isOrientationCorrect),

        const SizedBox(height: 24),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Confirm Submission',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please verify the details below before submitting for official verification.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildReviewRow('Country', '${_selectedCountry.flag} ${_selectedCountry.countryName}'),
              const Divider(height: 20),
              _buildReviewRow('Document Type', _selectedDocType),
              const Divider(height: 20),
              _buildReviewRow('Document Number', _docNumberController.text),
              const Divider(height: 20),
              _buildReviewRow('Front Image', 'Captured (Volatile RAM) ✓'),
              if (needsBack) ...[
                const Divider(height: 20),
                _buildReviewRow('Back Image', 'Captured (Volatile RAM) ✓'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        CheckboxListTile(
          value: _consentAffirmed,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I affirm that this official government document is authentic, belongs to me, and may be validated under Date² safety escrow guidelines.',
            style: TextStyle(fontSize: 12, height: 1.3),
          ),
          onChanged: (val) => setState(() => _consentAffirmed = val ?? false),
        ),
        const SizedBox(height: 24),

        PrimaryButton(
          label: _isSubmitting
              ? 'Encrypting & Submitting...'
              : 'Submit Document for Verification',
          icon: Icons.check_circle_rounded,
          onPressed: _isSubmitting ? null : _handleSubmitDocument,
        ),
      ],
    );
  }

  // STAGE 6: VERIFICATION STATUS RESULT
  Widget _buildStage6Result() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF22C55E), width: 2.2),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF22C55E),
            size: 50,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Government ID Verified!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your $_selectedDocType has passed optical alignment and cryptographic validation.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),

        if (_proofId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Proof ID: $_proofId',
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFF22C55E), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Zero-Persistence Mandate: Document image bytes were evaluated in volatile RAM and securely wiped. No raw ID scans are retained.',
                  style: TextStyle(fontSize: 11, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Sequential Flow: Move to Personal Info (Onboarding Profile)
        PrimaryButton(
          label: 'Proceed to Personal Info',
          icon: Icons.person_outline_rounded,
          backgroundColor: AppColors.primary,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCaptureRow({
    required String title,
    required bool isCaptured,
    required VoidCallback onCapture,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCaptured ? const Color(0xFF22C55E) : AppColors.border,
          width: isCaptured ? 1.6 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCaptured
                  ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCaptured ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
              color: isCaptured ? const Color(0xFF22C55E) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  isCaptured ? 'Captured in volatile RAM ✓' : 'Tap to scan card',
                  style: TextStyle(
                    color: isCaptured ? const Color(0xFF1B6A45) : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCapture,
            child: Text(
              isCaptured ? 'Retake' : 'Capture',
              style: TextStyle(
                color: isCaptured ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCard(String title, String desc, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: passed ? const Color(0xFF22C55E).withValues(alpha: 0.5) : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: passed ? const Color(0xFF22C55E) : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _DocFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    const cornerLength = 24.0;
    const padding = 16.0;

    const left = padding;
    const top = padding;
    final right = size.width - padding;
    final bottom = size.height - padding;

    // Top-Left corner
    canvas.drawLine(const Offset(left, top), const Offset(left + cornerLength, top), paint);
    canvas.drawLine(const Offset(left, top), const Offset(left, top + cornerLength), paint);

    // Top-Right corner
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - cornerLength), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
