import 'package:flutter/material.dart';
import 'file_manager_screen.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/transfer_controller.dart';
import '../services/permission_service.dart';
import '../services/settings_service.dart';
import '../widgets/tv_focusable.dart';
import '../widgets/neumorphic_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    await SettingsService.getDefaultDownloadsPath();
    if (!mounted) return;
    final controller = Provider.of<TransferController>(context, listen: false);
    await controller.getEffectiveDestinationDir();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickNewDestinationFolder() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final granted = await PermissionService.requestStoragePermissions();
    if (!granted && mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Storage permission is required to choose folder.')),
      );
      return;
    }

    if (!mounted) return;
    final newFolder = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const FileManagerScreen(mode: FileManagerMode.pickFolder),
      ),
    );

    if (newFolder != null && mounted) {
      final controller = Provider.of<TransferController>(context, listen: false);
      await controller.setDestinationDir(newFolder);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Destination updated to: $newFolder')),
        );
      }
    }
  }

  Future<void> _resetToDefaultDownloads() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final controller = Provider.of<TransferController>(context, listen: false);
    await controller.setDestinationDir(null);
    final defaultPath = await SettingsService.getDefaultDownloadsPath();

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Destination reset to default Downloads: $defaultPath')),
      );
    }
  }

  Future<void> _editDeviceNameDialog() async {
    final controller = Provider.of<TransferController>(context, listen: false);
    final textController = TextEditingController(text: controller.deviceName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Device Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This unique name identifies your device to nearby LAN senders/receivers.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, textController.text.trim()),
              child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (newName != null && mounted) {
      await controller.setDeviceName(newName.isEmpty ? null : newName);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device name updated to: ${controller.deviceName}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.white;
    final controller = Provider.of<TransferController>(context);

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
              title: const Text('Settings — Send to TV'),
              centerTitle: true,
              elevation: 0,
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Identity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Device Name Card
                        TVFocusableCard(
                          autofocus: true,
                          focusBorderColor: primaryColor,
                          focusBackgroundColor: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.all(20),
                          onTap: _editDeviceNameDialog,
                          child: Row(
                            children: [
                              NeumorphicContainer(
                                padding: const EdgeInsets.all(12),
                                borderRadius: 14.0,
                                isPressed: false,
                                child: const Icon(Icons.tv_rounded, color: primaryColor, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Device Name',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.deviceName,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TVButton(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('Edit'),
                                color: primaryColor,
                                onPressed: _editDeviceNameDialog,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Storage & Receiving',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Destination Path Setting Card
                        TVFocusableCard(
                          // The controls inside this card are the interactive
                          // elements. Keeping the decorative container out of
                          // traversal lets D-pad focus reach Browse/Default.
                          focusable: false,
                          focusBorderColor: primaryColor,
                          focusBackgroundColor: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  NeumorphicContainer(
                                    padding: const EdgeInsets.all(12),
                                    borderRadius: 14.0,
                                    isPressed: false,
                                    child: const Icon(Icons.folder_special_rounded, color: primaryColor, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Destination Folder',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Files received on this device are saved here',
                                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: TVButton(
                                      icon: const Icon(Icons.folder_open_rounded),
                                      label: const Text('Browse Folder'),
                                      color: primaryColor,
                                      onPressed: _pickNewDestinationFolder,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TVButton(
                                      icon: const Icon(Icons.restore_rounded),
                                      label: const Text('Default (Downloads)'),
                                      isSecondary: true,
                                      color: Colors.grey.shade400,
                                      onPressed: _resetToDefaultDownloads,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
}
