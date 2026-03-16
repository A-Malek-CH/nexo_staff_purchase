import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../models/order_stats_model.dart';

final adminOrderServiceProvider = Provider<AdminOrderService>((ref) {
  return AdminOrderService(ref.read(dioProvider));
});

class AdminOrderService {
  final Dio _dio;

  AdminOrderService(this._dio);

  Future<List<Order>> getAllOrders({
    String? status,
    String? supplierId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (supplierId != null && supplierId.isNotEmpty) {
        queryParams['supplierId'] = supplierId;
      }

      final response = await _dio.get(
        AppConstants.ordersEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['orders'] ?? response.data;
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> getOrderById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}/$id');
      final data = response.data['order'] ?? response.data['data'] ?? response.data;
      return Order.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(AppConstants.ordersEndpoint, data: data);
      final responseData = response.data['order'] ?? response.data;
      return Order.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> updateOrder(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('${AppConstants.ordersEndpoint}/$id', data: data);
      final responseData = response.data['order'] ?? response.data;
      return Order.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderStats> getOrderStats() async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}/stats');
      final data = response.data['stats'] ?? response.data;
      return OrderStats.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> confirmPayment(String id, {File? billFile, String? notes}) async {
    try {
      final formData = FormData();
      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes));
      }
      if (billFile != null) {
        final fileName = path.basename(billFile.path);
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            billFile.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }
      await _dio.post(
        '${AppConstants.ordersEndpoint}/$id/confirm-payment',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
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
