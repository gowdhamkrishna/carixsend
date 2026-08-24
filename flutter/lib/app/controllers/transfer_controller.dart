import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../src/rust/frb_api.dart';
import '../models/transfer_model.dart';
import '../services/settings_service.dart';
import '../services/device_discovery_service.dart';
import '../services/transfer_repository.dart';

class TransferController extends ChangeNotifier {
  final TransferRepository _repository;
  final Map<int, TransferModel> _transfers = {};
  final Map<int, StreamSubscription<FrbTransferEvent>> _subscriptions = {};
  bool _isServerRunning = false;
  String? _serverBoundAddr;
  String? _configuredDestDir;
  String _deviceName = 'Nearby Device';
  Timer? _incomingPoller;

  TransferController(this._repository) {
    _loadSettings();
  }

  bool get isServerRunning => _isServerRunning;
  String? get serverBoundAddr => _serverBoundAddr;
  String? get configuredDestDir => _configuredDestDir;
  String get deviceName => _deviceName;

  Future<void> _loadSettings() async {
    _configuredDestDir = await SettingsService.getDestinationPath();
    _deviceName = await SettingsService.getDeviceName();
    notifyListeners();
  }

  Future<String> getEffectiveDestinationDir() async {
    return _configuredDestDir ?? await SettingsService.getDestinationPath();
  }

  Future<void> setDestinationDir(String? newPath) async {
    await SettingsService.setDestinationPath(newPath);
    _configuredDestDir = await SettingsService.getDestinationPath();
    notifyListeners();
  }

  Future<void> setDeviceName(String? newName) async {
    await SettingsService.setDeviceName(newName);
    _deviceName = await SettingsService.getDeviceName();
    if (_isServerRunning && _serverBoundAddr != null) {
      final port = int.tryParse(_serverBoundAddr!.split(':').last) ?? 23984;
      await DeviceDiscoveryService.startAdvertising(
        name: _deviceName,
        port: port,
      );
    }
    notifyListeners();
  }

