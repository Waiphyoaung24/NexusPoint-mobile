import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Shows a manager approval dialog with manager dropdown + 4-digit PIN.
/// Returns the approved manager's ID if verified, null if cancelled.
/// Supports both online (server) and offline (cached hash) verification.
Future<String?> showManagerApprovalDialog(
  BuildContext context, {
  required String branchId,
  required List<ManagerInfo> managers,
}) async {
  if (!context.mounted) return null;

  final result = await showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ManagerApprovalDialog(
      branchId: branchId,
      managers: managers,
    ),
  );

  return result;
}

class ManagerInfo {
  final String id;
  final String name;
  final String role;

  const ManagerInfo({
    required this.id,
    required this.name,
    required this.role,
  });
}

class _ManagerApprovalDialog extends ConsumerStatefulWidget {
  final String branchId;
  final List<ManagerInfo> managers;

  const _ManagerApprovalDialog({
    required this.branchId,
    required this.managers,
  });

  @override
  ConsumerState<_ManagerApprovalDialog> createState() =>
      _ManagerApprovalDialogState();
}

class _ManagerApprovalDialogState
    extends ConsumerState<_ManagerApprovalDialog> {
  String? _selectedManagerId;
  String _pin = '';
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.managers.length == 1) {
      _selectedManagerId = widget.managers.first.id;
    }
  }

  void _onDigitPressed(int digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit.toString();
        _errorMessage = null;
      });
      if (_pin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitPin() async {
    if (_selectedManagerId == null || _pin.length != 4) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final verified = await ref.read(authProvider.notifier).verifyManagerPin(
            _selectedManagerId!,
            _pin,
            widget.branchId,
          );

      if (verified && mounted) {
        Navigator.of(context).pop(_selectedManagerId);
      } else if (mounted) {
        setState(() {
          _pin = '';
          _errorMessage = 'Incorrect PIN';
          _isVerifying = false;
        });
      }
    } on PinLockoutException catch (e) {
      if (mounted) {
        setState(() {
          _pin = '';
          _errorMessage = e.message;
          _isVerifying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pin = '';
          _errorMessage = 'Verification failed. Try again.';
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manager Approval Required'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Manager dropdown
            DropdownButtonFormField<String>(
              value: _selectedManagerId,
              decoration: const InputDecoration(
                labelText: 'Select Manager',
                border: OutlineInputBorder(),
              ),
              items: widget.managers
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.name} (${m.role})'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedManagerId = value;
                  _pin = '';
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 24),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ),

            // Loading indicator
            if (_isVerifying)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(),
              ),

            // Numpad
            if (!_isVerifying) _buildNumpad(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (final row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map((digit) => _NumpadButton(
                      digit: digit,
                      onPressed: () => _onDigitPressed(digit),
                    ))
                .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 64),
            _NumpadButton(digit: 0, onPressed: () => _onDigitPressed(0)),
            SizedBox(
              width: 64,
              height: 64,
              child: IconButton(
                onPressed: _onBackspace,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final int digit;
  final VoidCallback onPressed;

  const _NumpadButton({required this.digit, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          '$digit',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
