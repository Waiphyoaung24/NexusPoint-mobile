import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import 'table_widget.dart';

/// Free-canvas floor plan rendered from grid coordinates.
///
/// Grid: 24 columns × 16 rows.
/// Each cell = canvasWidth/24 wide × canvasHeight/16 tall.
/// Table is positioned at: left = positionX * cellW, top = positionY * cellH
class FloorPlanCanvas extends StatelessWidget {
  final List<LocalTable> tables;
  final void Function(LocalTable table) onTableTap;

  // Canvas logical size (fixed ratio 24:16 = 3:2)
  static const double canvasWidth = 960.0;
  static const double canvasHeight = 640.0;
  static const int gridCols = 24;
  static const int gridRows = 16;

  const FloorPlanCanvas({
    super.key,
    required this.tables,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    final cellW = canvasWidth / gridCols; // 40px per column
    final cellH = canvasHeight / gridRows; // 40px per row

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 2.5,
      child: SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          children: [
            // Subtle grid background
            CustomPaint(
              size: const Size(canvasWidth, canvasHeight),
              painter: _GridPainter(cellW: cellW, cellH: cellH),
            ),
            // Table widgets positioned by grid coordinates
            ...tables.map((table) => Positioned(
              left: table.positionX * cellW - TableWidget.cardWidth / 2,
              top: table.positionY * cellH - TableWidget.cardHeight / 2,
              child: TableWidget(
                number: table.number,
                seats: table.seats,
                shape: table.shape,
                status: table.status,
                onTap: () => onTableTap(table),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Paints a subtle dotted grid on the canvas background.
class _GridPainter extends CustomPainter {
  final double cellW;
  final double cellH;

  const _GridPainter({required this.cellW, required this.cellH});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0) // slate-200
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (double x = 0; x <= size.width; x += cellW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y <= size.height; y += cellH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
