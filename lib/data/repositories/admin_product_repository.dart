import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/admin_product_service.dart';

final adminProductRepositoryProvider = Provider<AdminProductRepository>((ref) {
  return AdminProductRepository(ref.read(adminProductServiceProvider));
});

class AdminProductRepository {
  final AdminProductService _service;

  AdminProductRepository(this._service);

  Future<List<Product>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
  }) async {
    return _service.getProducts(categoryId: categoryId, search: search, page: page);
  }

  Future<Product> getProductById(String id) async {
    return _service.getProductById(id);
  }

  Future<Product> createProduct(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    return _service.createProduct(data, imageFile: imageFile);
  }

  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    return _service.updateProduct(id, data, imageFile: imageFile);
  }

  Future<void> deleteProduct(String id) async {
    return _service.deleteProduct(id);
  }
}
