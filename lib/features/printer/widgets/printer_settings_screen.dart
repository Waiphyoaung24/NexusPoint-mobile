import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../providers/printer_provider.dart';
import '../services/printer_service.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final printerState = ref.watch(printerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Printer Status
            _PrinterStatusCard(state: printerState),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                if (printerState.isConnected)
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(printerProvider.notifier)
                        .disconnectPrinter(),
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PosTheme.dangerRed,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label:
                        Text(_isScanning ? 'Scanning...' : 'Scan for Printers'),
                  ),
                const SizedBox(width: 12),
                if (printerState.isConnected)
                  OutlinedButton.icon(
                    onPressed: _printTestPage,
                    icon: const Icon(Icons.print),
                    label: const Text('Test Print'),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Error Message
            if (printerState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PosTheme.dangerRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PosTheme.dangerRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: PosTheme.dangerRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        printerState.errorMessage!,
                        style: const TextStyle(color: PosTheme.dangerRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Scan Results
            if (_scanResults.isNotEmpty) ...[
              Text(
                'Available Devices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _scanResults.length,
                  itemBuilder: (context, index) {
                    final result = _scanResults[index];
                    return _DeviceListTile(
                      result: result,
                      isConnecting: printerState.status ==
                              PrinterConnectionStatus.connecting &&
                          printerState.deviceId ==
                              result.device.remoteId.str,
                      onConnect: () => _connectToDevice(result.device),
                    );
                  },
                ),
              ),
            ] else if (!_isScanning && !printerState.isConnected) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_outlined,
                        size: 64,
                        color:
                            PosTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No printers found',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: PosTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Scan for Printers" to find nearby devices',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: PosTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      final results = await ref.read(printerProvider.notifier).scan();
      setState(() {
        _scanResults = results;
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await ref.read(printerProvider.notifier).connectToDevice(device);
  }

  Future<void> _printTestPage() async {
    try {
      final service = ref.read(printerServiceProvider);
      // Simple test: ESC @ (init) + "Test Print OK" + LF + cut
      final bytes = <int>[
        0x1B, 0x40, // ESC @ — Initialize
        ...('Test Print OK\n\n\n').codeUnits,
        0x1D, 0x56, 0x00, // GS V 0 — Full cut
      ];
      await service.writeBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test print sent!'),
            backgroundColor: PosTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: $e'),
            backgroundColor: PosTheme.dangerRed,
          ),
        );
      }
    }
  }
}

class _PrinterStatusCard extends StatelessWidget {
  final PrinterState state;

  const _PrinterStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isConnected ? PosTheme.successGreen : PosTheme.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isConnected
                    ? PosTheme.successGreen.withValues(alpha: 0.1)
                    : PosTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConnected ? Icons.print : Icons.print_disabled,
                color: isConnected
                    ? PosTheme.successGreen
                    : PosTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.deviceName ?? 'No printer connected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected
                        ? 'Connected — ${state.deviceId}'
                        : _statusText(state.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isConnected
                              ? PosTheme.successGreen
                              : PosTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? PosTheme.successGreen
                    : PosTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(PrinterConnectionStatus status) {
    switch (status) {
      case PrinterConnectionStatus.disconnected:
        return 'Disconnected';
      case PrinterConnectionStatus.scanning:
        return 'Scanning...';
      case PrinterConnectionStatus.connecting:
        return 'Connecting...';
      case PrinterConnectionStatus.connected:
        return 'Connected';
      case PrinterConnectionStatus.error:
        return 'Error';
    }
  }
}

class _DeviceListTile extends StatelessWidget {
  final ScanResult result;
  final bool isConnecting;
  final VoidCallback onConnect;

  const _DeviceListTile({
    required this.result,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : 'Unknown Device';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: PosTheme.borderLight),
      ),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: PosTheme.primaryBlue),
        title: Text(name),
        subtitle: Text(
          '${result.device.remoteId} • RSSI: ${result.rssi}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: onConnect,
                child: const Text('Connect'),
              ),
      ),
    );
  }
}
