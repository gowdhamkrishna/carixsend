import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:carixsend_flutter/main.dart';
import 'package:carixsend_flutter/app/controllers/transfer_controller.dart';
import 'transfer_controller_test.dart';

void main() {
  testWidgets('CarixSendApp smoke test', (WidgetTester tester) async {
    final fakeRepo = FakeTransferRepository();
    final controller = TransferController(fakeRepo);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const CarixSendApp(),
      ),
    );
    expect(find.text('Send to TV'), findsOneWidget);
  });
}
