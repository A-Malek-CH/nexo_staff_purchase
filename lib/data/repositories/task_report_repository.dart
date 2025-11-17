import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_report_model.dart';
import '../services/task_report_service.dart';

final taskReportRepositoryProvider = Provider<TaskReportRepository>((ref) {
  return TaskReportRepository(ref.read(taskReportServiceProvider));
});

class TaskReportRepository {
  final TaskReportService _taskReportService;

  TaskReportRepository(this._taskReportService);

  Future<List<TaskReport>> getTaskReports({
    String? taskId,
    int page = 1,
  }) async {
    return await _taskReportService.getTaskReports(
      taskId: taskId,
      page: page,
    );
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
    return await _taskReportService.createTaskReport(
      taskId: taskId,
      reportType: reportType,
      title: title,
      description: description,
      productId: productId,
      supplierId: supplierId,
      priceChange: priceChange,
      alternativeProduct: alternativeProduct,
      photoUrls: photoUrls,
    );
  }

  Future<String> uploadReportPhoto(String filePath) async {
    return await _taskReportService.uploadReportPhoto(filePath);
  }
}
