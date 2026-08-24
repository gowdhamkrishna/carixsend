import 'package:flutter/material.dart';
import 'file_manager_screen.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/transfer_controller.dart';
import '../services/permission_service.dart';
import '../services/settings_service.dart';
import '../widgets/tv_focusable.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _currentDestPath;
  String _defaultDownloadsPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final defaultPath = await SettingsService.getDefaultDownloadsPath();
    final controller = Provider.of<TransferController>(context, listen: false);
    final activeDest = await controller.getEffectiveDestinationDir();

    if (mounted) {
      setState(() {
        _defaultDownloadsPath = defaultPath;
        _currentDestPath = activeDest;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickNewDestinationFolder() async {
    final granted = await PermissionService.requestStoragePermissions();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
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
      setState(() {
        _currentDestPath = newFolder;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destination updated to: $newFolder')),
      );
    }
  }

  Future<void> _resetToDefaultDownloads() async {
    final controller = Provider.of<TransferController>(context, listen: false);
    await controller.setDestinationDir(null);
    final defaultPath = await SettingsService.getDefaultDownloadsPath();

    if (mounted) {
      setState(() {
        _currentDestPath = defaultPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
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
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device name updated to: ${controller.deviceName}')),
      );
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(14),
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
                                        color: Colors.black,
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
                          autofocus: true,
                          focusBorderColor: primaryColor,
                          focusBackgroundColor: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2C),
                                      borderRadius: BorderRadius.circular(14),
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
