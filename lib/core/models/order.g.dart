// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      localId: (json['localId'] as num?)?.toInt(),
      orderId: json['orderId'] as String?,
      orderNumber: json['orderNumber'] as String,
      source: $enumDecode(_$OrderSourceEnumMap, json['source']),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: _parsePrice(json['totalAmount']),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      tableNumber: json['tableNumber'] as String?,
      tableId: json['tableId'] as String?,
      orderType: json['orderType'] as String?,
      createdBy: json['createdBy'] as String?,
      subtotalAmount: _parsePriceNullable(json['subtotalAmount']),
      vatAmount: _parsePriceNullable(json['vatAmount']),
      vatRate: _parsePriceNullable(json['vatRate']),
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'source': _$OrderSourceEnumMap[instance.source]!,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
      'tableNumber': instance.tableNumber,
      'tableId': instance.tableId,
      'orderType': instance.orderType,
      'createdBy': instance.createdBy,
      'subtotalAmount': instance.subtotalAmount,
      'vatAmount': instance.vatAmount,
      'vatRate': instance.vatRate,
    };

const _$OrderSourceEnumMap = {
  OrderSource.dinein: 'dinein',
  OrderSource.grab: 'grab',
  OrderSource.wongnai: 'wongnai',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.completed: 'completed',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.promptpay: 'promptpay',
  PaymentMethod.card: 'card',
};
