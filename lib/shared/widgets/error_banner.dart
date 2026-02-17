import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pos_theme.dart';

/// Global error state provider.
final errorBannerProvider =
    StateNotifierProvider<ErrorBannerNotifier, ErrorBannerState>((ref) {
  return ErrorBannerNotifier();
});

/// Error banner state.
class ErrorBannerState {
  final String? message;
  final bool isCritical;
  final VoidCallback? onRetry;

  const ErrorBannerState({
    this.message,
    this.isCritical = false,
    this.onRetry,
  });

  bool get hasError => message != null;
}

/// Manages global error banner state.
class ErrorBannerNotifier extends StateNotifier<ErrorBannerState> {
  ErrorBannerNotifier() : super(const ErrorBannerState());

  void showError(String message, {bool isCritical = false, VoidCallback? onRetry}) {
    state = ErrorBannerState(
      message: message,
      isCritical: isCritical,
      onRetry: onRetry,
    );
  }

  void dismiss() {
    state = const ErrorBannerState();
  }
}

/// A global error banner widget that displays at the top of the screen.
class ErrorBanner extends ConsumerWidget {
  const ErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorState = ref.watch(errorBannerProvider);

    if (!errorState.hasError) return const SizedBox.shrink();

    return MaterialBanner(
      backgroundColor:
          errorState.isCritical ? PosTheme.dangerRed : Colors.orange,
      content: Row(
        children: [
          Icon(
            errorState.isCritical ? Icons.error : Icons.warning_amber,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorState.message!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        if (errorState.onRetry != null)
          TextButton(
            onPressed: () {
              ref.read(errorBannerProvider.notifier).dismiss();
              errorState.onRetry?.call();
            },
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        TextButton(
          onPressed: () => ref.read(errorBannerProvider.notifier).dismiss(),
          child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
