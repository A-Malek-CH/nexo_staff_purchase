// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Staff _$StaffFromJson(Map<String, dynamic> json) => Staff(
      id: json['_id'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
      '_id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['_id'] as String,
      taskNumber: json['taskNumber'] as String,
      staffId: json['staffId'] == null
          ? null
          : Staff.fromJson(json['staffId'] as Map<String, dynamic>),
      description: json['description'] as String?,
      status: json['status'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      '_id': instance.id,
      'taskNumber': instance.taskNumber,
      'staffId': instance.staffId?.toJson(),
      'description': instance.description,
      'status': instance.status,
      'deadline': instance.deadline?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

