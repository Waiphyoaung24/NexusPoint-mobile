import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../providers/auth_provider.dart';

/// Shows the manager PIN dialog and returns true if verified, false otherwise.
Future<bool> showPinDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PinDialog(),
  );
  return result ?? false;
}

class _PinDialog extends ConsumerStatefulWidget {
  const _PinDialog();

  @override
  ConsumerState<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends ConsumerState<_PinDialog> {
  static const int _pinLength = 4;
  final List<String> _digits = [];
  bool _isVerifying = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_digits.length >= _pinLength || _isVerifying) return;
    setState(() {
      _digits.add(digit);
      _errorMessage = null;
    });
    if (_digits.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_digits.isEmpty || _isVerifying) return;
    setState(() {
      _digits.removeLast();
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final pin = _digits.join();
    try {
      final authState = ref.read(authProvider);
      final user = authState.whenOrNull(
        authenticated: (user, _) => user,
        branchPending: (user, _) => user,
      );
      if (user == null) {
        setState(() {
          _digits.clear();
          _errorMessage = 'Not authenticated.';
          _isVerifying = false;
        });
        return;
      }
      final success =
          await ref.read(authProvider.notifier).verifyManagerPin(
                user.id,
                pin,
                user.branchId ?? '',
              );
      if (!mounted) return;
      if (success) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _digits.clear();
          _errorMessage = 'Incorrect PIN. Try again.';
          _isVerifying = false;
        });
      }
    } on PinLockoutException {
      if (!mounted) return;
      setState(() {
        _digits.clear();
        _errorMessage = 'Too many failed attempts. Access locked.';
        _isVerifying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _digits.clear();
        _errorMessage = 'Verification failed. Try again.';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Icon(
                Icons.lock_outline,
                size: 40,
                color: PosTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'Manager PIN',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Enter your 4-digit PIN to continue',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // PIN Dots
              _PinDots(filledCount: _digits.length, pinLength: _pinLength),

              // Error Message
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _errorMessage != null ? 32 : 0,
                child: _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PosTheme.dangerRed,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Numpad
              _isVerifying
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _Numpad(
                      onDigit: _onDigitPressed,
                      onBackspace: _onBackspace,
                    ),

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filledCount;
  final int pinLength;

  const _PinDots({required this.filledCount, required this.pinLength});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final filled = index < filledCount;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? PosTheme.primaryBlue : Colors.transparent,
            border: Border.all(
              color: filled ? PosTheme.primaryBlue : PosTheme.borderLight,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

class _Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _Numpad({required this.onDigit, required this.onBackspace});

  static const _layout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _layout.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 72, height: 52);
            return _NumpadKey(
              label: key,
              onTap: key == '⌫' ? null : () => onDigit(key),
              onBackspace: key == '⌫' ? onBackspace : null,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onBackspace;

  const _NumpadKey({
    required this.label,
    this.onTap,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isBackspace ? onBackspace : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 64,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PosTheme.borderLight),
              color: PosTheme.surfaceWhite,
            ),
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: PosTheme.textSecondary,
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
          ),
        ),
      ),
    );
  }
}
