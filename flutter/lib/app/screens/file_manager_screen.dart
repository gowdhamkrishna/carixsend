import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../services/permission_service.dart';
import '../widgets/tv_focusable.dart';

enum FileManagerMode { view, pickFiles, pickFolder }

class FileManagerScreen extends StatefulWidget {
  final FileManagerMode mode;

  const FileManagerScreen({super.key, this.mode = FileManagerMode.view});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  String _currentPath = '';
  String _storageRoot = '';
  List<FileSystemEntity> _entities = [];
  Set<String> _selectedPaths = {};
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<String> _findStorageRoot() async {
    // On Android TV / boxes, start from /storage so all volumes are visible
    // (internal emulated + any USB drives mounted under /storage/<UUID>)
    if (await Directory('/storage').exists()) {
      final storageChildren = await Directory('/storage').list().toList();
      debugPrint('[FileManager] /storage children: ${storageChildren.map((e) => e.path).toList()}');
      // If /storage has more than just 'emulated', show /storage as root so
      // user sees all volumes.  Otherwise dive straight into emulated/0.
      final hasExtraVolumes = storageChildren.any((e) {
        final name = e.path.split('/').last;
        return name != 'emulated' && name != 'self';
      });
      if (hasExtraVolumes) {
        debugPrint('[FileManager] Extra volumes found, using /storage as root');
        return '/storage';
      }
    }

    // Try path_provider — getExternalStorageDirectory() returns something like
    // /storage/emulated/0/Android/data/<pkg>/files; walk up to the volume root.
    try {
      final extDir = await getExternalStorageDirectory();
      debugPrint('[FileManager] getExternalStorageDirectory: ${extDir?.path}');
      if (extDir != null) {
        Directory candidate = extDir;
        for (int i = 0; i < 6; i++) {
          final androidChild = Directory('${candidate.path}/Android');
          if (await androidChild.exists()) {
            debugPrint('[FileManager] Found Android child at: ${candidate.path}');
            return candidate.path;
          }
          final parent = candidate.parent;
          if (parent.path == candidate.path) break;
          candidate = parent;
        }
        // Walk up 4 levels from app-specific dir
        Directory root = extDir;
        for (int i = 0; i < 4; i++) {
          final p = root.parent;
          if (p.path == root.path) break;
          root = p;
        }
        if (await root.exists()) {
          debugPrint('[FileManager] Fallback root (4 levels up): ${root.path}');
          return root.path;
        }
      }
    } catch (e) {
      debugPrint('[FileManager] getExternalStorageDirectory error: $e');
    }

    // Probe well-known paths
    for (final path in ['/storage/emulated/0', '/sdcard', '/storage/sdcard0', '/mnt/sdcard']) {
      if (await Directory(path).exists()) {
        debugPrint('[FileManager] Using probed path: $path');
        return path;
      }
    }

    debugPrint('[FileManager] Falling back to filesystem root /');
    return '/';
  }

  Future<void> _initStorage() async {
    final granted = await PermissionService.requestStoragePermissions();
    if (!mounted) return;
    setState(() {
      _hasPermission = granted;
    });
    if (granted) {
      final root = await _findStorageRoot();
      if (!mounted) return;
      setState(() {
        _storageRoot = root;
        _currentPath = root;
      });
      _loadDirectory(root);
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDirectory(String path) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentPath = path;
    });

