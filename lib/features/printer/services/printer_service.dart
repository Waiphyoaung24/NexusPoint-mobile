import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connection status for the thermal printer.
enum PrinterConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Type of print job.
enum PrintJobType {
  receipt,
  kitchenTicket,
}

/// A queued print job.
class PrintJob {
  final PrintJobType type;
  final List<int> data;
  final String? orderNumber;
  final DateTime createdAt;

  PrintJob({
    required this.type,
    required this.data,
    this.orderNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// State for the printer connection.
class PrinterState {
  final PrinterConnectionStatus status;
  final String? deviceName;
  final String? deviceId;
  final String? errorMessage;

  const PrinterState({
    this.status = PrinterConnectionStatus.disconnected,
    this.deviceName,
    this.deviceId,
    this.errorMessage,
  });

  bool get isConnected => status == PrinterConnectionStatus.connected;

  PrinterState copyWith({
    PrinterConnectionStatus? status,
    String? deviceName,
    String? deviceId,
    String? errorMessage,
  }) {
    return PrinterState(
      status: status ?? this.status,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      errorMessage: errorMessage,
    );
  }
}

/// Service that manages Bluetooth thermal printer connections and printing.
class PrinterService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription? _connectionSubscription;
  final List<PrintJob> _printQueue = [];
  bool _isPrinting = false;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<PrintJob> get printQueue => List.unmodifiable(_printQueue);

  /// Scan for nearby Bluetooth devices.
  /// Returns a stream of scan results.
  Future<List<ScanResult>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Stop any existing scan
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final results = <ScanResult>[];

    final subscription = FlutterBluePlus.onScanResults.listen((scanResults) {
      for (final r in scanResults) {
        // Filter for likely printers (devices with names)
        if (r.advertisementData.advName.isNotEmpty) {
          final exists = results.any(
            (existing) => existing.device.remoteId == r.device.remoteId,
          );
          if (!exists) {
            results.add(r);
          }
        }
      }
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.startScan(timeout: timeout);

    // Wait for scan to complete
    await FlutterBluePlus.isScanning
        .where((scanning) => scanning == false)
        .first;

    return results;
  }

  /// Connect to a Bluetooth printer device.
  Future<void> connect(BluetoothDevice device) async {
    try {
      // Listen for disconnection
      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen(
        (BluetoothConnectionState state) {
          if (state == BluetoothConnectionState.disconnected) {
            debugPrint(
              'Printer disconnected: '
              '${device.disconnectReason?.code} '
              '${device.disconnectReason?.description}',
            );
            _connectedDevice = null;
            _writeCharacteristic = null;
          }
        },
      );

      // Connect with timeout
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;

      // Discover services to find write characteristic
      final services = await device.discoverServices();
      _writeCharacteristic = _findWriteCharacteristic(services);

      if (_writeCharacteristic == null) {
        debugPrint('No write characteristic found, will use direct write');
      }

      // Save as last connected printer
      await _savePrinterPreference(device);

      debugPrint('Connected to printer: ${device.platformName}');

      // Process any queued print jobs
      await _processQueue();
    } catch (e) {
      _connectedDevice = null;
      _writeCharacteristic = null;
      rethrow;
    }
  }

  /// Disconnect from the current printer.
  Future<void> disconnect() async {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('Error disconnecting: $e');
      }
    }

    _connectedDevice = null;
    _writeCharacteristic = null;
  }

  /// Send raw bytes to the printer.
  Future<void> writeBytes(List<int> bytes) async {
    if (_connectedDevice == null || !_connectedDevice!.isConnected) {
      throw PrinterNotConnectedException();
    }

    final data = Uint8List.fromList(bytes);

    if (_writeCharacteristic != null) {
      // Write in chunks to avoid BLE buffer overflow
      final mtu = _connectedDevice!.mtuNow - 3;
      final chunkSize = mtu > 0 ? mtu : 20;

      for (var i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final chunk = data.sublist(i, end);
        await _writeCharacteristic!.write(chunk.toList(), withoutResponse: false);
      }
    }
  }

  /// Add a print job to the queue. If connected, process immediately.
  void enqueueJob(PrintJob job) {
    _printQueue.add(job);
    if (_connectedDevice != null && _connectedDevice!.isConnected) {
      _processQueue();
    }
  }

  /// Process all queued print jobs.
  Future<void> _processQueue() async {
    if (_isPrinting || _printQueue.isEmpty) return;
    if (_connectedDevice == null || !_connectedDevice!.isConnected) return;

    _isPrinting = true;

    try {
      while (_printQueue.isNotEmpty) {
        final job = _printQueue.removeAt(0);
        try {
          await writeBytes(job.data);
          debugPrint('Printed ${job.type.name}: ${job.orderNumber}');
        } catch (e) {
          debugPrint('Print failed for ${job.orderNumber}: $e');
          // Re-queue failed job at the front
          _printQueue.insert(0, job);
          break;
        }
      }
    } finally {
      _isPrinting = false;
    }
  }

  /// Find a writable characteristic from discovered services.
  BluetoothCharacteristic? _findWriteCharacteristic(
    List<BluetoothService> services,
  ) {
    for (final service in services) {
      for (final char in service.characteristics) {
        if (char.properties.write || char.properties.writeWithoutResponse) {
          return char;
        }
      }
    }
    return null;
  }

  /// Save the connected printer info to SharedPreferences.
  Future<void> _savePrinterPreference(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paired_printer_id', device.remoteId.str);
    await prefs.setString('paired_printer_name', device.platformName);
  }

  /// Load the previously paired printer info.
  static Future<({String? id, String? name})> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      id: prefs.getString('paired_printer_id'),
      name: prefs.getString('paired_printer_name'),
    );
  }

  /// Clear saved printer preference.
  static Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paired_printer_id');
    await prefs.remove('paired_printer_name');
  }

  /// Dispose of resources.
  void dispose() {
    _connectionSubscription?.cancel();
    _printQueue.clear();
  }
}

/// Exception thrown when attempting to print without a connected printer.
class PrinterNotConnectedException implements Exception {
  final String message;
  PrinterNotConnectedException([this.message = 'Printer not connected']);

  @override
  String toString() => 'PrinterNotConnectedException: $message';
}
