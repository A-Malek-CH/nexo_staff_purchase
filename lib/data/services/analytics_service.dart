import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/analytics_model.dart';
import '../models/order_stats_model.dart';
import '../../core/constants/app_constants.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.read(dioProvider));
});

class AnalyticsService {
  final Dio _dio;

  AnalyticsService(this._dio);

  Future<List<CategoryAnalytics>> getCategoryAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics/category');
      final List<dynamic> data =
          response.data['data'] ?? response.data['categories'] ?? response.data;
      return data
          .map((json) => CategoryAnalytics.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MonthlyAnalytics>> getMonthlyAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics/monthly');
      final List<dynamic> data =
          response.data['data'] ?? response.data['monthly'] ?? response.data;
      return data
          .map((json) => MonthlyAnalytics.fromJson(json as Map<String, dynamic>))
          .toList();
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
