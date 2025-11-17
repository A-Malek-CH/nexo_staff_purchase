import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(productServiceProvider));
});

class ProductRepository {
  final ProductService _productService;

  ProductRepository(this._productService);

  Future<List<Product>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
  }) async {
    return await _productService.getProducts(
      categoryId: categoryId,
      search: search,
      page: page,
    );
  }

  Future<Product> getProductById(String id) async {
    return await _productService.getProductById(id);
  }
}
