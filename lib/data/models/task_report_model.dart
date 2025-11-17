import 'package:json_annotation/json_annotation.dart';

part 'task_report_model.g.dart';

@JsonSerializable()
class TaskReport {
  final String id;
  final String taskId;
  final String reportType;
  final String title;
  final String description;
  final List<String>? photoUrls;
  final String? productId;
  final String? supplierId;
  final double? priceChange;
  final String? alternativeProduct;
  final String status;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  TaskReport({
    required this.id,
    required this.taskId,
    required this.reportType,
    required this.title,
    required this.description,
    this.photoUrls,
    this.productId,
    this.supplierId,
    this.priceChange,
    this.alternativeProduct,
    required this.status,
    required this.reportedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  factory TaskReport.fromJson(Map<String, dynamic> json) =>
      _$TaskReportFromJson(json);
  Map<String, dynamic> toJson() => _$TaskReportToJson(this);

  TaskReport copyWith({
    String? id,
    String? taskId,
    String? reportType,
    String? title,
    String? description,
    List<String>? photoUrls,
    String? productId,
    String? supplierId,
    double? priceChange,
    String? alternativeProduct,
    String? status,
    String? reportedBy,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return TaskReport(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      productId: productId ?? this.productId,
      supplierId: supplierId ?? this.supplierId,
      priceChange: priceChange ?? this.priceChange,
      alternativeProduct: alternativeProduct ?? this.alternativeProduct,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
