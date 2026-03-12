import 'package:flutter/material.dart';
import '../../../core/theme/pos_theme.dart';

/// Renders a single restaurant table card with surrounding chair indicators.
///
/// Status → visual mapping:
///  available  → white bg, green border (#22C55E), checkmark icon
///  occupied   → blue-800 filled (#1E40AF), no border, clock icon + elapsed time
///  reserved   → amber-50 bg (#FFFBEB), amber-500 border, calendar icon + time
///  cleaning   → slate-50 bg (#F8FAFC), slate-300 border, "Cleaning" label
class TableWidget extends StatelessWidget {
  final int number;
  final int seats;
  final String shape; // 'rectangle' | 'round' | 'bar_stool'
  final String status; // 'available' | 'occupied' | 'reserved' | 'cleaning'
  final int? elapsedMinutes; // shown on occupied tables
  final String? reservationLabel; // shown on reserved tables (e.g. "8:30PM")
  final VoidCallback onTap;

  // Table card size (2×2 grid cells, each cell = canvas/24 or canvas/16)
  static const double cardWidth = 88.0;
  static const double cardHeight = 80.0;
  static const double chairSize = 10.0;
  static const double chairMargin = 3.0;

  const TableWidget({
    super.key,
    required this.number,
    required this.seats,
    required this.shape,
    required this.status,
    this.elapsedMinutes,
    this.reservationLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors();
    final isRound = shape == 'round';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth + chairSize * 2 + chairMargin * 4,
        height: cardHeight + chairSize * 2 + chairMargin * 4,
        child: Column(
          children: [
            // Top chairs
            _buildChairRow(colors.chairColor, isTopRow: true),
            Row(
              children: [
                // Left chairs
                _buildSideChairs(colors.chairColor),
                // Table card
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: colors.bgColor,
                    borderRadius: BorderRadius.circular(isRound ? 40 : 12),
                    border: colors.borderColor != null
                        ? Border.all(color: colors.borderColor!, width: 2.5)
                        : null,
                    boxShadow: [PosTheme.shadowSm],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Table number
                      Text(
                        'T-$number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status icon row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_statusIcon(), size: 14, color: colors.iconColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _statusSubLabel(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.iconColor,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right chairs
                _buildSideChairs(colors.chairColor),
              ],
            ),
            // Bottom chairs
            _buildChairRow(colors.chairColor, isTopRow: false),
          ],
        ),
      ),
    );
  }

  Widget _buildChairRow(Color color, {required bool isTopRow}) {
    final topChairs = (seats / 2).ceil();
    return Padding(
      padding: EdgeInsets.only(
        top: isTopRow ? 0 : chairMargin,
        bottom: isTopRow ? chairMargin : 0,
        left: chairSize + chairMargin * 2,
        right: chairSize + chairMargin * 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          topChairs.clamp(1, 4),
          (_) => _buildChair(color),
        ),
      ),
    );
  }

  Widget _buildSideChairs(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: chairMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_buildChair(color)],
      ),
    );
  }

  Widget _buildChair(Color color) => Container(
    width: chairSize,
    height: chairSize,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );

  String _statusSubLabel() {
    switch (status) {
      case 'occupied':
        return elapsedMinutes != null ? '${elapsedMinutes}m' : '—';
      case 'reserved':
        return reservationLabel ?? 'Reserved';
      case 'cleaning':
        return 'Cleaning';
      case 'available':
      default:
        return '$seats seats';
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'occupied':
        return Icons.access_time_rounded;
      case 'reserved':
        return Icons.event_available_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'available':
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  _TableColors _statusColors() {
    switch (status) {
      case 'occupied':
        return _TableColors(
          bgColor: const Color(0xFF1E40AF),
          borderColor: null,
          textColor: Colors.white,
          iconColor: const Color(0xFF93C5FD), // blue-300
          chairColor: const Color(0xFF93C5FD),
        );
      case 'reserved':
        return _TableColors(
          bgColor: const Color(0xFFFFFBEB), // amber-50
          borderColor: const Color(0xFFF59E0B), // amber-500
          textColor: const Color(0xFF92400E), // amber-900
          iconColor: const Color(0xFFF59E0B),
          chairColor: const Color(0xFFFCD34D), // amber-300
        );
      case 'cleaning':
        return _TableColors(
          bgColor: const Color(0xFFF8FAFC), // slate-50
          borderColor: const Color(0xFFCBD5E1), // slate-300
          textColor: const Color(0xFF64748B), // slate-500
          iconColor: const Color(0xFF94A3B8),
          chairColor: const Color(0xFFCBD5E1),
        );
      case 'available':
      default:
        return _TableColors(
          bgColor: Colors.white,
          borderColor: const Color(0xFF22C55E), // green-500
          textColor: const Color(0xFF1E3A8A), // blue-900
          iconColor: const Color(0xFF22C55E),
          chairColor: const Color(0xFF86EFAC), // green-300
        );
    }
  }
}

class _TableColors {
  final Color bgColor;
  final Color? borderColor;
  final Color textColor;
  final Color iconColor;
  final Color chairColor;

  const _TableColors({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.chairColor,
  });
}
