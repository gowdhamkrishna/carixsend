import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../src/rust/frb_api.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/error_message.dart';
import '../widgets/tv_focusable.dart';

class TransferDetailScreen extends StatefulWidget {
  final int transferId;

  const TransferDetailScreen({super.key, required this.transferId});

  @override
  State<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends State<TransferDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransferController>(context, listen: false)
          .reattachListener(widget.transferId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransferController>(context);
    final transfer = controller.transfers[widget.transferId];

    if (transfer == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Transfer #${widget.transferId}')),
        body: const Center(child: Text('Transfer not found')),
      );
    }

    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        LogicalKeySet(LogicalKeyboardKey.goBack): const DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              Navigator.maybePop(context);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Transfer Details #${transfer.id}'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF3B3B3B),
                          offset: Offset(-4, -4),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Color(0xFF1D1D1D),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Status', _statusString(transfer.status)),
                          const Divider(),
                          _buildInfoRow('Server Address', transfer.serverAddr),
                          const Divider(),
                          _buildInfoRow('Source Path', transfer.srcDir),
                          if (transfer.destDir != null) ...[
                            const Divider(),
                            _buildInfoRow('Destination Path', transfer.destDir!),
                          ],
                          const Divider(),
                          _buildInfoRow('Files', '${transfer.files.length}'),
                          const Divider(),
                          _buildInfoRow(
                            'Total Size',
                            _formatBytes(transfer.progress.totalBytes),
                          ),
                          if (transfer.recoveryInfo != null) ...[
                            const Divider(),
                            _buildInfoRow(
                              'Recovery Attempt',
                              '${transfer.recoveryInfo!.attempt} / ${transfer.recoveryInfo!.maxAttempts}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF3B3B3B),
                          offset: Offset(-4, -4),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Color(0xFF1D1D1D),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Real-Time Progress', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: transfer.status == FrbTransferStatus.completed
                                  ? 1.0
                                  : (transfer.status == FrbTransferStatus.transferring
                                      ? transfer.progress.progress.clamp(0.0, 1.0)
                                      : null),
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Transferred',
                            '${_formatBytes(transfer.progress.bytesTransferred)} / ${_formatBytes(transfer.progress.totalBytes)} (${(transfer.progress.progress * 100).toStringAsFixed(1)}%)',
                          ),
                          if (transfer.progress.speedBytesPerSec > BigInt.zero) ...[
                            const Divider(),
                            _buildInfoRow(
                              'Transfer Speed',
                              '${_formatBytes(transfer.progress.speedBytesPerSec)}/s',
                            ),
                          ],
                          if (transfer.progress.etaSeconds != null) ...[
                            const Divider(),
                            _buildInfoRow(
                              'ETA',
                              '${transfer.progress.etaSeconds} sec',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Files', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...transfer.files.map((file) => ListTile(
                        leading: const Icon(Icons.description_outlined, color: Colors.white),
                        title: Text(file.filename),
                        subtitle: Text(
                            '${(file.fileSize.toInt() / 1024).toStringAsFixed(1)} KB'),
                      )),
                  if (transfer.errorCode != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                getTransferErrorMessage(transfer.errorCode!),
                                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!transfer.isTerminal)
                    SizedBox(
                      width: double.infinity,
                      child: TVButton(
                        autofocus: true,
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text('Cancel Transfer'),
                        color: theme.colorScheme.error,
                        onPressed: () {
                          controller.cancelTransfer(transfer.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _statusString(FrbTransferStatus status) {
    switch (status) {
      case FrbTransferStatus.queued:
        return 'Queued';
      case FrbTransferStatus.connecting:
        return 'Connecting';
      case FrbTransferStatus.preparing:
        return 'Preparing';
      case FrbTransferStatus.transferring:
        return 'Transferring';
      case FrbTransferStatus.recovering:
        return 'Recovering';
      case FrbTransferStatus.verifying:
        return 'Verifying SHA-256';
      case FrbTransferStatus.completed:
        return 'Completed';
      case FrbTransferStatus.failed:
        return 'Failed';
      case FrbTransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatBytes(BigInt bytes) {
    final b = bytes.toDouble();
    if (b >= 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (b >= 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (b >= 1024) {
      return '${(b / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${bytes.toInt()} B';
    }
  }
}
