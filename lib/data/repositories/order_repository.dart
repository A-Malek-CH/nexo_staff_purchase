import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../../core/constants/app_constants.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(orderServiceProvider));
});

class OrderRepository {
  final OrderService _orderService;

  OrderRepository(this._orderService);

  /// Get orders assigned to the logged-in staff
  Future<List<Order>> getMyOrders({
    String? status,
    int page = 1,
  }) async {
    return await _orderService.getMyOrders(
      status: status,
      page: page,
    );
  }

  /// Get single order details by ID
  Future<Order> getOrderById(String id) async {
    return await _orderService.getOrderById(id);
  }

  /// Submit order for review with image proof
  Future<void> submitOrderForReview(
    String orderId, 
    File imageFile, 
    String? notes, {
    Map<String, int>? editedQuantities,
    Map<String, double>? editedPrices,
  }) async {
    return await _orderService.submitOrderForReview(
      orderId, 
      imageFile, 
      notes,
      editedQuantities: editedQuantities,
      editedPrices: editedPrices,
    );
  }

  /// Filter today's orders
  List<Order> filterTodayOrders(List<Order> orders) {
    final now = DateTime.now();
    return orders.where((order) {
      final expectedDate = order.expectedDate;
      if (expectedDate == null) return false;
      return expectedDate.year == now.year &&
          expectedDate.month == now.month &&
          expectedDate.day == now.day;
    }).toList();
  }

  /// Filter assigned orders (orders staff can work on)
  List<Order> filterAssignedOrders(List<Order> orders) {
    return orders.where((order) => 
      order.status == AppConstants.orderStatusAssigned
    ).toList();
  }

  /// Filter overdue orders
  List<Order> filterOverdueOrders(List<Order> orders) {
    final now = DateTime.now();
    return orders.where((order) {
      final expectedDate = order.expectedDate;
      if (expectedDate == null) return false;
      return expectedDate.isBefore(now) && 
             order.status == AppConstants.orderStatusAssigned;
    }).toList();
  }
}
