import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/supplier_model.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(ref.read(dioProvider));
});

class SupplierService {
  final Dio _dio;

  SupplierService(this._dio);

  Future<List<Supplier>> getSuppliers({
    String? search,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.suppliersEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Supplier.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Supplier> getSupplierById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.suppliersEndpoint}/$id');
      return Supplier.fromJson(response.data);
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
