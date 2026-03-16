import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/admin_product_repository.dart';

final adminProductProvider =
    StateNotifierProvider<AdminProductNotifier, AdminProductState>((ref) {
  return AdminProductNotifier(ref.read(adminProductRepositoryProvider));
});

class AdminProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategoryId;

  AdminProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategoryId,
  });

  AdminProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return AdminProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  List<Product> get filteredProducts {
    var list = products;
    if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
      list = list
          .where((p) => p.categoryId?.id == selectedCategoryId)
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<Product> get lowStockProducts {
    return products
        .where((p) =>
            p.currentStock != null &&
            p.minQty != null &&
            p.currentStock! < p.minQty!)
        .toList();
  }
}

class AdminProductNotifier extends StateNotifier<AdminProductState> {
  final AdminProductRepository _repo;

  AdminProductNotifier(this._repo) : super(AdminProductState());

  Future<void> loadProducts({String? categoryId, String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repo.getProducts(
        categoryId: categoryId,
        search: search,
      );
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createProduct(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.createProduct(data, imageFile: imageFile);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateProduct(id, data, imageFile: imageFile);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void searchProducts(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterByCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }
}
