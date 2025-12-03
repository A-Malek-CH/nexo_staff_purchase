import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../core/constants/app_constants.dart';

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.read(orderRepositoryProvider));
});

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final String? selectedStatus;

  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    String? selectedStatus,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  List<Order> get todayOrders {
    final now = DateTime.now();
    return orders.where((order) {
      final expectedDate = order.expectedDate;
      if (expectedDate == null) return false;
      return expectedDate.year == now.year &&
          expectedDate.month == now.month &&
          expectedDate.day == now.day;
    }).toList();
  }

  List<Order> get assignedOrders {
    return orders.where((order) => 
      order.status == AppConstants.orderStatusAssigned
    ).toList();
  }

  List<Order> get overdueOrders {
    final now = DateTime.now();
    return orders.where((order) {
      final expectedDate = order.expectedDate;
      if (expectedDate == null) return false;
      return expectedDate.isBefore(now) && 
             order.status == AppConstants.orderStatusAssigned;
    }).toList();
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepository _orderRepository;

  OrdersNotifier(this._orderRepository) : super(OrdersState());

  Future<void> loadOrders({String? status}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedStatus: status,
    );

    try {
      final orders = await _orderRepository.getMyOrders(
        status: status ?? AppConstants.orderStatusAssigned,
      );
      state = state.copyWith(
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders(
      status: state.selectedStatus,
    );
  }

  Future<void> submitOrderForReview(String orderId, String? notes) async {
    try {
      final updatedOrder = await _orderRepository.submitOrderForReview(orderId, notes);
      
      // Update the order in the list
      final updatedOrders = state.orders.map((order) {
        return order.id == orderId ? updatedOrder : order;
      }).toList();
      
      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearFilters() {
    state = state.copyWith(
      selectedStatus: null,
    );
    loadOrders(status: AppConstants.orderStatusAssigned);
  }
}
