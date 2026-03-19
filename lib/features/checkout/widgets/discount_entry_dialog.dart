import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/pos_theme.dart';

/// Shows the discount entry dialog. Returns (percent, reason) or null if cancelled.
Future<({double percent, String? reason})?> showDiscountEntryDialog(
  BuildContext context, {
  required double subtotal,
}) async {
  return showDialog<({double percent, String? reason})>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DiscountEntryDialog(subtotal: subtotal),
  );
}

class _DiscountEntryDialog extends StatefulWidget {
  final double subtotal;
  const _DiscountEntryDialog({required this.subtotal});

  @override
  State<_DiscountEntryDialog> createState() => _DiscountEntryDialogState();
}

class _DiscountEntryDialogState extends State<_DiscountEntryDialog> {
  final _percentController = TextEditingController();
  final _reasonController = TextEditingController();
  double _percent = 0;
  String? _error;

  static const _presets = [5.0, 10.0, 15.0, 20.0];

  @override
  void dispose() {
    _percentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _selectPreset(double value) {
    setState(() {
      _percent = value;
      _percentController.text = value.toStringAsFixed(0);
      _error = null;
    });
  }

  void _onPercentChanged(String value) {
    final parsed = double.tryParse(value);
    setState(() {
      if (parsed == null || parsed <= 0) {
        _percent = 0;
        _error = 'Enter a value between 1 and 100';
      } else if (parsed > 100) {
        _percent = 0;
        _error = 'Cannot exceed 100%';
      } else {
        _percent = parsed;
        _error = null;
      }
    });
  }

  double get _discountAmount => widget.subtotal * (_percent / 100);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply Discount'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick preset chips
            Wrap(
              spacing: 8,
              children: _presets.map((p) {
                final selected = _percent == p;
                return ActionChip(
                  label: Text('${p.toStringAsFixed(0)}%'),
                  backgroundColor: selected
                      ? PosTheme.primaryBlue.withValues(alpha: 0.15)
                      : null,
                  side: selected
                      ? const BorderSide(color: PosTheme.primaryBlue)
                      : null,
                  onPressed: () => _selectPreset(p),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Custom percentage input
            TextFormField(
              controller: _percentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Discount %',
                suffixText: '%',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onChanged: _onPercentChanged,
            ),

            // Live preview
            if (_percent > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PosTheme.dangerRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PosTheme.dangerRed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_percent.toStringAsFixed(0)}% off \$${widget.subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '-\$${_discountAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PosTheme.dangerRed,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Optional reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g., Loyal customer, Manager discretion',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _percent > 0 && _percent <= 100
              ? () {
                  final reason = _reasonController.text.trim();
                  Navigator.of(context).pop((
                    percent: _percent,
                    reason: reason.isEmpty ? null : reason,
                  ));
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
