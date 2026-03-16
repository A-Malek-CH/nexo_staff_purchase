import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/category_model.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(dioProvider));
});

class CategoryService {
  final Dio _dio;

  CategoryService(this._dio);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(AppConstants.categoriesEndpoint);
      final List<dynamic> data =
          response.data['categories'] ?? response.data;
      return data.map((json) => _categoryFromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(AppConstants.categoriesEndpoint, data: data);
      final responseData = response.data['category'] ?? response.data;
      return _categoryFromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Category> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('${AppConstants.categoriesEndpoint}/$id', data: data);
      final responseData = response.data['category'] ?? response.data;
      return _categoryFromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('${AppConstants.categoriesEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handles both 'id' and '_id' from API responses
  Category _categoryFromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '') as String;
    final isActive = json['isActive'];
    final createdAt = json['createdAt'];
    return Category(
      id: id,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      isActive: isActive is bool ? isActive : true,
      createdAt: createdAt != null
          ? (DateTime.tryParse(createdAt as String) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
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