  Future<void> startReceiverServer({String? bindAddr, String? destDir}) async {
    if (_isServerRunning) return;
    try {
      final port = await SettingsService.getReceiverPort();
      final effectiveBindAddr = bindAddr ?? '0.0.0.0:$port';
      final effectiveDestDir = destDir ?? await getEffectiveDestinationDir();
      _serverBoundAddr = await _repository.startServer(
        bindAddr: effectiveBindAddr,
        destDir: effectiveDestDir,
      );
      _isServerRunning = true;
      final advertisedPort = int.tryParse(_serverBoundAddr!.split(':').last) ?? port;
      _deviceName = await SettingsService.getDeviceName();
      await DeviceDiscoveryService.startAdvertising(
        name: _deviceName,
        port: advertisedPort,
      );
      _incomingPoller ??= Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => refreshIncomingTransfers(),
      );
      await refreshIncomingTransfers();
      notifyListeners();
    } catch (e) {
      _isServerRunning = false;
      rethrow;
    }
  }

  Map<int, TransferModel> get transfers => Map.unmodifiable(_transfers);

  List<TransferModel> get transferList => _transfers.values.toList();

  Future<int> startTransfer({
    required String serverAddr,
    required List<FrbFileSpec> files,
    required String srcDir,
    String? destDir,
    FrbTransferOptions? options,
  }) async {
    final effectiveDestDir = destDir ?? await getEffectiveDestinationDir();

    final id = await _repository.startTransfer(
      serverAddr: serverAddr,
      files: files,
      srcDir: srcDir,
      destDir: effectiveDestDir,
      options: options,
    );

    final totalBytes = files.fold<BigInt>(
      BigInt.zero,
      (sum, file) => sum + file.fileSize,
    );

    final model = TransferModel(
      id: id,
      serverAddr: serverAddr,
      srcDir: srcDir,
      destDir: effectiveDestDir,
      files: files,
      status: FrbTransferStatus.queued,
      progress: FrbTransferProgress(
        bytesTransferred: BigInt.zero,
        totalBytes: totalBytes,
        filesCompleted: 0,
        totalFiles: files.length,
        progress: 0.0,
        speedBytesPerSec: BigInt.zero,
        etaSeconds: null,
      ),
    );

    _transfers[id] = model;
    notifyListeners();

    _subscribeToEvents(id);
    return id;
  }

  Future<void> cancelTransfer(int id) async {
    final transfer = _transfers[id];
    if (transfer?.isIncoming == true) {
      await decideIncomingTransfer(id, accept: false);
      return;
    }
    await _repository.cancelTransfer(id);
  }

  /// Polling is used for receiver state because progress is produced by the
  /// server's worker threads, not the sender's event stream.
  Future<void> refreshIncomingTransfers() async {
    if (!_isServerRunning) return;
    try {
      final incoming = await _repository.listIncomingTransfers();
      var changed = false;
      for (final transfer in incoming) {
        final remoteId = transfer.id.toInt();
        // Keep incoming and outgoing records distinct even when both devices
        // happen to allocate the same transfer id.
        final id = -remoteId - 1;
        final files = List<FrbFileSpec>.generate(
          transfer.filenames.length,
          (index) => FrbFileSpec(
            filename: transfer.filenames[index],
            fileSize: transfer.fileSizes[index],
          ),
        );
        final totalFiles = files.length;
        final received = transfer.receivedBytes;
        final total = transfer.totalBytes;
        final progress = total > BigInt.zero
            ? received.toDouble() / total.toDouble()
            : 1.0;
        final status = _incomingStatus(transfer.status);
        final model = TransferModel(
          id: id,
          remoteTransferId: remoteId,
          isIncoming: true,
          serverAddr: 'Incoming transfer',
          srcDir: '',
          destDir: _configuredDestDir,
          files: files,
          status: status,
          progress: FrbTransferProgress(
            bytesTransferred: received,
            totalBytes: total,
            filesCompleted: status == FrbTransferStatus.completed ? totalFiles : 0,
            totalFiles: totalFiles,
            progress: progress.clamp(0.0, 1.0),
            speedBytesPerSec: BigInt.zero,
            etaSeconds: null,
          ),
        );
        if (_transfers[id] != model) {
          _transfers[id] = model;
          changed = true;
        }
      }
      if (changed) notifyListeners();
    } catch (_) {
      // The receiver keeps working even when an individual state refresh fails.
    }
  }

  Future<void> decideIncomingTransfer(int id, {required bool accept}) async {
    final transfer = _transfers[id];
    if (transfer == null || !transfer.isIncoming || transfer.remoteTransferId == null) return;
    await _repository.decideIncomingTransfer(transfer.remoteTransferId!, accept: accept);
    await refreshIncomingTransfers();
  }

  FrbTransferStatus _incomingStatus(FrbIncomingTransferStatus status) {
    switch (status) {
      case FrbIncomingTransferStatus.pending:
        return FrbTransferStatus.queued;
      case FrbIncomingTransferStatus.accepted:
        return FrbTransferStatus.preparing;
      case FrbIncomingTransferStatus.receiving:
        return FrbTransferStatus.transferring;
      case FrbIncomingTransferStatus.completed:
        return FrbTransferStatus.completed;
      case FrbIncomingTransferStatus.rejected:
        return FrbTransferStatus.cancelled;
      case FrbIncomingTransferStatus.failed:
        return FrbTransferStatus.failed;
    }
  }

  Future<void> refreshState(int id) async {
    final status = await _repository.getStatus(id);
    final progress = await _repository.getProgress(id);
    if (status != null && _transfers.containsKey(id)) {
      _transfers[id] = _transfers[id]!.copyWith(
        status: status,
        progress: progress ?? _transfers[id]!.progress,
      );
      notifyListeners();
    }
  }

  void reattachListener(int id) {
    if (!_subscriptions.containsKey(id) &&
        _transfers.containsKey(id) &&
        !_transfers[id]!.isTerminal) {
      _subscribeToEvents(id);
      refreshState(id);
    }
  }

  void _subscribeToEvents(int id) {
    _subscriptions[id]?.cancel();
    _subscriptions[id] = _repository.events(id).listen(
      (event) {
        _onEvent(id, event);
      },
      onError: (err) {
        // Event channel closed
      },
      onDone: () {
        _subscriptions.remove(id);
      },
    );
  }

  void _onEvent(int id, FrbTransferEvent event) {
    final current = _transfers[id];
    if (current == null) return;

    event.when(
      started: () {
        _transfers[id] = current.copyWith(status: FrbTransferStatus.connecting);
      },
      progress: (prog) {
        _transfers[id] = current.copyWith(
          status: FrbTransferStatus.transferring,
          progress: prog,
        );
      },
      recovering: (recovery) {
        _transfers[id] = current.copyWith(
          status: FrbTransferStatus.recovering,
          recoveryInfo: recovery,
        );
      },
      verifying: () {
        _transfers[id] = current.copyWith(status: FrbTransferStatus.verifying);
      },
      completed: () {
        _transfers[id] = current.copyWith(
          status: FrbTransferStatus.completed,
          progress: FrbTransferProgress(
            bytesTransferred: current.progress.totalBytes,
            totalBytes: current.progress.totalBytes,
            filesCompleted: current.progress.totalFiles,
            totalFiles: current.progress.totalFiles,
            progress: 1.0,
            speedBytesPerSec: BigInt.zero,
            etaSeconds: BigInt.zero,
          ),
        );
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
      },
      failed: (errCode) {
        _transfers[id] = current.copyWith(
          status: FrbTransferStatus.failed,
          errorCode: errCode,
        );
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
      },
      cancelled: () {
        _transfers[id] = current.copyWith(status: FrbTransferStatus.cancelled);
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
      },
    );

    notifyListeners();
  }

  void disposeScreenListeners() {}

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _incomingPoller?.cancel();
    super.dispose();
  }
}
