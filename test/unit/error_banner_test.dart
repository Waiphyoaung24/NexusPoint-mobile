import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/shared/widgets/error_banner.dart';

void main() {
  group('ErrorBannerNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no error', () {
      final state = container.read(errorBannerProvider);
      expect(state.hasError, false);
      expect(state.message, isNull);
    });

    test('showError sets message', () {
      container.read(errorBannerProvider.notifier).showError('Network error');

      final state = container.read(errorBannerProvider);
      expect(state.hasError, true);
      expect(state.message, 'Network error');
      expect(state.isCritical, false);
    });

    test('showError with critical flag', () {
      container
          .read(errorBannerProvider.notifier)
          .showError('Auth failed', isCritical: true);

      final state = container.read(errorBannerProvider);
      expect(state.isCritical, true);
    });

    test('showError with retry callback', () {
      var retried = false;
      container.read(errorBannerProvider.notifier).showError(
            'Failed',
            onRetry: () => retried = true,
          );

      final state = container.read(errorBannerProvider);
      expect(state.onRetry, isNotNull);
      state.onRetry!();
      expect(retried, true);
    });

    test('dismiss clears error', () {
      container.read(errorBannerProvider.notifier).showError('Error');
      container.read(errorBannerProvider.notifier).dismiss();

      final state = container.read(errorBannerProvider);
      expect(state.hasError, false);
      expect(state.message, isNull);
    });
  });
}
