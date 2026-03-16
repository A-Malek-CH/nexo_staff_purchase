import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/admin_supplier_repository.dart';

final adminSupplierProvider =
    StateNotifierProvider<AdminSupplierNotifier, AdminSupplierState>((ref) {
  return AdminSupplierNotifier(ref.read(adminSupplierRepositoryProvider));
});

class AdminSupplierState {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  AdminSupplierState({
    this.suppliers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  AdminSupplierState copyWith({
    List<Supplier>? suppliers,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return AdminSupplierState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Supplier> get filteredSuppliers {
    if (searchQuery.isEmpty) return suppliers;
    final q = searchQuery.toLowerCase();
    return suppliers
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            (s.contactPerson?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}

class AdminSupplierNotifier extends StateNotifier<AdminSupplierState> {
  final AdminSupplierRepository _repo;

  AdminSupplierNotifier(this._repo) : super(AdminSupplierState());

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final suppliers = await _repo.getSuppliers();
      state = state.copyWith(suppliers: suppliers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createSupplier(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.createSupplier(data);
      await loadSuppliers();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateSupplier(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateSupplier(id, data);
      await loadSuppliers();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteSupplier(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteSupplier(id);
      await loadSuppliers();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void searchSupplier(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
