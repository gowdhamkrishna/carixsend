import 'package:flutter_test/flutter_test.dart';
import 'package:carixsend_flutter/app/services/device_discovery_service.dart';

void main() {
  test('DiscoveredDevice equality and address formatting', () {
    final dev1 = DiscoveredDevice(
      ip: '192.168.1.10',
      port: 23984,
      name: 'Host 1',
      lastSeen: DateTime.now(),
    );

    final dev2 = DiscoveredDevice(
      ip: '192.168.1.10',
      port: 23984,
      name: 'Host 1 Alt',
      lastSeen: DateTime.now(),
    );

    expect(dev1.address, equals('192.168.1.10:23984'));
    expect(dev1.displayName, equals('Host 1'));
    expect(dev1, equals(dev2));
  });

  test('DeviceDiscoveryService start and stop lifecycle', () async {
    final service = DeviceDiscoveryService();
    expect(service.isScanning, isFalse);

    await service.startDiscovery(targetPort: 9999);
    expect(service.isScanning, isTrue);

    service.stopDiscovery();
    expect(service.isScanning, isFalse);

    service.dispose();
  });
}
