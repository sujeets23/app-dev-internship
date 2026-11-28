import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import '../../data/biometric_privacy_guard.dart';
import '../../data/face_liveness_detector.dart';
import '../../data/web_face_landmarker_bridge.dart';
import '../../domain/liveness_state_machine.dart';
import '../../domain/models/biometric_verification_model.dart';
import '../providers/biometric_verification_provider.dart';
import 'companion_kyc_screen.dart';
import 'government_id_verification_screen.dart';
import 'security_check_intro_screen.dart';
import 'verification_result_screen.dart';

class BiometricVerificationScreen extends ConsumerStatefulWidget {
  final bool isCompanionFlow;
  const BiometricVerificationScreen({super.key, this.isCompanionFlow = false});

  @override
  ConsumerState<BiometricVerificationScreen> createState() =>
      _BiometricVerificationScreenState();
}

class _BiometricVerificationScreenState
    extends ConsumerState<BiometricVerificationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _scanController;

  CameraController? _cameraController;
  IFaceFrameAnalyzer? _faceAnalyzer;
  IWebFaceScannerBridge? _webBridge;
  bool _isCameraInitialized = false;
  bool _isWebLoadingModel = false;
  bool _isAnalyzingFrame = false;
  DateTime _lastAnalyzedAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _cameraErrorText;
  bool _isCapturingFinal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) {
      _webBridge = createWebFaceScannerBridge();
    }
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHardwarePipeline();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(biometricVerificationProvider.notifier);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _teardownCameraResources();
      final current = ref.read(biometricVerificationProvider);
      if (current.status == BiometricVerificationStatus.challenging ||
          current.status == BiometricVerificationStatus.aligning) {
        notifier.handleCameraInterruption(
          'Camera session interrupted while app moved to background. Tap Retry to resume safely.',
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      final current = ref.read(biometricVerificationProvider);
      if (!_isCameraInitialized &&
          !_isCapturingFinal &&
          current.permissionState != CameraPermissionState.unavailable &&
          (_isPermissionBlocked(current.permissionState) ||
              current.machinePhase == LivenessMachinePhase.interrupted)) {
        notifier.retry();
        _initializeHardwarePipeline();
      }
    }
  }

  Future<void> _initializeHardwarePipeline() async {
    if (!mounted) return;
    final notifier = ref.read(biometricVerificationProvider.notifier);

    if (kIsWeb) {
      await _initializeWebWebcamPipeline(notifier);
      return;
    }

    await notifier.initializePermissions();
    if (!mounted) return;

    final perm = ref.read(biometricVerificationProvider).permissionState;
    if (perm != CameraPermissionState.granted) return;

    // ML Kit & CameraX image streaming are supported on Android and iOS only.
    if (!(Platform.isAndroid || Platform.isIOS)) {
      if (mounted) {
        setState(() {
          _cameraErrorText =
              'Live front camera & ML Kit face detection require an iOS or Android device.';
        });
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        notifier.markCameraUnavailable('No front camera found on this device.');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      CameraController controller;
      try {
        controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
        );
        await controller.initialize();
      } on CameraException catch (_) {
        if (!Platform.isAndroid) rethrow;
        controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        await controller.initialize();
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _faceAnalyzer = MlKitFaceFrameAnalyzer();
      _cameraController = controller;

      setState(() {
        _isCameraInitialized = true;
        _cameraErrorText = null;
      });

      await controller.startImageStream(_processLiveCameraImage);
    } on CameraException catch (e) {
      notifier.markCameraUnavailable(
        'Camera initialization failed (${e.code}): ${e.description ?? 'Unknown error'}',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorText = 'Hardware camera unavailable: $e';
        });
      }
    }
  }

  Future<void> _initializeWebWebcamPipeline(
    BiometricVerificationNotifier notifier,
  ) async {
    final bridge = _webBridge;
    if (bridge == null || !bridge.isSupported) {
      notifier.setHardwareUnavailableState(
        'Browser MediaPipe Face Landmarker helper is unavailable in this environment.',
      );
      return;
    }

    setState(() {
      _isCameraInitialized = false;
      _isWebLoadingModel = false;
      _cameraErrorText = 'Requesting webcam access in Chrome...';
    });
    notifier.setCheckingPermissionState('Requesting webcam access in Chrome...');

    await bridge.start(
      onFrame: (analysis) {
        if (!mounted || _isCapturingFinal) return;
        final now = DateTime.now();
        if (now.difference(_lastAnalyzedAt).inMilliseconds < 90) return;
        _lastAnalyzedAt = now;
        ref
            .read(biometricVerificationProvider.notifier)
            .onFaceAnalysisFrame(analysis, timestamp: now);
      },
      onStatus: (status, message) {
        if (!mounted) return;
        switch (status) {
          case WebScannerStatus.requestingPermission:
            setState(() {
              _isWebLoadingModel = false;
              _cameraErrorText = message;
            });
            notifier.setCheckingPermissionState(message);
            break;
          case WebScannerStatus.loadingModel:
            setState(() {
              _isCameraInitialized = true;
              _isWebLoadingModel = true;
              _cameraErrorText = message;
            });
            notifier.setGrantedAligningState(statusMessage: message);
            break;
          case WebScannerStatus.ready:
            setState(() {
              _isCameraInitialized = true;
              _isWebLoadingModel = false;
              _cameraErrorText = null;
            });
            notifier.setGrantedAligningState();
            break;
          case WebScannerStatus.permissionDenied:
            setState(() {
              _isCameraInitialized = false;
              _isWebLoadingModel = false;
              _cameraErrorText = message;
            });
            notifier.setPermissionDenied(
              permanent: false,
              customMessage: message,
            );
            break;
          case WebScannerStatus.unavailable:
          case WebScannerStatus.modelError:
            setState(() {
              _isCameraInitialized = false;
              _isWebLoadingModel = false;
              _cameraErrorText = message;
            });
            notifier.setHardwareUnavailableState(message);
            break;
          case WebScannerStatus.interrupted:
            setState(() {
              _isCameraInitialized = false;
              _isWebLoadingModel = false;
              _cameraErrorText = message;
            });
            notifier.handleCameraInterruption(message);
            break;
        }
      },
    );
  }

  Future<void> _processLiveCameraImage(CameraImage image) async {
    if (_isAnalyzingFrame ||
        _isCapturingFinal ||
        !mounted ||
        _cameraController == null ||
        _faceAnalyzer == null) {
      return;
    }

    final now = DateTime.now();
    // Throttle inference to ~6-7 fps to maintain crisp UI responsiveness
    if (now.difference(_lastAnalyzedAt).inMilliseconds < 150) {
      return;
    }

    _isAnalyzingFrame = true;
    _lastAnalyzedAt = now;

    try {
      final result = await _faceAnalyzer!.analyzeCameraImage(
        image,
        _cameraController!.description,
        _cameraController!.value.deviceOrientation,
      );
      if (mounted) {
        ref
            .read(biometricVerificationProvider.notifier)
            .onFaceAnalysisFrame(result, timestamp: now);
      }
    } catch (_) {
      // Drop transient frame error safely without logging raw buffers
    } finally {
      _isAnalyzingFrame = false;
    }
  }

  Future<void> _captureAndSubmitInMemory() async {
    if (_isCapturingFinal) return;
    final notifier = ref.read(biometricVerificationProvider.notifier);
    final currentState = ref.read(biometricVerificationProvider);
    if (!currentState.isReadyToCapture) return;

    setState(() => _isCapturingFinal = true);

    Uint8List? inMemoryBytes;
    String? tempFilePath;

    try {
      if (kIsWeb) {
        inMemoryBytes = _webBridge?.captureSnapshotBytes();
      } else {
        final controller = _cameraController;
        if (controller != null && controller.value.isInitialized) {
          if (controller.value.isStreamingImages) {
            await controller.stopImageStream();
          }
          final xFile = await controller.takePicture();
          tempFilePath = xFile.path;
          inMemoryBytes = await xFile.readAsBytes();
        }
      }
      await notifier.submitBiometricVerification(
        inMemoryFrameBytes: inMemoryBytes,
      );
    } on CameraException catch (e) {
      notifier.handleCameraInterruption(
        'Capture interrupted (${e.code}). Please retry.',
      );
    } catch (e) {
      notifier.handleCameraInterruption(
        'Webcam capture failed: $e. Please retry.',
      );
    } finally {
      // Strictly purge any temporary camera artifact & clear local buffers
      await BiometricPrivacyGuard.deleteTempFileIfExists(tempFilePath);
      BiometricPrivacyGuard.bestEffortWipeBytes(inMemoryBytes);
      inMemoryBytes = null;
      await _teardownCameraResources();
      if (mounted) {
        setState(() => _isCapturingFinal = false);
      }
    }
  }

  Future<void> _teardownCameraResources() async {
    _isCameraInitialized = false;
    _isWebLoadingModel = false;

    final webBridge = _webBridge;
    if (webBridge != null) {
      try {
        await webBridge.stop();
      } catch (_) {}
    }

    final controller = _cameraController;
    _cameraController = null;

    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (_) {}
      try {
        await controller.dispose();
      } catch (_) {}
    }

    final analyzer = _faceAnalyzer;
    _faceAnalyzer = null;
    if (analyzer != null) {
      try {
        await analyzer.dispose();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    unawaited(_teardownCameraResources());
    _webBridge?.dispose();
    _webBridge = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biometricVerificationProvider);
    final notifier = ref.read(biometricVerificationProvider.notifier);

    ref.listen<BiometricVerificationState>(biometricVerificationProvider,
        (previous, next) async {
      final bool isTerminalNavigationState =
          next.status == BiometricVerificationStatus.verified ||
              (next.status == BiometricVerificationStatus.failed &&
                  !_isPermissionBlocked(next.permissionState) &&
                  next.result != null);
      if (isTerminalNavigationState) {
        if (next.status == BiometricVerificationStatus.verified &&
            !widget.isCompanionFlow) {
          ref.read(authProvider.notifier).setFaceVerified(
                next.result?.verificationId ?? 'DEMO-LIVENESS-PROOF',
              );
        } else if (next.status == BiometricVerificationStatus.failed &&
            !widget.isCompanionFlow) {
          ref.read(authProvider.notifier).setFaceVerificationStatus(
                next.result?.resultStatus ?? FaceVerificationStatus.failed,
                errorMessage: next.statusMessage,
              );
        }

        await _teardownCameraResources();
        if (!context.mounted) return;

        if (widget.isCompanionFlow) {
          if (next.status == BiometricVerificationStatus.verified) {
            Navigator.of(context).pop(next.result?.verificationId);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerificationResultScreen(
                  result: next.result,
                  isCompanionFlow: true,
                ),
              ),
            );
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VerificationResultScreen(result: next.result),
            ),
          );
        }
      }
    });

    final bool isCompliant =
        state.alignmentStatus == FaceAlignmentStatus.aligned;

    final screen = PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(_teardownCameraResources());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () async {
              await _teardownCameraResources();
              if (!context.mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => widget.isCompanionFlow
                        ? const CompanionKycScreen()
                        : const SecurityCheckIntroScreen(),
                  ),
                );
              }
            },
          ),
          title: const Text(
            'Identity Assurance & Shield',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                key: const ValueKey('skip_face_scan_qa_btn'),
                icon: const Icon(Icons.fast_forward_rounded,
                    color: Color(0xFFFFD600), size: 16),
                label: const Text(
                  'Skip (QA)',
                  style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                onPressed: _bypassForTesting,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'FACE CHECK · 2 OF 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            if (!widget.isCompanionFlow)
              TextButton(
                onPressed: () async {
                  await _teardownCameraResources();
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CompanionKycScreen()),
                  );
                },
                child: const Text(
                  'Companion KYC',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: _isPermissionBlocked(state.permissionState)
              ? _buildPermissionDeniedView(state, notifier)
              : Column(
                  children: [
                    // Step Progress Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.status ==
                                        BiometricVerificationStatus.challenging
                                    ? 'STEP 2: ACTIVE LIVENESS'
                                    : 'STEP 1: FACE ALIGNMENT',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                '${(state.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: state.progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Full-screen Camera Viewport with Oval Alignment Guide
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isCompliant
                                    ? AppColors.success
                                    : (state.alignmentStatus ==
                                            FaceAlignmentStatus.poorLighting
                                        ? AppColors.warning
                                        : AppColors.accent),
                                width: 2.2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (kIsWeb && _webBridge != null)
                                    IgnorePointer(
                                      child: _webBridge!.buildPreviewWidget(),
                                    )
                                  else if (_isCameraInitialized &&
                                      _cameraController != null)
                                    FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _cameraController!
                                                .value.previewSize?.height ??
                                            1,
                                        height: _cameraController!
                                                .value.previewSize?.width ??
                                            1,
                                        child:
                                            CameraPreview(_cameraController!),
                                      ),
                                    )
                                  else
                                    _buildCameraFallbackNotice(),

                                  if (kIsWeb &&
                                      (!_isCameraInitialized || _isWebLoadingModel))
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      padding: const EdgeInsets.all(24),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.accent,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              _cameraErrorText ??
                                                  'Starting Chrome webcam & MediaPipe Face Landmarker...',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Laser Scanning Bar
                                  AnimatedBuilder(
                                    animation: _scanController,
                                    builder: (context, child) {
                                      return Align(
                                        alignment: Alignment(
                                          0,
                                          (_scanController.value * 2) - 1,
                                        ),
                                        child: Container(
                                          height: 2.5,
                                          decoration: BoxDecoration(
                                            color: isCompliant
                                                ? AppColors.success
                                                : AppColors.accent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isCompliant
                                                        ? AppColors.success
                                                        : AppColors.accent)
                                                    .withValues(alpha: 0.7),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Oval Face Alignment Guide
                                  CustomPaint(
                                    painter: _FaceOvalPainter(
                                      borderColor: isCompliant
                                          ? AppColors.success
                                          : (state.alignmentStatus ==
                                                  FaceAlignmentStatus
                                                      .poorLighting
                                              ? AppColors.warning
                                              : AppColors.secondary),
                                    ),
                                  ),

                                  // Detected ML Kit / MediaPipe Landmark Points (scaled cleanly to live viewport)
                                  if (state.landmarkPoints.isNotEmpty)
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isFront = kIsWeb ||
                                            (_cameraController?.description
                                                        .lensDirection ??
                                                    CameraLensDirection.front) ==
                                                CameraLensDirection.front;
                                        return Stack(
                                          children: state.landmarkPoints.map((point) {
                                            final mappedX = isFront
                                                ? (1.0 - point.x)
                                                : point.x;
                                            return Positioned(
                                              left: (constraints.maxWidth *
                                                          mappedX -
                                                      3.5)
                                                  .clamp(0.0,
                                                      constraints.maxWidth - 7),
                                              top: (constraints.maxHeight *
                                                          point.y -
                                                      3.5)
                                                  .clamp(0.0,
                                                      constraints.maxHeight - 7),
                                              child: Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: state
                                                          .areAllChallengesCompleted
                                                      ? AppColors.success
                                                      : AppColors.accentTeal,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),

                                  if (state.status ==
                                          BiometricVerificationStatus
                                              .processing ||
                                      _isCapturingFinal)
                                    Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.accent,
                                              ),
                                            ),
                                            SizedBox(height: 14),
                                            Text(
                                              'Processing in volatile RAM...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Figma ● LIVE badge
                          Positioned(
                            top: 18,
                            left: 32,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF3B30),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Environmental Quality Pills
                          Positioned(
                            top: 20,
                            left: 12,
                            right: 12,
                            child: Center(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildStatusBadge(
                                    label: 'Lighting',
                                    isOk: state.isLightingGood,
                                  ),
                                  _buildStatusBadge(
                                    label: state.isFaceTooFar
                                        ? 'Too Far'
                                        : (state.isFaceTooClose
                                            ? 'Too Close'
                                            : 'Distance'),
                                    isOk: state.isDistanceGood,
                                  ),
                                  _buildStatusBadge(
                                    label: 'Centered',
                                    isOk: state.isCentered,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Real-Time Guidance & Single Challenge Card
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (state.areAllChallengesCompleted
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  state.areAllChallengesCompleted
                                      ? Icons.check_circle_rounded
                                      : (state.status ==
                                              BiometricVerificationStatus
                                                  .challenging
                                          ? Icons.visibility_rounded
                                          : Icons.face_rounded),
                                  color: state.areAllChallengesCompleted
                                      ? AppColors.success
                                      : AppColors.accent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.status ==
                                                    BiometricVerificationStatus
                                                        .challenging
                                                ? (state.areAllChallengesCompleted
                                                    ? 'CHALLENGES COMPLETE'
                                                    : 'CHALLENGE ${state.currentChallengeIndex + 1} OF ${state.challenges.length}')
                                                : 'GUIDED ALIGNMENT',
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        if (kIsWeb)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent
                                                  .withValues(alpha: 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.accent
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: const Text(
                                              'DEMO MODE',
                                              style: TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.7,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      state.statusMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (state.status ==
                                  BiometricVerificationStatus.challenging &&
                              !state.areAllChallengesCompleted) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: state.currentChallengeProgress,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined,
                                  color: Colors.white54, size: 14),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  kIsWeb
                                      ? 'DEMO MODE (MediaPipe 2D webcam landmarks): frames stay in volatile memory — not 3D depth or identity matching.'
                                      : 'Strict privacy: frames processed in memory only — never saved to gallery or device storage.',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Controls strictly gated by alignment & challenge state
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () {
                                notifier.retry();
                                _initializeHardwarePipeline();
                              },
                              child: const Text('Retry'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: state.status ==
                                        BiometricVerificationStatus.challenging
                                ? PrimaryButton(
                                    label: 'Capture & Verify',
                                    icon: Icons.camera_alt_rounded,
                                    backgroundColor: state.isReadyToCapture
                                        ? AppColors.accent
                                        : AppColors.surfaceMutedDark,
                                    textColor: state.isReadyToCapture
                                        ? AppColors.encreDeep
                                        : Colors.white54,
                                    isLoading: _isCapturingFinal,
                                    onPressed: state.isReadyToCapture
                                        ? _captureAndSubmitInMemory
                                        : null,
                                  )
                                : PrimaryButton(
                                    label: 'Start Liveness Check',
                                    icon: Icons.play_arrow_rounded,
                                    backgroundColor: state.canStartChallenges
                                        ? AppColors.accent
                                        : AppColors.surfaceMutedDark,
                                    textColor: state.canStartChallenges
                                        ? AppColors.encreDeep
                                        : Colors.white54,
                                    onPressed: state.canStartChallenges
                                        ? () =>
                                            notifier.startLivenessVerification()
                                        : null,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // QA Testing Skip Button
                    Center(
                      child: TextButton.icon(
                        key: const ValueKey('skip_face_scan_bottom_btn'),
                        icon: const Icon(Icons.fast_forward_rounded,
                            color: Color(0xFFFFD600), size: 16),
                        label: const Text(
                          'Skip Face Scan (For Testing)',
                          style: TextStyle(
                            color: Color(0xFFFFD600),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: _bypassForTesting,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
        ),
      ),
    );

    if (widget.isCompanionFlow) {
      return screen;
    }
    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.faceScan,
      child: screen,
    );
  }

  Future<void> _bypassForTesting() async {
    await _teardownCameraResources();
    ref.read(authProvider.notifier).setFaceVerified('VERIF-B3D-QA-SKIP');
    if (!mounted) return;
    if (widget.isCompanionFlow) {
      Navigator.of(context).pop('VERIF-B3D-QA-SKIP');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const GovernmentIdVerificationScreen(),
        ),
      );
    }
  }

  bool _isPermissionBlocked(CameraPermissionState permission) {
    return permission == CameraPermissionState.denied ||
        permission == CameraPermissionState.permanentlyDenied ||
        permission == CameraPermissionState.restricted ||
        permission == CameraPermissionState.unavailable;
  }

  Widget _buildCameraFallbackNotice() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          Text(
            _cameraErrorText ?? 'Initializing front camera stream...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (_cameraErrorText != null && Navigator.canPop(context)) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
              ),
              onPressed: () async {
                await _teardownCameraResources();
                if (mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Security Check',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required bool isOk,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOk
            ? AppColors.success.withValues(alpha: 0.90)
            : AppColors.error.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(
    BiometricVerificationState currentState,
    BiometricVerificationNotifier notifier,
  ) {
    final permissionState = currentState.permissionState;
    final bool permanent =
        permissionState == CameraPermissionState.permanentlyDenied ||
            permissionState == CameraPermissionState.restricted;
    final bool unavailable = permissionState == CameraPermissionState.unavailable;

    final String detailText = currentState.statusMessage.isNotEmpty
        ? currentState.statusMessage
        : (unavailable
            ? 'Camera hardware is unavailable in this session. Connect or free up a webcam and retry.'
            : 'To run on-device liveness checks without storing photos, Date² requires front camera permission.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              unavailable
                  ? 'Camera Hardware Unavailable'
                  : 'Camera Access Required',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detailText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (!unavailable) ...[
              PrimaryButton(
                label: permanent
                    ? 'Open App Settings'
                    : (kIsWeb ? 'Retry Webcam Permission' : 'Grant Camera Permission'),
                backgroundColor: AppColors.accent,
                textColor: AppColors.encreDeep,
                onPressed: () {
                  if (permanent && !kIsWeb) {
                    notifier.openSettings();
                  } else {
                    notifier.retry();
                    _initializeHardwarePipeline();
                  }
                },
              ),
              if (permanent) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _initializeHardwarePipeline,
                    child: const Text('I Enabled Access — Retry'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ] else ...[
              PrimaryButton(
                label: 'Retry Camera',
                icon: Icons.refresh_rounded,
                backgroundColor: AppColors.accent,
                textColor: AppColors.encreDeep,
                onPressed: () {
                  notifier.retry();
                  _initializeHardwarePipeline();
                },
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await _teardownCameraResources();
                  if (!mounted) return;
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => widget.isCompanionFlow
                            ? const CompanionKycScreen()
                            : const SecurityCheckIntroScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Back to Security Check'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.fast_forward_rounded,
                  color: Color(0xFFFFD600), size: 16),
              label: const Text(
                'Skip Face Scan (For Testing)',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: _bypassForTesting,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceOvalPainter extends CustomPainter {
  final Color borderColor;
  _FaceOvalPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.68,
      height: size.height * 0.72,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceOvalPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
