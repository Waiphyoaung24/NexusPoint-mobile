import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/features/printer/services/printer_service.dart';
import 'package:nexuspoint_pos/features/printer/providers/printer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PrinterState', () {
    test('initial state is disconnected with no device', () {
      const state = PrinterState();
      expect(state.status, PrinterConnectionStatus.disconnected);
      expect(state.deviceName, isNull);
      expect(state.deviceId, isNull);
      expect(state.isConnected, false);
    });

    test('connected state reports isConnected true', () {
      const state = PrinterState(
        status: PrinterConnectionStatus.connected,
        deviceName: 'Test Printer',
        deviceId: 'AA:BB:CC:DD:EE:FF',
      );
      expect(state.isConnected, true);
      expect(state.deviceName, 'Test Printer');
    });

    test('scanning state is not connected', () {
      const state = PrinterState(status: PrinterConnectionStatus.scanning);
      expect(state.isConnected, false);
    });

    test('connecting state is not connected', () {
      const state = PrinterState(status: PrinterConnectionStatus.connecting);
      expect(state.isConnected, false);
    });

    test('error state preserves error message', () {
      const state = PrinterState(
        status: PrinterConnectionStatus.error,
        errorMessage: 'Connection failed',
      );
      expect(state.isConnected, false);
      expect(state.errorMessage, 'Connection failed');
    });
  });

  group('PrintJob', () {
    test('creates receipt print job', () {
      final job = PrintJob(
        type: PrintJobType.receipt,
        data: [0x1B, 0x40],
        orderNumber: 'ORD-20260217-120000',
      );
      expect(job.type, PrintJobType.receipt);
      expect(job.data, [0x1B, 0x40]);
      expect(job.orderNumber, 'ORD-20260217-120000');
    });

    test('creates kitchen ticket print job', () {
      final job = PrintJob(
        type: PrintJobType.kitchenTicket,
        data: [0x1B, 0x40],
        orderNumber: 'ORD-20260217-120000',
      );
      expect(job.type, PrintJobType.kitchenTicket);
    });
  });

  group('PrinterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is disconnected', () {
      final state = container.read(printerProvider);
      expect(state.status, PrinterConnectionStatus.disconnected);
    });
  });
}
