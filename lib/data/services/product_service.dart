import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.read(dioProvider));
});

class ProductService {
  final Dio _dio;

  ProductService(this._dio);

  Future<List<Product>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.productsEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusMessage}';
    }
    return 'An unexpected error occurred.';
  }
}
