import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderSource {
  @JsonValue('dinein')
  dinein,
  @JsonValue('grab')
  grab,
  @JsonValue('wongnai')
  wongnai,
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('promptpay')
  promptpay,
  @JsonValue('card')
  card,
}

double _parsePrice(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@freezed
class Order with _$Order {
  const factory Order({
    int? localId,
    String? orderId,
    required String orderNumber,
    required OrderSource source,
    required OrderStatus status,
    required List<CartItem> items,
    @JsonKey(fromJson: _parsePrice) required double totalAmount,
    required PaymentMethod paymentMethod,
    required DateTime createdAt,
    DateTime? syncedAt,
    @Default(false) bool isSynced,
    String? tableNumber,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}
