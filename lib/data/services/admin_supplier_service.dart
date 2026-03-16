import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/supplier_model.dart';

final adminSupplierServiceProvider = Provider<AdminSupplierService>((ref) {
  return AdminSupplierService(ref.read(dioProvider));
});

class AdminSupplierService {
  final Dio _dio;

  AdminSupplierService(this._dio);

  Future<List<Supplier>> getSuppliers({String? search, bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await _dio.get(
        AppConstants.suppliersEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data =
          response.data['suppliers'] ?? response.data;
      return data.map((json) => Supplier.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Supplier> getSupplierById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.suppliersEndpoint}/$id');
      final data = response.data['supplier'] ?? response.data;
      return Supplier.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(AppConstants.suppliersEndpoint, data: data);
      final responseData = response.data['supplier'] ?? response.data;
      return Supplier.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Supplier> updateSupplier(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('${AppConstants.suppliersEndpoint}/$id', data: data);
      final responseData = response.data['supplier'] ?? response.data;
      return Supplier.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _dio.delete('${AppConstants.suppliersEndpoint}/$id');
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