    try {
      final dir = Directory(path);
      final exists = await dir.exists();
      debugPrint('[FileManager] Loading: $path  exists=$exists');

      if (exists) {
        List<FileSystemEntity> entities = [];
        try {
          entities = await dir.list(followLinks: false).toList();
        } on FileSystemException catch (e) {
          debugPrint('[FileManager] list() error: $e');
          // Permission denied on this path — show a snackbar and stop
          if (mounted) {
            setState(() { _entities = []; _isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Permission denied: $path')),
            );
          }
          return;
        }

        debugPrint('[FileManager] Found ${entities.length} entries in $path');

        entities.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

        if (mounted) {
          setState(() {
            _entities = entities;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('[FileManager] Path does not exist: $path');
        if (mounted) {
          setState(() {
            _entities = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[FileManager] Unexpected error loading $path: $e');
      if (mounted) {
        setState(() {
          _entities = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading directory: $e')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final root = _storageRoot.isNotEmpty ? _storageRoot : '/';
    if (_currentPath != root && _currentPath != '/') {
      final parentDir = Directory(_currentPath).parent.path;
      _loadDirectory(parentDir);
      return false;
    }
    return true;
  }

  void _openEntity(FileSystemEntity entity) {
    if (entity is Directory) {
      _loadDirectory(entity.path);
    } else if (entity is File) {
      if (widget.mode == FileManagerMode.pickFiles) {
        setState(() {
          if (_selectedPaths.contains(entity.path)) {
            _selectedPaths.remove(entity.path);
          } else {
            _selectedPaths.add(entity.path);
          }
        });
      } else if (widget.mode == FileManagerMode.view) {
        OpenFilex.open(entity.path).then((result) {
          if (result.type != ResultType.done && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open file: ${result.message}')),
            );
          }
        });
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    i = i >= suffixes.length ? suffixes.length - 1 : i;
    final value = bytes / (1 << (i * 10));
    return "${value.toStringAsFixed(1)} ${suffixes[i]}";
  }

  Widget _buildEntityIcon(FileSystemEntity entity) {
    if (entity is Directory) {
      return const Icon(Icons.folder_rounded, color: Color(0xFF00E5FF), size: 36);
    }
    
    final path = entity.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.avi')) {
      return const Icon(Icons.movie_rounded, color: Colors.orange, size: 36);
    } else if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.flac')) {
      return const Icon(Icons.audiotrack_rounded, color: Colors.purple, size: 36);
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.gif')) {
      return const Icon(Icons.image_rounded, color: Colors.green, size: 36);
    } else if (path.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 36);
    } else if (path.endsWith('.apk')) {
      return const Icon(Icons.android_rounded, color: Colors.greenAccent, size: 36);
    } else if (path.endsWith('.zip') || path.endsWith('.tar') || path.endsWith('.gz')) {
      return const Icon(Icons.archive_rounded, color: Colors.yellow, size: 36);
    }
    
    return const Icon(Icons.insert_drive_file_rounded, color: Colors.grey, size: 36);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
          LogicalKeySet(LogicalKeyboardKey.goBack): const DismissIntent(),
        },
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) async {
                final pop = await _onWillPop();
                if (pop && mounted) {
                  Navigator.maybePop(context);
                }
                return null;
              },
            ),
          },
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.mode == FileManagerMode.pickFiles
                        ? 'Select Files'
                        : (widget.mode == FileManagerMode.pickFolder ? 'Select Folder' : 'File Manager')),
                    Text(
                      _currentPath,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
                actions: [
                  if (widget.mode == FileManagerMode.pickFolder)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _currentPath);
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('SELECT FOLDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(backgroundColor: const Color(0xFF3B3B3B)),
                      ),
                    ),
                ],
              ),
              floatingActionButton: widget.mode == FileManagerMode.pickFiles && _selectedPaths.isNotEmpty
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.pop(context, _selectedPaths.toList());
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      label: Text('Confirm (${_selectedPaths.length})'),
                      icon: const Icon(Icons.check),
                    )
                  : null,
              body: !_hasPermission && !_isLoading
                  ? Center(
                      child: Text(
                        'Storage permission is required to view files.',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
                      ),
                    )
                  : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _entities.isEmpty
                          ? Center(
                              child: Text(
                                'Empty Directory',
                                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _entities.length,
                              itemBuilder: (context, index) {
                                final entity = _entities[index];
                                final name = entity.path.split('/').last;
                                final isDir = entity is Directory;
                                
                                String sizeStr = '';
                                if (!isDir) {
                                  try {
                                    final stat = entity.statSync();
                                    sizeStr = _formatSize(stat.size);
                                  } catch (_) {}
                                }
                                
                                final isSelected = _selectedPaths.contains(entity.path);

                                return TVFocusableCard(
                                  autofocus: index == 0,
                                  focusBorderColor: isSelected ? Colors.greenAccent : const Color(0xFF00E5FF),
                                  // ignore: deprecated_member_use
                                  focusBackgroundColor: isSelected ? Colors.greenAccent.withOpacity(0.15) : const Color(0xFF00E5FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  onTap: () => _openEntity(entity),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          _buildEntityIcon(entity),
                                          if (isSelected)
                                            const Positioned(
                                              right: -2,
                                              bottom: -2,
                                              child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: isSelected ? Colors.greenAccent : Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (!isDir && sizeStr.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  sizeStr,
                                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ),
      ),
    );
  }
}
