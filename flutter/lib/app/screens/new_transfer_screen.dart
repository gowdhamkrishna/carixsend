import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../src/rust/frb_api.dart';
import '../controllers/transfer_controller.dart';
import '../services/device_discovery_service.dart';
import '../services/permission_service.dart';
import '../widgets/tv_focusable.dart';
import 'file_manager_screen.dart';

class NewTransferScreen extends StatefulWidget {
  final List<PlatformFile>? initialFiles;

  const NewTransferScreen({super.key, this.initialFiles});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverAddrController = TextEditingController();
  final _discoveryService = DeviceDiscoveryService();

  List<DiscoveredDevice> _discoveredDevices = [];
  StreamSubscription<List<DiscoveredDevice>>? _discoverySub;

  List<PlatformFile> _selectedFiles = [];
  int _workerCount = 4;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      _selectedFiles = widget.initialFiles!;
    }
    _startDiscovery();
  }

  void _startDiscovery() {
    _discoverySub?.cancel();
    _discoveryService.startDiscovery();
    _discoverySub = _discoveryService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _discoveredDevices = devices;
        });
      }
    });
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    _discoveryService.dispose();
    _serverAddrController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const FileManagerScreen(mode: FileManagerMode.pickFiles),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newFiles = result.map((path) {
        final f = File(path);
        return PlatformFile(
          name: f.uri.pathSegments.last,
          path: path,
          size: f.existsSync() ? f.lengthSync() : 0,
        );
      }).toList();

      setState(() {
        _selectedFiles = newFiles;
      });
    }
  }



  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_serverAddrController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a nearby receiver first.')),
      );
      return;
    }
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final controller = Provider.of<TransferController>(context, listen: false);

      String srcDirectory;
      final frbFiles = <FrbFileSpec>[];

      bool allShareParent = true;
      String? commonParent;

      for (final f in _selectedFiles) {
        if (f.path != null && File(f.path!).existsSync()) {
          final parent = File(f.path!).parent.path;
          if (commonParent == null) {
            commonParent = parent;
          } else if (commonParent != parent) {
            allShareParent = false;
            break;
          }
        } else {
          allShareParent = false;
          break;
        }
      }

      if (allShareParent && commonParent != null) {
        srcDirectory = commonParent;
        for (final f in _selectedFiles) {
          frbFiles.add(FrbFileSpec(
            filename: f.name,
            fileSize: BigInt.from(f.size),
          ));
        }
      } else {
        final tempStaging = await Directory.systemTemp.createTemp('carixsend_stage_');
        for (final f in _selectedFiles) {
          final targetFile = File('${tempStaging.path}/${f.name}');
          if (f.path != null && File(f.path!).existsSync()) {
            final srcFile = File(f.path!);
            if (!targetFile.existsSync()) {
              await srcFile.copy(targetFile.path);
            }
            frbFiles.add(FrbFileSpec(
              filename: f.name,
              fileSize: BigInt.from(targetFile.lengthSync()),
            ));
          } else if (f.bytes != null) {
            if (!targetFile.existsSync()) {
              await targetFile.writeAsBytes(f.bytes!);
            }
            frbFiles.add(FrbFileSpec(
              filename: f.name,
              fileSize: BigInt.from(targetFile.lengthSync()),
            ));
          }
        }
        srcDirectory = tempStaging.path;
      }

      if (frbFiles.isEmpty) {
        throw Exception('Could not access selected files.');
      }

      await controller.startTransfer(
        serverAddr: _serverAddrController.text.trim(),
        files: frbFiles,
        srcDir: srcDirectory,
        options: FrbTransferOptions(
          workerCount: BigInt.from(_workerCount),
          chunkSize: BigInt.from(4 * 1024 * 1024),
          bufferSize: BigInt.from(128 * 1024),
          queueCapacity: BigInt.from(8),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start transfer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.white;

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
              title: const Text('Send Files — Select Receiver'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Rescan Devices',
                  onPressed: () {
                    _startDiscovery();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scanning LAN for receivers...')),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.radar_rounded, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Discovered LAN Receivers',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_discoveryService.isScanning)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_discoveredDevices.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Looking for nearby Send to TV devices…',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _discoveredDevices.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final device = entry.value;
                                  final isSelected = _serverAddrController.text.trim() == device.address;
                                  return TVChoiceChip(
                                    autofocus: index == 0,
                                    avatar: const Icon(Icons.tv_rounded),
                                    label: Text(device.displayName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _serverAddrController.text = device.address;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_serverAddrController.text.trim().isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Select a nearby device to continue.',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // File Picker Tile
                    TVFocusableCard(
                      focusBorderColor: primaryColor,
                      focusBackgroundColor: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      onTap: _pickFiles,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12),
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
                            child: const Icon(Icons.folder_open_rounded, color: primaryColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFiles.isEmpty
                                      ? 'Select Files to Send'
                                      : '${_selectedFiles.length} file(s) selected',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedFiles.isNotEmpty
                                      ? _selectedFiles.map((f) => f.name).join(', ')
                                      : 'Tap or press OK to browse storage',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),





                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: TVButton(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(_isSubmitting ? 'Starting Transfer...' : 'Start Transfer'),
                        color: primaryColor,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
