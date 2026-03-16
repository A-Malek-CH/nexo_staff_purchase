import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';

final adminProductServiceProvider = Provider<AdminProductService>((ref) {
  return AdminProductService(ref.read(dioProvider));
});

class AdminProductService {
  final Dio _dio;

  AdminProductService(this._dio);

  Future<List<Product>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.productsEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['products'] ?? response.data;
      return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      final data = response.data['product'] ?? response.data;
      return Product.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> createProduct(
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      if (imageFile != null) {
        final formData = _buildFormData(data, imageFile);
        final response = await _dio.post(
          AppConstants.productsEndpoint,
          data: await formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final responseData = response.data['product'] ?? response.data;
        return Product.fromJson(responseData as Map<String, dynamic>);
      } else {
        final response = await _dio.post(AppConstants.productsEndpoint, data: data);
        final responseData = response.data['product'] ?? response.data;
        return Product.fromJson(responseData as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    try {
      if (imageFile != null) {
        final formData = _buildFormData(data, imageFile);
        final response = await _dio.put(
          '${AppConstants.productsEndpoint}/$id',
          data: await formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final responseData = response.data['product'] ?? response.data;
        return Product.fromJson(responseData as Map<String, dynamic>);
      } else {
        final response =
            await _dio.put('${AppConstants.productsEndpoint}/$id', data: data);
        final responseData = response.data['product'] ?? response.data;
        return Product.fromJson(responseData as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('${AppConstants.productsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<FormData> _buildFormData(Map<String, dynamic> data, File imageFile) async {
    final fileName = path.basename(imageFile.path);
    final fields = data.entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value.toString()))
        .toList();

    final formData = FormData.fromMap({
      ...{for (final f in fields) f.key: f.value},
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    return formData;
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
