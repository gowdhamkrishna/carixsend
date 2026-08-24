import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../src/rust/frb_api.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/transfer_card.dart';
import '../widgets/tv_focusable.dart';
import 'new_transfer_screen.dart';
import 'receive_screen.dart';
import 'settings_screen.dart';
import 'transfer_detail_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/secrets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _intentDataStreamSubscription;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _bannerAd = BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[Ad] Banner loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[Ad] Banner failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();

    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      _handleSharedFiles(value);
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFiles(value);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleSharedFiles(List<SharedMediaFile> sharedFiles) {
    if (sharedFiles.isEmpty) return;
    
    final platformFiles = <PlatformFile>[];
    for (var f in sharedFiles) {
      int size = 0;
      try {
        size = File(f.path).lengthSync();
      } catch (_) {}
      platformFiles.add(PlatformFile(
        name: f.path.split('/').last,
        path: f.path,
        size: size,
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewTransferScreen(initialFiles: platformFiles)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransferController>(context);
    final transfers = controller.transferList;
    final theme = Theme.of(context);
    final isServerRunning = controller.isServerRunning;
    final deviceName = controller.deviceName;

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Scaffold(
        bottomNavigationBar: _isAdLoaded && _bannerAd != null
            ? Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                color: const Color(0xFF1D1D1D),
                alignment: Alignment.center,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              )
            : null,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Send to TV',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isServerRunning ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isServerRunning ? deviceName : 'Receiver Off',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isServerRunning ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Hero Action Section: SEND, RECEIVE and BROWSE
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      return isWide
                          ? Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildSendTile(context, theme, autofocus: true),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReceiveTile(context, theme, isServerRunning, deviceName),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                              ],
                            )
                          : Column(
                              children: [
                                _buildSendTile(context, theme, autofocus: true),
                                const SizedBox(height: 16),
                                _buildReceiveTile(context, theme, isServerRunning, deviceName),
                                const SizedBox(height: 16),
                              
                              ],
                            );
                    },
                  ),
                ),
              ),

              // Recent Transfers Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transfers',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (transfers.isNotEmpty)
                        Text(
                          '${transfers.length} item(s)',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                ),
              ),

              // Transfers List or Empty View
              if (transfers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_vert_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No active transfers',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select SEND to send files or RECEIVE to accept incoming transfers',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = transfers[index];
                      return TransferCard(
                        transfer: item,
                        onAccept: item.isIncoming && item.status == FrbTransferStatus.queued
                            ? () => controller.decideIncomingTransfer(item.id, accept: true)
                            : null,
                        onReject: item.isIncoming && item.status == FrbTransferStatus.queued
                            ? () => controller.decideIncomingTransfer(item.id, accept: false)
                            : null,
                        onCancel: item.isIncoming && item.status == FrbTransferStatus.queued
                            ? null
                            : () => controller.cancelTransfer(item.id),
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
                    childCount: transfers.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendTile(BuildContext context, ThemeData theme, {bool autofocus = false}) {
    const sendColor = Colors.white;

    return TVFocusableCard(
      autofocus: autofocus,
      focusBorderColor: sendColor,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewTransferScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF2C2C2C),
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
                child: const Icon(Icons.upload_rounded, size: 36, color: sendColor),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: sendColor),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'SEND',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: sendColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Send files to TV, phone, or tablet on your LAN',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveTile(
    BuildContext context,
    ThemeData theme,
    bool isServerRunning,
    String deviceName,
  ) {
    const receiveColor = Colors.white;

    return TVFocusableCard(
      focusBorderColor: receiveColor,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReceiveScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF2C2C2C),
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
                child: const Icon(Icons.download_rounded, size: 36, color: receiveColor),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: receiveColor),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'RECEIVE',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: receiveColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isServerRunning
                ? 'Ready as $deviceName'
                : 'Tap to start receiver listening mode',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isServerRunning ? receiveColor : Colors.grey.shade400,
              fontWeight: isServerRunning ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
 
}
