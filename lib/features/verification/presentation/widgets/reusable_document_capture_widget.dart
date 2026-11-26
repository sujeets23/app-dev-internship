import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../../data/biometric_privacy_guard.dart';
import '../../data/camera_permission_service.dart';
import '../../data/document_quality_analyzer.dart';
import '../../domain/models/biometric_verification_model.dart';
import '../../domain/models/government_id_model.dart';

/// Reusable document capture & upload card shared between Consumer Government ID
/// verification and Companion KYC verification.
class ReusableDocumentSideCard extends StatelessWidget {
  final String title;
  final String documentType;
  final CapturedDocumentSide? capturedSide;
  final VoidCallback onCameraCaptured;
  final ValueChanged<CapturedDocumentSide> onSidePicked;
  final VoidCallback? onClear;

  const ReusableDocumentSideCard({
    super.key,
    required this.title,
    required this.documentType,
    required this.capturedSide,
    required this.onSidePicked,
    required this.onCameraCaptured,
    this.onClear,
  });

  Future<void> _openRearCameraCapture(BuildContext context) async {
    onCameraCaptured();
    final result = await Navigator.of(context).push<CapturedDocumentSide>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RearCameraDocumentCaptureScreen(
          sideTitle: title,
          documentType: documentType,
        ),
      ),
    );
    if (result != null) {
      onSidePicked(result);
    }
  }

  Future<void> _pickFileOrPdf(BuildContext context) async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Select $title ($documentType)',
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (picked == null) return;

      final Uint8List bytes = await picked.xFile.readAsBytes();
      final ext = (picked.extension ?? '').toLowerCase();
      final isPdf = ext == 'pdf';

      const analyzer = DocumentQualityAnalyzer();
      final quality = await analyzer.analyzeBytes(
        bytes: bytes,
        isPdf: isPdf,
        fileName: picked.name,
      );

      if (!kIsWeb) {
        await FilePicker.clearTemporaryFiles();
      }

      onSidePicked(
        CapturedDocumentSide(
          bytes: bytes,
          fileName: picked.name,
          isPdf: isPdf,
          quality: quality,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not read selected file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bool isCaptured = capturedSide?.bytes != null;
    final bool hasQualityIssues =
        isCaptured && !(capturedSide!.quality.isCompliant);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCaptured
              ? (hasQualityIssues ? AppColors.warning : AppColors.success)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: isCaptured ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCaptured
                      ? (hasQualityIssues
                              ? AppColors.warning
                              : AppColors.success)
                          .withValues(alpha: 0.14)
                      : AppColors.adaptiveHighlightBg(isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCaptured
                      ? (capturedSide!.isPdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.check_circle_rounded)
                      : Icons.add_a_photo_outlined,
                  color: isCaptured
                      ? (hasQualityIssues
                          ? AppColors.warning
                          : AppColors.success)
                      : AppColors.adaptiveAccent(isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCaptured
                          ? (capturedSide!.isPdf
                              ? 'PDF attached in memory (${capturedSide!.fileName ?? "document.pdf"})'
                              : (hasQualityIssues
                                  ? 'Captured — quality warnings detected'
                                  : 'Captured & quality checked in memory ✓'))
                          : 'Scan with rear camera or upload JPG/PNG/PDF',
                      style: TextStyle(
                        color: isCaptured
                            ? (hasQualityIssues
                                ? AppColors.warning
                                : AppColors.success)
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCaptured && onClear != null)
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textTertiary),
                  onPressed: onClear,
                ),
            ],
          ),
          if (isCaptured &&
              !capturedSide!.isPdf &&
              capturedSide!.bytes != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                capturedSide!.bytes!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: Text(
                    isCaptured ? 'Retake Camera' : 'Rear Camera',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _openRearCameraCapture(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text(
                    'Upload PDF/Image',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _pickFileOrPdf(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-screen rear-camera capture view with document alignment guide and flash toggle.
class RearCameraDocumentCaptureScreen extends StatefulWidget {
  final String sideTitle;
  final String documentType;

  const RearCameraDocumentCaptureScreen({
    super.key,
    required this.sideTitle,
    required this.documentType,
  });

  @override
  State<RearCameraDocumentCaptureScreen> createState() =>
      _RearCameraDocumentCaptureScreenState();
}

class _RearCameraDocumentCaptureScreenState
    extends State<RearCameraDocumentCaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _flashOn = false;
  bool _isCapturing = false;
  bool _permPermanentlyDenied = false;
  String? _errorMessage;
  final ICameraPermissionService _permService =
      const DeviceCameraPermissionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initRearCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed &&
        !_isInitialized &&
        !_isCapturing) {
      _initRearCamera();
    }
  }

  Future<void> _initRearCamera() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _permPermanentlyDenied = false;
      });
    }
    final status = await _permService.requestPermission();
    if (!mounted) return;

    if (status == CameraPermissionState.denied ||
        status == CameraPermissionState.permanentlyDenied ||
        status == CameraPermissionState.restricted) {
      setState(() {
        _permPermanentlyDenied =
            status == CameraPermissionState.permanentlyDenied ||
                status == CameraPermissionState.restricted;
        _errorMessage =
            'Camera permission denied. Enable camera access or upload a PDF/image instead.';
      });
      return;
    }

    if (status == CameraPermissionState.unavailable ||
        kIsWeb ||
        !(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _errorMessage =
            'Rear hardware camera capture is available on iOS and Android devices. Use "Upload PDF/Image" on desktop or web.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No rear camera found on this device.');
        return;
      }
      final backCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to open rear camera: $e');
      }
    }
  }

  Future<void> _toggleFlash() async {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized) return;
    try {
      final next = !_flashOn;
      await ctrl.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _flashOn = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flash is not supported on this camera.')),
        );
      }
    }
  }

  Future<void> _captureDocumentFrame() async {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);
    String? tempPath;
    try {
      final xFile = await ctrl.takePicture();
      tempPath = xFile.path;
      final Uint8List bytes = await xFile.readAsBytes();
      const analyzer = DocumentQualityAnalyzer();
      final quality = await analyzer.analyzeBytes(
        bytes: bytes,
        isPdf: false,
        fileName: 'captured_doc.jpg',
      );
      await _disposeCamera();
      if (mounted) {
        Navigator.of(context).pop(
          CapturedDocumentSide(
            bytes: bytes,
            fileName: 'rear_camera_capture.jpg',
            isPdf: false,
            quality: quality,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Capture failed: $e';
        });
      }
    } finally {
      await BiometricPrivacyGuard.deleteTempFileIfExists(tempPath);
    }
  }

  Future<void> _disposeCamera() async {
    final ctrl = _controller;
    _controller = null;
    _isInitialized = false;
    if (ctrl != null) {
      try {
        await ctrl.setFlashMode(FlashMode.off);
      } catch (_) {}
      try {
        await ctrl.dispose();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.sideTitle} • ${widget.documentType}',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _flashOn ? AppColors.warning : Colors.white70,
            ),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isInitialized && _controller != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize?.height ?? 1,
                            height: _controller!.value.previewSize?.width ?? 1,
                            child: CameraPreview(_controller!),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _errorMessage ?? 'Starting rear camera...',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                if (_permPermanentlyDenied) ...[
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: AppColors.accent,
                                      side: const BorderSide(
                                          color: AppColors.accent),
                                    ),
                                    onPressed: _permService.openSettings,
                                    icon: const Icon(Icons.settings_outlined,
                                        size: 16),
                                    label: const Text('Open App Settings'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      CustomPaint(painter: _DocCornerFramePainter()),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Align all 4 corners horizontally inside the guides. Avoid shadows and glare.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: PrimaryButton(
                label: _isCapturing ? 'Analyzing Image...' : 'Capture Document',
                icon: Icons.camera_alt_rounded,
                isLoading: _isCapturing,
                onPressed:
                    (_isInitialized && !_isCapturing) ? _captureDocumentFrame : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable on-device document quality card listing sharpness, glare, edges, lighting & orientation.
class ReusableDocumentQualitySection extends StatelessWidget {
  final DocumentQualityFeedback quality;
  final String sideLabel;

  const ReusableDocumentQualitySection({
    super.key,
    required this.quality,
    required this.sideLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sideLabel.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.adaptiveAccent(isDark),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (quality.isPdfUpload)
          _buildCheckTile(
            context,
            'Digital PDF Validation',
            'PDF header signature verified in memory (pixel blur/glare N/A for PDF).',
            quality.isCompliant,
          )
        else ...[
          _buildCheckTile(
            context,
            'Sharpness & Focus (Anti-Blur)',
            quality.isSharp
                ? 'Edge detail crisp (variance: ${quality.sharpnessScore.toStringAsFixed(0)}).'
                : 'Low edge detail / blur detected. Retake steadily.',
            quality.isSharp,
          ),
          _buildCheckTile(
            context,
            'Glare & Reflection',
            quality.isNoGlare
                ? 'No overexposed glare patches found.'
                : 'Specular glare detected (${(quality.glareRatio * 100).toStringAsFixed(0)}% bright area). Tilt slightly.',
            quality.isNoGlare,
          ),
          _buildCheckTile(
            context,
            'Full Edges & Framing',
            quality.areEdgesVisible
                ? 'Document detail extends appropriately inside boundary.'
                : 'Document appears cropped or outside frame.',
            quality.areEdgesVisible,
          ),
          _buildCheckTile(
            context,
            'Ambient Lighting',
            quality.isLightingAdequate
                ? 'Balanced luminance (${quality.meanLuminance.toStringAsFixed(0)}/255).'
                : 'Lighting too dim or washed out (${quality.meanLuminance.toStringAsFixed(0)}/255).',
            quality.isLightingAdequate,
          ),
          _buildCheckTile(
            context,
            'Horizontal Orientation',
            quality.isOrientationCorrect
                ? 'Landscape orientation confirmed.'
                : 'Image appears vertical; rotate horizontally.',
            quality.isOrientationCorrect,
          ),
        ],
      ],
    );
  }

  Widget _buildCheckTile(
    BuildContext context,
    String title,
    String desc,
    bool passed,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: passed
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.warning,
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: passed ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocCornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const cornerLength = 28.0;
    const padX = 24.0;
    final padY = size.height * 0.22;

    const left = padX;
    final top = padY;
    final right = size.width - padX;
    final bottom = size.height - padY;

    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), paint);

    canvas.drawLine(
        Offset(right, top), Offset(right - cornerLength, top), paint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), paint);

    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), paint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left, bottom - cornerLength), paint);

    canvas.drawLine(
        Offset(right, bottom), Offset(right - cornerLength, bottom), paint);
    canvas.drawLine(
        Offset(right, bottom), Offset(right, bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
