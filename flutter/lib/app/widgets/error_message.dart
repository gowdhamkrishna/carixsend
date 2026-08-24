import '../../src/rust/frb_api.dart';

String getTransferErrorMessage(FrbTransferErrorCode errorCode) {
  switch (errorCode) {
    case FrbTransferErrorCode.invalidConfiguration:
      return 'Invalid transfer configuration.';
    case FrbTransferErrorCode.connectionFailed:
      return 'Unable to connect to the receiver.';
    case FrbTransferErrorCode.connectionLost:
      return 'Connection was lost during transfer.';
    case FrbTransferErrorCode.timeout:
      return 'Transfer timed out.';
    case FrbTransferErrorCode.protocolError:
      return 'A protocol error occurred.';
    case FrbTransferErrorCode.fileReadFailed:
      return 'Could not read the source file.';
    case FrbTransferErrorCode.fileWriteFailed:
      return 'Could not write the destination file.';
    case FrbTransferErrorCode.resumeFailed:
      return 'Transfer could not be resumed.';
    case FrbTransferErrorCode.retryLimitExceeded:
      return 'Transfer could not be recovered after 3 attempts.';
    case FrbTransferErrorCode.integrityMismatch:
      return 'Transfer completed but file verification failed.';
    case FrbTransferErrorCode.cancelled:
      return 'Transfer was cancelled.';
    case FrbTransferErrorCode.unknown:
      return 'An unexpected error occurred.';
  }
}
