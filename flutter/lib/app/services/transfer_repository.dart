import '../../src/rust/frb_api.dart';

abstract interface class TransferRepository {
  Future<String> startServer({String bindAddr = '0.0.0.0:23984', String? destDir});

  Future<int> startTransfer({
    required String serverAddr,
    required List<FrbFileSpec> files,
    required String srcDir,
    String? destDir,
    FrbTransferOptions? options,
  });

  Future<void> cancelTransfer(int id);

  Future<FrbTransferStatus?> getStatus(int id);

  Future<FrbTransferProgress?> getProgress(int id);

  Stream<FrbTransferEvent> events(int id);

  Future<List<FrbIncomingTransfer>> listIncomingTransfers();

  Future<void> decideIncomingTransfer(int id, {required bool accept});
}

class RustTransferRepository implements TransferRepository {
  const RustTransferRepository();

  @override
  Future<String> startServer({String bindAddr = '0.0.0.0:23984', String? destDir}) async {
    return await frbStartServer(bindAddr: bindAddr, destDir: destDir);
  }

  @override
  Future<int> startTransfer({
    required String serverAddr,
    required List<FrbFileSpec> files,
    required String srcDir,
    String? destDir,
    FrbTransferOptions? options,
  }) async {
    final opts = options ??
        FrbTransferOptions(
          workerCount: BigInt.from(4),
          chunkSize: BigInt.from(4 * 1024 * 1024),
          bufferSize: BigInt.from(128 * 1024),
          queueCapacity: BigInt.from(8),
        );

    final idVal = await frbStartTransfer(
      serverAddr: serverAddr,
      files: files,
      srcDir: srcDir,
      destDir: destDir,
      options: opts,
    );
    return idVal.toInt();
  }

  @override
  Future<void> cancelTransfer(int id) async {
    await frbCancelTransfer(id: BigInt.from(id));
  }

  @override
  Future<FrbTransferStatus?> getStatus(int id) async {
    return await frbGetStatus(id: BigInt.from(id));
  }

  @override
  Future<FrbTransferProgress?> getProgress(int id) async {
    return await frbGetProgress(id: BigInt.from(id));
  }

  @override
  Stream<FrbTransferEvent> events(int id) {
    return frbSubscribe(id: BigInt.from(id));
  }

  @override
  Future<List<FrbIncomingTransfer>> listIncomingTransfers() =>
      frbListIncomingTransfers();

  @override
  Future<void> decideIncomingTransfer(int id, {required bool accept}) =>
      frbDecideIncomingTransfer(id: BigInt.from(id), accept: accept);
}
