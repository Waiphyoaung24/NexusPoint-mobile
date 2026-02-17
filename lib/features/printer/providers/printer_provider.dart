import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/printer_service.dart';

/// Riverpod provider for the printer service singleton.
final printerServiceProvider = Provider<PrinterService>((ref) {
  final service = PrinterService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Riverpod provider for the printer connection state.
final printerProvider =
    StateNotifierProvider<PrinterNotifier, PrinterState>((ref) {
  return PrinterNotifier(ref.read(printerServiceProvider));
});

/// Manages printer connection state and exposes scan/connect/disconnect.
class PrinterNotifier extends StateNotifier<PrinterState> {
  final PrinterService _service;

  PrinterNotifier(this._service) : super(const PrinterState()) {
    _loadSavedPrinter();
  }

  /// Load saved printer info (does NOT auto-connect).
  Future<void> _loadSavedPrinter() async {
    try {
      final saved = await PrinterService.loadSavedPrinter();
      if (saved.id != null && saved.name != null) {
        state = state.copyWith(
          deviceName: saved.name,
          deviceId: saved.id,
        );
      }
    } catch (e) {
      debugPrint('Failed to load saved printer: $e');
    }
  }

  /// Scan for nearby Bluetooth printers.
  Future<List<ScanResult>> scan() async {
    state = state.copyWith(status: PrinterConnectionStatus.scanning);
    try {
      final results = await _service.scanForPrinters();
      state = state.copyWith(status: PrinterConnectionStatus.disconnected);
      return results;
    } catch (e) {
      state = state.copyWith(
        status: PrinterConnectionStatus.error,
        errorMessage: 'Scan failed: $e',
      );
      return [];
    }
  }

  /// Connect to a specific Bluetooth device.
  Future<void> connectToDevice(BluetoothDevice device) async {
    state = state.copyWith(
      status: PrinterConnectionStatus.connecting,
      deviceName: device.platformName,
      deviceId: device.remoteId.str,
    );

    try {
      await _service.connect(device);
      state = state.copyWith(
        status: PrinterConnectionStatus.connected,
        deviceName: device.platformName,
        deviceId: device.remoteId.str,
      );
    } catch (e) {
      state = state.copyWith(
        status: PrinterConnectionStatus.error,
        errorMessage: 'Connection failed: $e',
      );
    }
  }

  /// Disconnect from the current printer.
  Future<void> disconnectPrinter() async {
    await _service.disconnect();
    await PrinterService.clearSavedPrinter();
    state = const PrinterState();
  }

  /// Queue a print job.
  void enqueueJob(PrintJob job) {
    _service.enqueueJob(job);
  }
}
