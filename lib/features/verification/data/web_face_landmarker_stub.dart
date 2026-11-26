import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'web_face_landmarker_bridge.dart';

class _StubWebFaceScannerBridge implements IWebFaceScannerBridge {
  @override
  bool get isSupported => false;

  @override
  Widget buildPreviewWidget() => const SizedBox.shrink();

  @override
  Future<void> start({
    required WebFaceFrameCallback onFrame,
    required WebFaceStatusCallback onStatus,
  }) async {
    onStatus(
      WebScannerStatus.unavailable,
      'Web MediaPipe scanner is only active in web builds.',
    );
  }

  @override
  Uint8List? captureSnapshotBytes() => null;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

IWebFaceScannerBridge createPlatformWebFaceScannerBridge() =>
    _StubWebFaceScannerBridge();
