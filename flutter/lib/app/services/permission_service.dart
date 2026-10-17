import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request file and storage permissions required for sending and receiving files on Android.
  static Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true; // Desktop / non-Android platforms handle permissions natively
    }

    try {
      // 1. Check legacy storage permission (Android 12 and below)
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // 2. On Android 13+ (API 33+), request media permissions
      await Permission.photos.request();
      await Permission.videos.request();
      await Permission.audio.request();

      // Media permissions alone do NOT grant raw filesystem write access on Android 11+.
      // We must check manageExternalStorage for the Rust core to use File::create.

      // 3. For TV & file manager access on Android 11+ (API 30+), check manage external storage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return true;
      }

      return false;
    } catch (_) {
      // Graceful fallback if permission handling is mocked or unavailable
      return true;
    }
  }

  /// Check current permission status without prompting
  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    final manage = await Permission.manageExternalStorage.status;
    if (manage.isGranted) return true;

    final photos = await Permission.photos.status;
    if (photos.isGranted) return true;

    return false;
  }
}
