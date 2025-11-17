import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? taskId;
  final String? data;
  final bool isRead;
  final String userId;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.taskId,
    this.data,
    required this.isRead,
    required this.userId,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? taskId,
    String? data,
    bool? isRead,
    String? userId,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      taskId: taskId ?? this.taskId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
