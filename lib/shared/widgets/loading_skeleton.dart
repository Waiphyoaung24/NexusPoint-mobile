import 'package:flutter/material.dart';
import '../../core/theme/pos_theme.dart';

/// A shimmer-style loading skeleton for grid items.
class MenuGridSkeleton extends StatefulWidget {
  final int itemCount;
  final int crossAxisCount;

  const MenuGridSkeleton({
    super.key,
    this.itemCount = 8,
    this.crossAxisCount = 3,
  });

  @override
  State<MenuGridSkeleton> createState() => _MenuGridSkeletonState();
}

class _MenuGridSkeletonState extends State<MenuGridSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return _SkeletonCard(opacity: _animation.value);
            },
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;

  const _SkeletonCard({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: PosTheme.borderLight.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title placeholder
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PosTheme.borderLight.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Price placeholder
            Container(
              height: 14,
              width: 60,
              decoration: BoxDecoration(
                color: PosTheme.borderLight.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
