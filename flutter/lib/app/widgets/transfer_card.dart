import 'package:flutter/material.dart';
import '../../src/rust/frb_api.dart';
import '../models/transfer_model.dart';
import 'error_message.dart';
import 'tv_focusable.dart';

class TransferCard extends StatelessWidget {
  final TransferModel transfer;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const TransferCard({
    super.key,
    required this.transfer,
    this.onCancel,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusText = _getStatusLabel(transfer);
    final statusColor = _getStatusColor(transfer.status, theme);

    final String filesText = transfer.files.length == 1
        ? transfer.files.first.filename
        : '${transfer.files.length} files';

    return TVFocusableCard(
      focusable: onAccept == null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      focusBorderColor: statusColor,
      focusBackgroundColor: statusColor.withValues(alpha: 0.1),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                transfer.status == FrbTransferStatus.completed
                    ? Icons.check_circle_rounded
                    : (transfer.status == FrbTransferStatus.failed
                        ? Icons.error_rounded
                        : Icons.swap_horiz_rounded),
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  filesText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Server: ${transfer.serverAddr}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(),
          if (transfer.status == FrbTransferStatus.transferring ||
              transfer.status == FrbTransferStatus.verifying ||
              transfer.status == FrbTransferStatus.completed) ...[
            const SizedBox(height: 6),
            _buildProgressDetails(theme),
          ],
          if (transfer.errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              getTransferErrorMessage(transfer.errorCode!),
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
          ],
          if (transfer.isIncoming &&
              transfer.status == FrbTransferStatus.queued &&
              onAccept != null &&
              onReject != null) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TVButton(
                  autofocus: true,
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('ACCEPT'),
                  color: Colors.greenAccent,
                  onPressed: onAccept,
                ),
                const SizedBox(height: 12),
                TVButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  label: const Text('REJECT'),
                  isSecondary: true,
                  color: Colors.redAccent,
                  onPressed: onReject,
                ),
              ],
            ),
          ],
          if (!transfer.isTerminal && onCancel != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TVButton(
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel'),
                isSecondary: true,
                color: theme.colorScheme.error,
                onPressed: onCancel,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const trackColor = Color(0xFF16181C);
    final progressColor = _getProgressColor();

    if (transfer.status == FrbTransferStatus.completed) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: 1.0,
          backgroundColor: trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 6,
        ),
      );
    } else if (transfer.status == FrbTransferStatus.transferring) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: transfer.progress.progress.clamp(0.0, 1.0),
          backgroundColor: trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 6,
        ),
      );
    } else if (transfer.status == FrbTransferStatus.failed ||
        transfer.status == FrbTransferStatus.cancelled) {
      return const SizedBox.shrink();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: null,
          backgroundColor: trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 6,
        ),
      );
    }
  }

  Color _getProgressColor() {
    switch (transfer.status) {
      case FrbTransferStatus.completed:
        return Colors.greenAccent;
      case FrbTransferStatus.transferring:
        return Colors.lightBlueAccent;
      case FrbTransferStatus.recovering:
        return Colors.orangeAccent;
      case FrbTransferStatus.verifying:
        return Colors.purpleAccent;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildProgressDetails(ThemeData theme) {
    final prog = transfer.progress;
    final transferredStr = _formatBytes(prog.bytesTransferred);
    final totalStr = _formatBytes(prog.totalBytes);
    final pctStr = '${(prog.progress * 100).toStringAsFixed(1)}%';

    String? statsText;
    if (transfer.status == FrbTransferStatus.transferring &&
        prog.speedBytesPerSec > BigInt.zero) {
      final speedStr = '${_formatBytes(prog.speedBytesPerSec)}/s';
      final etaStr = prog.etaSeconds != null ? 'ETA ${prog.etaSeconds}s' : null;
      statsText = etaStr != null ? '$speedStr • $etaStr' : speedStr;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$transferredStr / $totalStr ($pctStr)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
          ),
        ),
        if (statsText != null)
          Text(
            statsText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      ],
    );
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

  String _getStatusLabel(TransferModel model) {
    switch (model.status) {
      case FrbTransferStatus.queued:
        return model.isIncoming ? 'Awaiting your approval' : 'Waiting for receiver';
      case FrbTransferStatus.connecting:
        return 'Connecting...';
      case FrbTransferStatus.preparing:
        return 'Preparing...';
      case FrbTransferStatus.transferring:
        return 'Transferring';
      case FrbTransferStatus.recovering:
        final attempt = model.recoveryInfo?.attempt ?? 1;
        final maxAtt = model.recoveryInfo?.maxAttempts ?? 3;
        return 'Recovering ($attempt/$maxAtt)';
      case FrbTransferStatus.verifying:
        return 'Verifying SHA-256...';
      case FrbTransferStatus.completed:
        return 'Completed ✓';
      case FrbTransferStatus.failed:
        return 'Failed';
      case FrbTransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(FrbTransferStatus status, ThemeData theme) {
    switch (status) {
      case FrbTransferStatus.queued:
      case FrbTransferStatus.connecting:
      case FrbTransferStatus.preparing:
        return Colors.grey.shade500;
      case FrbTransferStatus.transferring:
        return Colors.white;
      case FrbTransferStatus.recovering:
        return Colors.orangeAccent;
      case FrbTransferStatus.verifying:
        return Colors.purpleAccent;
      case FrbTransferStatus.completed:
        return Colors.white;
      case FrbTransferStatus.failed:
        return theme.colorScheme.error;
      case FrbTransferStatus.cancelled:
        return Colors.grey.shade400;
    }
  }
}
