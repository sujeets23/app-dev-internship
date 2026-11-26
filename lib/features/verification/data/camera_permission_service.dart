import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/models/biometric_verification_model.dart';

/// Abstraction for camera permission checks and OS settings navigation.
abstract class ICameraPermissionService {
  Future<CameraPermissionState> checkStatus();
  Future<CameraPermissionState> requestPermission();
  Future<bool> openSettings();
}

/// Device OS implementation backed by `permission_handler`.
class DeviceCameraPermissionService implements ICameraPermissionService {
  const DeviceCameraPermissionService();

  @override
  Future<CameraPermissionState> checkStatus() async {
    if (kIsWeb) {
      // Browser prompts camera permission when stream initializes.
      return CameraPermissionState.granted;
    }
    try {
      final status = await Permission.camera.status;
      return _mapStatus(status);
    } on MissingPluginException {
      return CameraPermissionState.unavailable;
    } on UnimplementedError {
      return CameraPermissionState.unavailable;
    } catch (_) {
      return CameraPermissionState.denied;
    }
  }

  @override
  Future<CameraPermissionState> requestPermission() async {
    if (kIsWeb) {
      return CameraPermissionState.granted;
    }
    try {
      final status = await Permission.camera.request();
      return _mapStatus(status);
    } on MissingPluginException {
      return CameraPermissionState.unavailable;
    } on UnimplementedError {
      return CameraPermissionState.unavailable;
    } catch (_) {
      return CameraPermissionState.denied;
    }
  }

  @override
  Future<bool> openSettings() async {
    if (kIsWeb) return false;
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  CameraPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) {
      return CameraPermissionState.restricted;
    }
    return CameraPermissionState.denied;
  }
}
