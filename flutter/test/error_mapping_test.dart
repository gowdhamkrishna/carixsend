import 'package:flutter_test/flutter_test.dart';
import 'package:carixsend_flutter/src/rust/frb_api.dart';
import 'package:carixsend_flutter/app/widgets/error_message.dart';

void main() {
  test('All 12 FrbTransferErrorCode variants map to non-empty user messages', () {
    for (final code in FrbTransferErrorCode.values) {
      final msg = getTransferErrorMessage(code);
      expect(msg, isNotEmpty);
      expect(msg, isNot(contains('null')));
    }
  });
}
