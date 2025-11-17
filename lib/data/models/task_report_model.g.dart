// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'task_report_model.dart';

TaskReport _$TaskReportFromJson(Map<String, dynamic> json) => TaskReport(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      reportType: json['report_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      productId: json['product_id'] as String?,
      supplierId: json['supplier_id'] as String?,
      priceChange: (json['price_change'] as num?)?.toDouble(),
      alternativeProduct: json['alternative_product'] as String?,
      status: json['status'] as String,
      reportedBy: json['reported_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null ? null : DateTime.parse(json['resolved_at'] as String),
    );

Map<String, dynamic> _$TaskReportToJson(TaskReport instance) => <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'report_type': instance.reportType,
      'title': instance.title,
      'description': instance.description,
      'photo_urls': instance.photoUrls,
      'product_id': instance.productId,
      'supplier_id': instance.supplierId,
      'price_change': instance.priceChange,
      'alternative_product': instance.alternativeProduct,
      'status': instance.status,
      'reported_by': instance.reportedBy,
      'created_at': instance.createdAt.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
    };
