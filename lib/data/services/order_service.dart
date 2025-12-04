import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/order_model.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.read(dioProvider));
});

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  /// Get orders assigned to the logged-in staff
  Future<List<Order>> getMyOrders({
    String? status,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        AppConstants.ordersEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['orders'] ?? response.data;
      final orders = data.map((json) => Order.fromJson(json)).toList();
      
      // Filter to only show orders assigned to current user (status: "assigned")
      // If the backend doesn't filter, we do it client-side
      return orders.where((order) => 
        order.staffId != null && 
        (status == null || order.status == status)
      ).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single order details by ID
  Future<Order> getOrderById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}/$id');
      final data = response.data['data'] ?? response.data;
      return Order.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm order with image proof (change status from "assigned" to "confirmed")
  /// Returns void since the response is unpopulated and we don't need to parse it
  Future<void> submitOrderForReview(String orderId, File imageFile, String? notes) async {
    try {
      // Get file extension and determine content type
      final fileName = path.basename(imageFile.path);
      final extension = path.extension(imageFile.path).toLowerCase();
      
      // Map extension to MediaType
      MediaType contentType;
      switch (extension) {
        case '.jpg':
        case '.jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case '.png':
          contentType = MediaType('image', 'png');
          break;
        case '.webp':
          contentType = MediaType('image', 'webp');
          break;
        case '.gif':
          contentType = MediaType('image', 'gif');
          break;
        default:
          contentType = MediaType('image', 'jpeg');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: contentType,
        ),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      final response = await _dio.post(
        '${AppConstants.ordersEndpoint}/$orderId/confirm',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      // Just verify success - don't parse the unpopulated response
      if (response.statusCode != 200) {
        throw 'Order confirmation failed with status ${response.statusCode}';
      }
      // Success! No need to return the order since response is unpopulated
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
