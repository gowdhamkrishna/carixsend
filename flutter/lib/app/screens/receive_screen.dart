import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../src/rust/frb_api.dart';
import '../controllers/transfer_controller.dart';
import '../services/permission_service.dart';
import '../widgets/transfer_card.dart';
import '../widgets/tv_focusable.dart';
import 'transfer_detail_screen.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransferController>(context);
    final theme = Theme.of(context);
    final isListening = controller.isServerRunning;
    final deviceName = controller.deviceName;

    final incomingTransfers = controller.transferList.where((item) => item.isIncoming).toList();

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
              title: const Text('Receive Files — Send to TV'),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Compact Receiver Status Banner
                  if (!isListening)
                    TVFocusableCard(
                      autofocus: true,
                      focusBorderColor: Colors.black,
                      focusBackgroundColor: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_tethering_off_rounded, color: Colors.grey.shade500, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Receiver is offline',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade400),
                            ),
                          ),
                          TVButton(
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            label: const Text('Start'),
                            color: theme.colorScheme.primary,
                            onPressed: () async {
                              try {
                                await PermissionService.requestStoragePermissions();
                                await controller.startReceiverServer();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to start server: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF3B3B3B),
                            offset: Offset(-2, -2),
                            blurRadius: 5,
                          ),
                          BoxShadow(
                            color: Color(0xFF1D1D1D),
                            offset: Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_tethering_rounded, color: Colors.greenAccent, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ready to Receive',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Send files to "$deviceName"',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Incoming & Received Files',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (incomingTransfers.isNotEmpty)
                        Text(
                          '${incomingTransfers.length} total',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (incomingTransfers.isEmpty)
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
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.downloading_rounded, size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 12),
                            Text(
                              'No incoming files yet',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Open Send to TV on another device and select $deviceName',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: incomingTransfers.length,
                      itemBuilder: (context, index) {
                        final item = incomingTransfers[index];
                        final isPending = item.status == FrbTransferStatus.queued;
                        return TransferCard(
                          transfer: item,
                          onAccept: isPending
                              ? () => controller.decideIncomingTransfer(item.id, accept: true)
                              : null,
                          onReject: isPending
                              ? () => controller.decideIncomingTransfer(item.id, accept: false)
                              : null,
                          onCancel: isPending ? null : () => controller.cancelTransfer(item.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransferDetailScreen(transferId: item.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
