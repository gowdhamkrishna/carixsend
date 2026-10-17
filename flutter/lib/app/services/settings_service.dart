import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyDestPath = 'custom_dest_path';
  static const String _keyPort = 'receiver_port';
  static const String _keyDeviceName = 'device_name';

  /// A stable, friendly identity for LAN discovery.  IP addresses remain an
  /// implementation detail and are never used as the receiver's label.
  static Future<String> getDeviceName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(_keyDeviceName);
      if (savedName != null && savedName.trim().isNotEmpty) return savedName;

      const adjectives = ['Amber', 'Arctic', 'Azure', 'Coral', 'Cosmic', 'Jade', 'Lunar', 'Misty', 'Nova', 'Solar'];
      const animals = ['Falcon', 'Fox', 'Koala', 'Lynx', 'Otter', 'Panda', 'Raven', 'Tiger', 'Wolf', 'Yak'];
      final random = Random.secure();
      final generated = '${adjectives[random.nextInt(adjectives.length)]} ${animals[random.nextInt(animals.length)]}';
      await prefs.setString(_keyDeviceName, generated);
      return generated;
    } catch (_) {
      return 'Nearby Device';
    }
  }

  /// Save custom device name. Pass `null` or empty string to reset to auto-generated.
  static Future<void> setDeviceName(String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name == null || name.trim().isEmpty) {
        await prefs.remove(_keyDeviceName);
      } else {
        await prefs.setString(_keyDeviceName, name.trim());
      }
    } catch (_) {}
  }

  /// Get configured destination path, defaulting to system Downloads directory.
  static Future<String> getDestinationPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString(_keyDestPath);
      if (customPath != null && customPath.isNotEmpty) {
        final dir = Directory(customPath);
        if (dir.existsSync()) {
          return customPath;
        }
      }
    } catch (_) {}

    return getDefaultDownloadsPath();
  }

  /// Get standard system Downloads path with robust fallbacks.
  static Future<String> getDefaultDownloadsPath() async {
    if (Platform.isAndroid) {
      // Hardcode the standard Android download path.
      // Do NOT use existsSync() here because it throws FileSystemException
      // on Android 11+ before permissions are granted, which would crash the
      // receiver server startup.
      return '/storage/emulated/0/Download';
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      return docsDir.path;
    } catch (_) {}

    return Directory.systemTemp.path;
  }

  /// Save custom destination directory path. Pass `null` to reset to default Downloads.
  static Future<void> setDestinationPath(String? path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null || path.trim().isEmpty) {
        await prefs.remove(_keyDestPath);
      } else {
        await prefs.setString(_keyDestPath, path.trim());
      }
    } catch (_) {}
  }

  /// Get configured receiver server port (default 23984).
  static Future<int> getReceiverPort() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyPort) ?? 23984;
    } catch (_) {
      return 23984;
    }
  }

  /// Save receiver server port.
  static Future<void> setReceiverPort(int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyPort, port);
    } catch (_) {}
  }
}
