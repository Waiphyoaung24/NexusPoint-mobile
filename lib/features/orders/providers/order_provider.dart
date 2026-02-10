import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order.dart';
import '../repositories/order_repository.dart';

final ordersProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchAllOrders();
});
