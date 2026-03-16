import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_stats_model.dart';
import '../../data/repositories/admin_order_repository.dart';

final adminOrderProvider =
    StateNotifierProvider<AdminOrderNotifier, AdminOrderState>((ref) {
  return AdminOrderNotifier(ref.read(adminOrderRepositoryProvider));
});

class AdminOrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final String? selectedStatus;
  final OrderStats? stats;

  AdminOrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
    this.stats,
  });

  AdminOrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    String? selectedStatus,
    OrderStats? stats,
  }) {
    return AdminOrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      stats: stats ?? this.stats,
    );
  }
}

class AdminOrderNotifier extends StateNotifier<AdminOrderState> {
  final AdminOrderRepository _repo;

  AdminOrderNotifier(this._repo) : super(AdminOrderState());

  Future<void> loadOrders({String? status}) async {
    state = state.copyWith(isLoading: true, error: null, selectedStatus: status);
    try {
      final orders = await _repo.getAllOrders(status: status);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _repo.getOrderStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Stats load failure is non-critical
    }
  }

  Future<void> createOrder(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.createOrder(data);
      await loadOrders(status: state.selectedStatus);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateOrder(id, data);
      await loadOrders(status: state.selectedStatus);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> filterByStatus(String? status) async {
    await loadOrders(status: status);
  }

  Future<void> confirmPayment(String id, {File? billFile, String? notes}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.confirmPayment(id, billFile: billFile, notes: notes);
      await loadOrders(status: state.selectedStatus);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
