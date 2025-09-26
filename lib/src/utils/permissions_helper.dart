import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionsHelper {
  static Future<bool> requestCameraAndMicrophonePermissions() async {
    try {
      // Request both camera and microphone permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      bool cameraGranted =
          PermissionStatusExtension(statuses[Permission.camera])?.isGranted ??
              false;
      bool microphoneGranted =
          PermissionStatusExtension(statuses[Permission.microphone])
                  ?.isGranted ??
              false;

      return cameraGranted && microphoneGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> checkCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;

      return PermissionStatusExtension(cameraStatus).isGranted &&
          PermissionStatusExtension(microphoneStatus).isGranted;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  static Future<bool> requestCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      return PermissionStatusExtension(status).isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> requestMicrophonePermission() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      return PermissionStatusExtension(status).isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    try {
      PermissionStatus status = await Permission.storage.request();
      return PermissionStatusExtension(status).isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<void> showPermissionDialog({
    required String title,
    required String message,
    required VoidCallback onGranted,
    VoidCallback? onDenied,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onDenied?.call();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onGranted();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showSettingsDialog({
    required String title,
    required String message,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  static Future<bool> handleCameraAndMicrophonePermissions() async {
    // First check if permissions are already granted
    bool hasPermissions = await checkCameraAndMicrophonePermissions();
    if (hasPermissions) return true;

    // Check individual permission statuses
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus microphoneStatus = await Permission.microphone.status;

    // If permissions are permanently denied, show settings dialog
    if (PermissionStatusExtension(cameraStatus).isPermanentlyDenied ||
        PermissionStatusExtension(microphoneStatus).isPermanentlyDenied) {
      await showSettingsDialog(
        title: 'Permissions Required',
        message:
            'Camera and microphone permissions are required to join video calls. Please enable them in app settings.',
      );
      return false;
    }

    // If permissions are denied but not permanently, request them
    if (PermissionStatusExtension(cameraStatus).isDenied ||
        PermissionStatusExtension(microphoneStatus).isDenied) {
      bool granted = await requestCameraAndMicrophonePermissions();
      if (!granted) {
        await showPermissionDialog(
          title: 'Permissions Required',
          message:
              'Camera and microphone permissions are required to join video calls.',
          onGranted: () async {
            await requestCameraAndMicrophonePermissions();
          },
        );
      }
      return granted;
    }

    return false;
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isRestricted => this == PermissionStatus.restricted;
  bool get isLimited => this == PermissionStatus.limited;
}
