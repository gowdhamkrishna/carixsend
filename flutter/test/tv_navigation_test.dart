import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:carixsend_flutter/main.dart';
import 'package:carixsend_flutter/app/controllers/transfer_controller.dart';
import 'package:carixsend_flutter/app/screens/receive_screen.dart';
import 'transfer_controller_test.dart';

void main() {
  testWidgets('TV D-Pad Focus & Navigation flow test', (WidgetTester tester) async {
    final fakeRepo = FakeTransferRepository();
    final controller = TransferController(fakeRepo);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const CarixSendApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Send to TV app title and hero cards exist
    expect(find.text('Send to TV'), findsOneWidget);
    expect(find.text('SEND'), findsOneWidget);
    expect(find.text('RECEIVE'), findsOneWidget);

    // Tap SEND card to navigate to NewTransferScreen
    await tester.tap(find.text('SEND'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Send Files — Select Receiver'), findsOneWidget);

    // Tap AppBar Back button to return to home
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SEND'), findsOneWidget);

    // Tap RECEIVE card to navigate to ReceiveScreen
    await tester.tap(find.text('RECEIVE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ReceiveScreen), findsOneWidget);
    expect(find.text('Receive Files — Send to TV'), findsOneWidget);

    // Tap AppBar Back button to return to home
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SEND'), findsOneWidget);
  });
}
