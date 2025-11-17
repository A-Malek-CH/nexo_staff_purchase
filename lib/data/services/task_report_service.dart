import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/task_report_model.dart';

final taskReportServiceProvider = Provider<TaskReportService>((ref) {
  return TaskReportService(ref.read(dioProvider));
});

class TaskReportService {
  final Dio _dio;

  TaskReportService(this._dio);

  Future<List<TaskReport>> getTaskReports({
    String? taskId,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (taskId != null) queryParams['task_id'] = taskId;

      final response = await _dio.get(
        AppConstants.taskReportsEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => TaskReport.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskReport> createTaskReport({
    required String taskId,
    required String reportType,
    required String title,
    required String description,
    String? productId,
    String? supplierId,
    double? priceChange,
    String? alternativeProduct,
    List<String>? photoUrls,
  }) async {
    try {
      final data = {
        'task_id': taskId,
        'report_type': reportType,
        'title': title,
        'description': description,
        if (productId != null) 'product_id': productId,
        if (supplierId != null) 'supplier_id': supplierId,
        if (priceChange != null) 'price_change': priceChange,
        if (alternativeProduct != null) 'alternative_product': alternativeProduct,
        if (photoUrls != null && photoUrls.isNotEmpty) 'photo_urls': photoUrls,
      };

      final response = await _dio.post(
        AppConstants.taskReportsEndpoint,
        data: data,
      );

      return TaskReport.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> uploadReportPhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '${AppConstants.taskReportsEndpoint}/upload',
        data: formData,
      );

      return response.data['url'] as String;
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
