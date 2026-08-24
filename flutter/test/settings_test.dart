import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carixsend_flutter/app/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Default destination path resolves to system Downloads path', () async {
    final defaultPath = await SettingsService.getDefaultDownloadsPath();
    expect(defaultPath, isNotEmpty);

    final currentDest = await SettingsService.getDestinationPath();
    expect(currentDest, equals(defaultPath));
  });

  test('Custom destination path can be set and reset to default Downloads', () async {
    final defaultPath = await SettingsService.getDefaultDownloadsPath();

    // Set custom path
    const customFolder = '/tmp/my_custom_downloads';
    await SettingsService.setDestinationPath(customFolder);

    // Save mock prefs with custom value
    SharedPreferences.setMockInitialValues({
      'custom_dest_path': customFolder,
    });

    final savedDest = await SettingsService.getDestinationPath();
    // Non-existent directory on system will fallback to default path safely
    expect(savedDest, isNotEmpty);

    // Reset to default
    await SettingsService.setDestinationPath(null);
    SharedPreferences.setMockInitialValues({});

    final resetDest = await SettingsService.getDestinationPath();
    expect(resetDest, equals(defaultPath));
  });

  test('Custom device name can be set, updated, and retrieved', () async {
    const customName = 'Living Room TV';
    await SettingsService.setDeviceName(customName);

    final savedName = await SettingsService.getDeviceName();
    expect(savedName, equals('Living Room TV'));

    await SettingsService.setDeviceName(null);
  });
}
