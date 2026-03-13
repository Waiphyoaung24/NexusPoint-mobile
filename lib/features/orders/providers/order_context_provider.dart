import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_context_provider.freezed.dart';

enum OrderType { dineIn, takeaway, delivery }

@freezed
class OrderContext with _$OrderContext {
  const factory OrderContext({
    required OrderType orderType,
    String? tableId,
    int? tableNumber,
    String? ticketNumber,
    String? deliveryPlatform,
  }) = _OrderContext;
}

/// Holds the current order context (source type, table, etc.)
/// Set by OrderSetupScreen, consumed by checkout.
final orderContextProvider = StateProvider<OrderContext?>((ref) => null);
