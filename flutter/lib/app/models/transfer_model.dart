import '../../src/rust/frb_api.dart';

class TransferModel {
  final int id;
  final String serverAddr;
  final String srcDir;
  final String? destDir;
  final List<FrbFileSpec> files;
  final FrbTransferStatus status;
  final FrbTransferProgress progress;
  final FrbTransferErrorCode? errorCode;
  final FrbRecoveryInfo? recoveryInfo;
  final bool isIncoming;
  final int? remoteTransferId;

  const TransferModel({
    required this.id,
    required this.serverAddr,
    required this.srcDir,
    this.destDir,
    required this.files,
    required this.status,
    required this.progress,
    this.errorCode,
    this.recoveryInfo,
    this.isIncoming = false,
    this.remoteTransferId,
  });

  bool get isTerminal =>
      status == FrbTransferStatus.completed ||
      status == FrbTransferStatus.failed ||
      status == FrbTransferStatus.cancelled;

  TransferModel copyWith({
    FrbTransferStatus? status,
    FrbTransferProgress? progress,
    FrbTransferErrorCode? errorCode,
    FrbRecoveryInfo? recoveryInfo,
  }) {
    return TransferModel(
      id: id,
      serverAddr: serverAddr,
      srcDir: srcDir,
      destDir: destDir,
      files: files,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorCode: errorCode ?? this.errorCode,
      recoveryInfo: recoveryInfo ?? this.recoveryInfo,
      isIncoming: isIncoming,
      remoteTransferId: remoteTransferId,
    );
  }
}
