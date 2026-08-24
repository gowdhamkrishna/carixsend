import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveredDevice {
  final String ip;
  final int port;
  final String name;
  final DateTime lastSeen;

  const DiscoveredDevice({
    required this.ip,
    required this.port,
    required this.name,
    required this.lastSeen,
  });

  String get address => '$ip:$port';

  String get displayName {
    if (name.isNotEmpty && name != ip && name != address && !name.startsWith('LAN Device') && !name.startsWith('Nearby Device')) {
      return name;
    }
    return 'Receiver ($ip)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          port == other.port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;
}

class DeviceDiscoveryService {
  static const _discoveryPort = 9001;
  static RawDatagramSocket? _advertisingSocket;
  static String? _advertisedName;
  static int? _advertisedTransferPort;
  final _deviceController = StreamController<List<DiscoveredDevice>>.broadcast();
  final Map<String, DiscoveredDevice> _discoveredMap = {};
  final Set<String> _ownIps = {};
  RawDatagramSocket? _socket;
  Timer? _scanTimer;
  bool _isScanning = false;

  Stream<List<DiscoveredDevice>> get devicesStream => _deviceController.stream;
  List<DiscoveredDevice> get currentDevices => _discoveredMap.values.toList();
  bool get isScanning => _isScanning;

  /// Listens for discovery broadcasts and replies directly to the sender.
  static Future<void> startAdvertising({required String name, required int port}) async {
    _advertisedName = name;
    _advertisedTransferPort = port;
    if (_advertisingSocket != null) return;
    try {
      RawDatagramSocket? socket;
      try {
        socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          _discoveryPort,
          reuseAddress: true,
          reusePort: false,
        );
      } catch (_) {
        socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          _discoveryPort,
          reuseAddress: true,
        );
      }
      socket.broadcastEnabled = true;
      socket.listen((event) {
        if (event != RawSocketEvent.read) return;
        final datagram = socket?.receive();
        if (datagram == null) return;
        final message = utf8.decode(datagram.data, allowMalformed: true).trim();
        if (!message.startsWith('CARIXSEND_DISCOVER:')) return;
        final advertisedName = _advertisedName;
        final advertisedPort = _advertisedTransferPort;
        if (advertisedName == null || advertisedPort == null) return;
        final response = utf8.encode('CARIXSEND_ANNOUNCE:$advertisedPort:$advertisedName');
        socket?.send(response, datagram.address, datagram.port);
      });
      _advertisingSocket = socket;
    } catch (_) {
      // Discovery can still use the TCP fallback on restrictive networks.
    }
  }

  Future<void> startDiscovery({int targetPort = 23984, bool includeSelf = false}) async {
    if (_isScanning) return;
    _isScanning = true;
    _discoveredMap.clear();

    await _updateOwnIps();

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket?.broadcastEnabled = true;

      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket?.receive();
          if (datagram != null) {
            _handleDatagram(datagram, includeSelf: includeSelf);
          }
        }
      });

      _sendBroadcastPing(targetPort);
      _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _sendBroadcastPing(targetPort);
      });
      // Probe subnet after allowing normal broadcast response a chance to arrive
      Timer(const Duration(seconds: 1), () {
        if (_isScanning) {
          _probeLocalSubnet(targetPort, includeSelf: includeSelf);
        }
      });
    } catch (_) {
      // Fall back to direct subnet probing if UDP bind is restricted
      _probeLocalSubnet(targetPort, includeSelf: includeSelf);
    }
  }

  Future<void> _updateOwnIps() async {
    _ownIps.clear();
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: true,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          _ownIps.add(addr.address);
        }
      }
    } catch (_) {}
  }

  void _sendBroadcastPing(int targetPort) {
    try {
      final senderName = _advertisedName ?? '';
      final msg = utf8.encode('CARIXSEND_DISCOVER:$targetPort:$senderName');
      _socket?.send(msg, InternetAddress('255.255.255.255'), _discoveryPort);
    } catch (_) {}
  }

  Future<void> _probeLocalSubnet(int targetPort, {bool includeSelf = false}) async {
    // Always check Android emulator host loopback alias (10.0.2.2) when applicable
    _checkEndpoint('10.0.2.2', targetPort, includeSelf: includeSelf);

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: true,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final ipStr = addr.address;
          if (ipStr == '127.0.0.1' || ipStr == '10.0.2.2') {
            continue;
          }

          final parts = ipStr.split('.');
          if (parts.length == 4) {
            final subnetPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
            for (var i = 1; i <= 254; i++) {
              final targetIp = '$subnetPrefix.$i';
              _checkEndpoint(targetIp, targetPort, includeSelf: includeSelf);
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _checkEndpoint(String ip, int port, {bool includeSelf = false}) async {
    // Filter out own device IP unless includeSelf is true
    if (!includeSelf && _ownIps.contains(ip)) {
      return;
    }

    // Try direct UDP discovery ping to the specific IP's discovery port first
    try {
      final pingMsg = utf8.encode('CARIXSEND_DISCOVER:$port:${_advertisedName ?? ''}');
      _socket?.send(pingMsg, InternetAddress(ip), _discoveryPort);
    } catch (_) {}

    // Also check TCP endpoint for network fallbacks
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 400),
      );
      socket.destroy();

      // If device already registered via UDP announcement, preserve its real name
      final existingKey = '$ip:$port';
      final existingDevice = _discoveredMap[existingKey];

      String resolvedName = existingDevice?.name ?? 'Receiver ($ip)';
      if (existingDevice == null || existingDevice.name.isEmpty || existingDevice.name == 'Receiver ($ip)') {
        try {
          final hostEntry = await InternetAddress(ip).reverse().timeout(const Duration(milliseconds: 300));
          if (hostEntry.host.isNotEmpty && hostEntry.host != ip) {
            resolvedName = _cleanHostName(hostEntry.host);
          }
        } catch (_) {}
      }

      final device = DiscoveredDevice(
        ip: ip,
        port: port,
        name: resolvedName,
        lastSeen: DateTime.now(),
      );

      _discoveredMap[device.address] = device;
      _deviceController.add(_discoveredMap.values.toList());
    } catch (_) {
      // Connection refused or timed out — device not running CarixSend receiver on this port
    }
  }

  String _cleanHostName(String host) {
    var name = host;
    if (name.endsWith('.local')) {
      name = name.substring(0, name.length - 6);
    } else if (name.endsWith('.lan')) {
      name = name.substring(0, name.length - 4);
    } else if (name.endsWith('.home')) {
      name = name.substring(0, name.length - 5);
    }
    return name.isNotEmpty ? name : host;
  }

  void _handleDatagram(Datagram datagram, {bool includeSelf = false}) {
    final senderIp = datagram.address.address;
    if (!includeSelf && _ownIps.contains(senderIp)) {
      return; // Ignore own UDP announcements
    }

    try {
      final text = utf8.decode(datagram.data).trim();
      if (text.startsWith('CARIXSEND_ANNOUNCE:')) {
        final parts = text.split(':');
        if (parts.length >= 3) {
          final port = int.tryParse(parts[1]) ?? 23984;
          final name = parts.sublist(2).join(':').trim();
          final device = DiscoveredDevice(
            ip: senderIp,
            port: port,
            name: name.isEmpty ? 'Receiver ($senderIp)' : name,
            lastSeen: DateTime.now(),
          );
          _discoveredMap[device.address] = device;
          _deviceController.add(_discoveredMap.values.toList());
        }
      }
    } catch (_) {}
  }

  void stopDiscovery() {
    _isScanning = false;
    _scanTimer?.cancel();
    _scanTimer = null;
    _socket?.close();
    _socket = null;
  }

  void dispose() {
    stopDiscovery();
    _deviceController.close();
  }
}
