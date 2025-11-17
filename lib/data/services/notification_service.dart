import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(dioProvider));
});

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (isRead != null) queryParams['is_read'] = isRead;

      final response = await _dio.get(
        AppConstants.notificationsEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put(
        '${AppConstants.notificationsEndpoint}/$notificationId/read',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put(
        '${AppConstants.notificationsEndpoint}/read-all',
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
