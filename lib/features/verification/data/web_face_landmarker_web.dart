import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import '../domain/models/biometric_verification_model.dart';
import 'web_face_landmarker_bridge.dart';

@JS('Date2WebFaceScanner')
external _JsDate2WebFaceScanner? get _jsScanner;

extension type _JsDate2WebFaceScanner(JSObject _) implements JSObject {
  external JSObject createViewElement(String containerId);
  external JSPromise<JSAny?> start(
    String containerId,
    JSFunction onFrameJson,
    JSFunction onStatus,
  );
  external JSUint8Array? captureSnapshotBytes();
  external JSPromise<JSAny?> stop();
  external void disposeContainer(String containerId);
}

class _BrowserWebFaceScannerBridge implements IWebFaceScannerBridge {
  static int _instanceCounter = 0;

  late final String _viewType;
  late final String _containerId;
  bool _viewRegistered = false;
  bool _disposed = false;

  _BrowserWebFaceScannerBridge() {
    _instanceCounter++;
    _viewType = 'date2-web-face-scanner-$_instanceCounter';
    _containerId = 'date2-web-face-container-$_instanceCounter';
  }

  @override
  bool get isSupported => _jsScanner != null;

  void _ensureViewRegistered() {
    if (_viewRegistered) return;
    _viewRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final scanner = _jsScanner;
      if (scanner == null) {
        throw StateError('Date2WebFaceScanner JS helper is not loaded.');
      }
      return scanner.createViewElement(_containerId);
    });
  }

  @override
  Widget buildPreviewWidget() {
    _ensureViewRegistered();
    return HtmlElementView(viewType: _viewType);
  }

  @override
  Future<void> start({
    required WebFaceFrameCallback onFrame,
    required WebFaceStatusCallback onStatus,
  }) async {
    _ensureViewRegistered();
    final scanner = _jsScanner;
    if (scanner == null) {
      onStatus(
        WebScannerStatus.unavailable,
        'Web Face Landmarker helper failed to load in browser.',
      );
      return;
    }

    final frameFn = ((JSString rawJson) {
      if (_disposed) return;
      try {
        final map = jsonDecode(rawJson.toDart) as Map<String, dynamic>;
        final rawLandmarks = map['landmarks'] as List<dynamic>? ?? const [];
        final landmarks = <FaceLandmarkPoint>[
          for (final item in rawLandmarks)
            if (item is Map<String, dynamic>)
              FaceLandmarkPoint(
                (item['x'] as num?)?.toDouble() ?? 0.0,
                (item['y'] as num?)?.toDouble() ?? 0.0,
                item['label'] as String? ?? '',
              ),
        ];

        final result = mapWebLandmarkerMetricsToAnalysis(
          hasFace: map['hasFace'] as bool? ?? false,
          faceCount: (map['faceCount'] as num?)?.toInt() ?? 0,
          meanLuma: (map['meanLuma'] as num?)?.toDouble() ?? 0.0,
          widthRatio: (map['widthRatio'] as num?)?.toDouble() ?? 0.0,
          centerX: (map['centerX'] as num?)?.toDouble() ?? 0.5,
          centerY: (map['centerY'] as num?)?.toDouble() ?? 0.5,
          headYawDeg: (map['headYawDeg'] as num?)?.toDouble() ?? 0.0,
          leftEyeOpen: (map['leftEyeOpen'] as num?)?.toDouble() ?? 1.0,
          rightEyeOpen: (map['rightEyeOpen'] as num?)?.toDouble() ?? 1.0,
          landmarks: landmarks,
        );
        onFrame(result);
      } catch (_) {
        // Skip malformed telemetry frames cleanly
      }
    }).toJS;

    final statusFn = ((JSString code, JSString message) {
      if (_disposed) return;
      final parsedStatus = switch (code.toDart) {
        'requesting_permission' => WebScannerStatus.requestingPermission,
        'loading_model' => WebScannerStatus.loadingModel,
        'ready' => WebScannerStatus.ready,
        'permission_denied' => WebScannerStatus.permissionDenied,
        'interrupted' => WebScannerStatus.interrupted,
        'model_error' => WebScannerStatus.modelError,
        _ => WebScannerStatus.unavailable,
      };
      onStatus(parsedStatus, message.toDart);
    }).toJS;

    await scanner.start(_containerId, frameFn, statusFn).toDart;
  }

  @override
  Uint8List? captureSnapshotBytes() {
    final scanner = _jsScanner;
    if (scanner == null) return null;
    return scanner.captureSnapshotBytes()?.toDart;
  }

  @override
  Future<void> stop() async {
    final scanner = _jsScanner;
    if (scanner == null) return;
    await scanner.stop().toDart;
  }

  @override
  void dispose() {
    _disposed = true;
    final scanner = _jsScanner;
    if (scanner != null) {
      scanner.disposeContainer(_containerId);
    }
  }
}

IWebFaceScannerBridge createPlatformWebFaceScannerBridge() =>
    _BrowserWebFaceScannerBridge();
