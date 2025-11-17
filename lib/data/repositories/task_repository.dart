import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(taskServiceProvider));
});

class TaskRepository {
  final TaskService _taskService;

  TaskRepository(this._taskService);

  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    return await _taskService.getTasks(
      status: status,
      priority: priority,
      page: page,
    );
  }

  Future<Task> getTaskById(String id) async {
    return await _taskService.getTaskById(id);
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    return await _taskService.updateTask(id, data);
  }

  Future<Task> updateTaskStatus(String id, String status) async {
    return await _taskService.updateTaskStatus(id, status);
  }

  Future<void> uploadReceipt(String taskId, String itemId, String filePath) async {
    return await _taskService.uploadReceipt(taskId, itemId, filePath);
  }

  Future<void> uploadPhoto(String taskId, String itemId, String filePath) async {
    return await _taskService.uploadPhoto(taskId, itemId, filePath);
  }

  List<Task> filterTodayTasks(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((task) {
      return task.deadline.year == now.year &&
          task.deadline.month == now.month &&
          task.deadline.day == now.day;
    }).toList();
  }

  List<Task> filterUrgentTasks(List<Task> tasks) {
    return tasks.where((task) => task.priority == 'urgent').toList();
  }

  List<Task> filterOverdueTasks(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((task) => task.deadline.isBefore(now)).toList();
  }
}
