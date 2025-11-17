// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'notification_model.dart';

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) => NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      taskId: json['task_id'] as String?,
      data: json['data'] as String?,
      isRead: json['is_read'] as bool,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'task_id': instance.taskId,
      'data': instance.data,
      'is_read': instance.isRead,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };
