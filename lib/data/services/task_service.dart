import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/task_model.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.read(dioProvider));
});

class TaskService {
  final Dio _dio;

  TaskService(this._dio);

  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;

      final response = await _dio.get(
        AppConstants.tasksEndpoint,
        queryParameters: queryParams,
      );

      final rawData = response.data;
      final List<dynamic> data = rawData is List
          ? rawData
          : (rawData['data'] ?? rawData['tasks'] ?? rawData) as List<dynamic>;
      return data.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Task>> getMyTasks({
    String? status,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    return getTasks(status: status, page: page, limit: limit);
  }

  Future<void> markTaskAsDone(String taskId) async {
    await updateTaskStatus(taskId, 'completed');
  }

  Future<Task> getTaskById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.tasksEndpoint}/$id');
      final rawData = response.data;
      final Map<String, dynamic> data = rawData is Map && rawData.containsKey('data')
          ? rawData['data'] as Map<String, dynamic>
          : rawData is Map && rawData.containsKey('task')
              ? rawData['task'] as Map<String, dynamic>
              : rawData as Map<String, dynamic>;
      return Task.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${AppConstants.tasksEndpoint}/$id',
        data: data,
      );
      final rawData = response.data;
      final Map<String, dynamic> taskData = rawData is Map && rawData.containsKey('data')
          ? rawData['data'] as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      return Task.fromJson(taskData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTaskStatus(String id, String status) async {
    return updateTask(id, {'status': status});
  }

  Future<void> uploadReceipt(String taskId, String itemId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'task_id': taskId,
        'item_id': itemId,
      });

      await _dio.post(
        '${AppConstants.tasksEndpoint}/$taskId/items/$itemId/receipt',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadPhoto(String taskId, String itemId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'task_id': taskId,
        'item_id': itemId,
      });

      await _dio.post(
        '${AppConstants.tasksEndpoint}/$taskId/items/$itemId/photo',
        data: formData,
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
