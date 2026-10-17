import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app/controllers/transfer_controller.dart';
import 'app/screens/home_screen.dart';
import 'app/services/transfer_repository.dart';
import 'src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await RustLib.init();

  final repo = const RustTransferRepository();
  final controller = TransferController(repo);

  // Auto-start receiver server so app is ready to receive transfers immediately
  try {
    await controller.startReceiverServer();
  } catch (_) {
    // Graceful fallback if port is busy
  }

  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const CarixSendApp(),
    ),
  );
}

class CarixSendApp extends StatelessWidget {
  const CarixSendApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.white;
    const neumorphicBase = Color(0xFF2A2D32);

    return MaterialApp(
      title: 'Send to TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: neumorphicBase,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: Colors.white54,
          surface: neumorphicBase,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: neumorphicBase,
          foregroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: neumorphicBase,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
