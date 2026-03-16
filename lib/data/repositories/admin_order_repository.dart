import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/order_stats_model.dart';
import '../services/admin_order_service.dart';

final adminOrderRepositoryProvider = Provider<AdminOrderRepository>((ref) {
  return AdminOrderRepository(ref.read(adminOrderServiceProvider));
});

class AdminOrderRepository {
  final AdminOrderService _service;

  AdminOrderRepository(this._service);

  Future<List<Order>> getAllOrders({
    String? status,
    String? supplierId,
    int page = 1,
    int limit = 20,
  }) async {
    return _service.getAllOrders(
      status: status,
      supplierId: supplierId,
      page: page,
      limit: limit,
    );
  }

  Future<Order> getOrderById(String id) async {
    return _service.getOrderById(id);
  }

  Future<Order> createOrder(Map<String, dynamic> data) async {
    return _service.createOrder(data);
  }

  Future<Order> updateOrder(String id, Map<String, dynamic> data) async {
    return _service.updateOrder(id, data);
  }

  Future<OrderStats> getOrderStats() async {
    return _service.getOrderStats();
  }

  Future<void> confirmPayment(String id, {File? billFile, String? notes}) async {
    return _service.confirmPayment(id, billFile: billFile, notes: notes);
  }
}
