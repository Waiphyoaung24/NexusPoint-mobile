import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/modifier_dao.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/menu_item.dart';
import '../../cart/providers/cart_provider.dart';

class ModifierPickerSheet extends ConsumerStatefulWidget {
  final MenuItem menuItem;
  final List<ModifierGroupWithOptions> modifierGroups;

  const ModifierPickerSheet({
    super.key,
    required this.menuItem,
    required this.modifierGroups,
  });

  @override
  ConsumerState<ModifierPickerSheet> createState() =>
      _ModifierPickerSheetState();
}

class _ModifierPickerSheetState extends ConsumerState<ModifierPickerSheet> {
  // groupId -> set of selected optionIds
  final Map<String, Set<String>> _selections = {};

  @override
  void initState() {
    super.initState();
    // Pre-select defaults
    for (final group in widget.modifierGroups) {
      final defaults = group.options
          .where((o) => o.isDefault)
          .map((o) => o.id)
          .toSet();
      if (defaults.isNotEmpty) {
        _selections[group.group.id] = defaults;
      }
    }
  }

  bool get _canAddToCart {
    for (final group in widget.modifierGroups) {
      if (!group.group.isRequired) continue;
      final selected = _selections[group.group.id] ?? {};
      final min = group.group.minSelections ?? 1;
      if (selected.length < min) return false;
    }
    return true;
  }

  double get _modifierTotal {
    double total = 0;
    for (final group in widget.modifierGroups) {
      final selected = _selections[group.group.id] ?? {};
      for (final option in group.options) {
        if (selected.contains(option.id)) {
          total += option.priceAdjustment;
        }
      }
    }
    return total;
  }

  void _toggleOption(ModifierGroupWithOptions group, String optionId) {
    setState(() {
      final groupId = group.group.id;
      final max = group.group.maxSelections ?? 1;
      final current = {...(_selections[groupId] ?? {})};

      if (current.contains(optionId)) {
        // Deselect (only if not required with exactly 1 selection left)
        final min = group.group.minSelections ?? (group.group.isRequired ? 1 : 0);
        if (current.length > min) {
          current.remove(optionId);
        }
      } else {
        if (max == 1) {
          // Single select — replace
          current
            ..clear()
            ..add(optionId);
        } else if (current.length < max) {
          current.add(optionId);
        }
      }
      _selections[groupId] = current;
    });
  }

  List<SelectedModifierOption> get _buildSelectedModifiers {
    final result = <SelectedModifierOption>[];
    for (final group in widget.modifierGroups) {
      final selected = _selections[group.group.id] ?? {};
      for (final option in group.options) {
        if (selected.contains(option.id)) {
          result.add(SelectedModifierOption(
            optionId: option.id,
            groupId: group.group.id,
            groupName: group.group.name,
            name: option.name,
            priceAdjustment: option.priceAdjustment,
          ));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = widget.menuItem.price + _modifierTotal;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.menuItem.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '฿${widget.menuItem.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Modifier groups
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.modifierGroups.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final group = widget.modifierGroups[index];
                  return _buildGroup(context, group);
                },
              ),
            ),

            // Add to Cart button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _canAddToCart
                        ? () {
                            ref.read(cartProvider.notifier).addItem(
                                  widget.menuItem,
                                  selectedModifiers: _buildSelectedModifiers,
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${widget.menuItem.name}'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Add to Cart  •  ฿${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroup(BuildContext context, ModifierGroupWithOptions group) {
    final theme = Theme.of(context);
    final selected = _selections[group.group.id] ?? {};
    final isMultiSelect = (group.group.maxSelections ?? 1) > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Row(
            children: [
              Text(
                group.group.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (group.group.isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              if (isMultiSelect) ...[
                const SizedBox(width: 8),
                Text(
                  'Pick up to ${group.group.maxSelections}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black45,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Options
          ...group.options.map((option) {
            final isSelected = selected.contains(option.id);
            return _buildOptionTile(
              context,
              option: option,
              isSelected: isSelected,
              isMultiSelect: isMultiSelect,
              onTap: () => _toggleOption(group, option.id),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required dynamic option,
    required bool isSelected,
    required bool isMultiSelect,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Checkbox or Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.black26,
                  width: 2,
                ),
                borderRadius: isMultiSelect
                    ? BorderRadius.circular(4)
                    : BorderRadius.circular(11),
              ),
              child: isSelected
                  ? Icon(
                      isMultiSelect ? Icons.check : Icons.circle,
                      size: isMultiSelect ? 14 : 10,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Text(
                option.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),

            // Price adjustment
            if (option.priceAdjustment != 0)
              Text(
                option.priceAdjustment > 0
                    ? '+฿${option.priceAdjustment.toStringAsFixed(2)}'
                    : '-฿${option.priceAdjustment.abs().toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: option.priceAdjustment > 0
                      ? Colors.black54
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
