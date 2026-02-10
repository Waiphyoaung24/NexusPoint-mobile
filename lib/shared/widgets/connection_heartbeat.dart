import 'package:flutter/material.dart';
import '../../core/theme/pos_theme.dart';

enum ConnectionStatus {
  online,
  offline,
  syncing,
  error,
}

class ConnectionHeartbeat extends StatefulWidget {
  final ConnectionStatus status;

  const ConnectionHeartbeat({
    super.key,
    this.status = ConnectionStatus.online,
  });

  @override
  State<ConnectionHeartbeat> createState() => _ConnectionHeartbeatState();
}

class _ConnectionHeartbeatState extends State<ConnectionHeartbeat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.status == ConnectionStatus.online ||
        widget.status == ConnectionStatus.syncing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionHeartbeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == ConnectionStatus.online ||
          widget.status == ConnectionStatus.syncing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case ConnectionStatus.online:
        return PosTheme.statusOnline;
      case ConnectionStatus.offline:
        return PosTheme.statusOffline;
      case ConnectionStatus.syncing:
        return PosTheme.statusSyncing;
      case ConnectionStatus.error:
        return PosTheme.statusError;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case ConnectionStatus.online:
        return Icons.check_circle;
      case ConnectionStatus.offline:
        return Icons.cloud_off;
      case ConnectionStatus.syncing:
        return Icons.sync;
      case ConnectionStatus.error:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case ConnectionStatus.online:
        return 'Online';
      case ConnectionStatus.offline:
        return 'Offline';
      case ConnectionStatus.syncing:
        return 'Syncing';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final text = _getStatusText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// Sync Status Indicator for Order Cards
class SyncStatusIndicator extends StatelessWidget {
  final bool isSynced;
  final bool isSyncing;

  const SyncStatusIndicator({
    super.key,
    required this.isSynced,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(PosTheme.statusSyncing),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Syncing...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: PosTheme.statusSyncing,
                ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSynced ? Icons.cloud_done : Icons.cloud_queue,
          size: 12,
          color: isSynced ? PosTheme.statusOnline : PosTheme.statusOffline,
        ),
        const SizedBox(width: 4),
        Text(
          isSynced ? 'Synced' : 'Local',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    isSynced ? PosTheme.statusOnline : PosTheme.statusOffline,
              ),
        ),
      ],
    );
  }
}
