import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carixsend_flutter/src/rust/frb_api.dart';
import 'package:carixsend_flutter/app/services/transfer_repository.dart';
import 'package:carixsend_flutter/app/controllers/transfer_controller.dart';

class FakeTransferRepository implements TransferRepository {
  int _nextId = 1000;
  final Map<int, FrbTransferStatus> statuses = {};
  final Map<int, FrbTransferProgress> progressMap = {};
  final Map<int, StreamController<FrbTransferEvent>> controllers = {};

  @override
  Future<String> startServer({String bindAddr = '0.0.0.0:23984', String? destDir}) async {
    return bindAddr;
  }

  @override
  Future<int> startTransfer({
    required String serverAddr,
    required List<FrbFileSpec> files,
    required String srcDir,
    String? destDir,
    FrbTransferOptions? options,
  }) async {
    final id = _nextId++;
    statuses[id] = FrbTransferStatus.queued;
    progressMap[id] = FrbTransferProgress(
      bytesTransferred: BigInt.zero,
      totalBytes: files.first.fileSize,
      filesCompleted: 0,
      totalFiles: files.length,
      progress: 0.0,
      speedBytesPerSec: BigInt.zero,
      etaSeconds: null,
    );
    controllers[id] = StreamController<FrbTransferEvent>.broadcast();
    return id;
  }

  @override
  Future<void> cancelTransfer(int id) async {
    statuses[id] = FrbTransferStatus.cancelled;
    controllers[id]?.add(const FrbTransferEvent.cancelled());
  }

  @override
  Future<FrbTransferStatus?> getStatus(int id) async => statuses[id];

  @override
  Future<FrbTransferProgress?> getProgress(int id) async => progressMap[id];

  @override
  Stream<FrbTransferEvent> events(int id) {
    return controllers[id]?.stream ?? const Stream.empty();
  }

  @override
  Future<List<FrbIncomingTransfer>> listIncomingTransfers() async => const [];

  @override
  Future<void> decideIncomingTransfer(int id, {required bool accept}) async {}

  void emitEvent(int id, FrbTransferEvent event) {
    controllers[id]?.add(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransferRepository fakeRepo;
  late TransferController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeRepo = FakeTransferRepository();
    controller = TransferController(fakeRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  test('startTransfer creates model and subscribes to events', () async {
    final id = await controller.startTransfer(
      serverAddr: '127.0.0.1:23984',
      files: [FrbFileSpec(filename: 'test.bin', fileSize: BigInt.from(100))],
      srcDir: '/tmp',
    );

    expect(id, equals(1000));
    expect(controller.transfers.containsKey(1000), isTrue);
    expect(controller.transfers[1000]!.status, equals(FrbTransferStatus.queued));
  });

  test('event transitions update model status', () async {
    final id = await controller.startTransfer(
      serverAddr: '127.0.0.1:23984',
      files: [FrbFileSpec(filename: 'test.bin', fileSize: BigInt.from(100))],
      srcDir: '/tmp',
    );

    fakeRepo.emitEvent(id, const FrbTransferEvent.started());
    await Future.delayed(Duration.zero);
    expect(controller.transfers[id]!.status, equals(FrbTransferStatus.connecting));

    fakeRepo.emitEvent(id, const FrbTransferEvent.verifying());
    await Future.delayed(Duration.zero);
    expect(controller.transfers[id]!.status, equals(FrbTransferStatus.verifying));

    fakeRepo.emitEvent(id, const FrbTransferEvent.completed());
    await Future.delayed(Duration.zero);
    expect(controller.transfers[id]!.status, equals(FrbTransferStatus.completed));
    expect(controller.transfers[id]!.isTerminal, isTrue);
  });

  test('multiple transfers remain isolated', () async {
    final id1 = await controller.startTransfer(
      serverAddr: '127.0.0.1:23984',
      files: [FrbFileSpec(filename: 'f1.bin', fileSize: BigInt.from(100))],
      srcDir: '/tmp',
    );

    final id2 = await controller.startTransfer(
      serverAddr: '127.0.0.1:23984',
      files: [FrbFileSpec(filename: 'f2.bin', fileSize: BigInt.from(200))],
      srcDir: '/tmp',
    );

    await controller.cancelTransfer(id1);
    await Future.delayed(Duration.zero);

    expect(controller.transfers[id1]!.status, equals(FrbTransferStatus.cancelled));
    expect(controller.transfers[id2]!.status, equals(FrbTransferStatus.queued));
  });
}
