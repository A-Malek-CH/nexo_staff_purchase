import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Staff {
  @JsonKey(name: '_id')
  final String id;
  final String fullname;
  final String email;

  Staff({
    required this.id,
    required this.fullname,
    required this.email,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Task {
  @JsonKey(name: '_id')
  final String id;
  final int taskNumber;
  final Staff? staffId;
  final String? description;
  final String status;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.taskNumber,
    this.staffId,
    this.description,
    required this.status,
    this.deadline,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    int? taskNumber,
    Staff? staffId,
    String? description,
    String? status,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      taskNumber: taskNumber ?? this.taskNumber,
      staffId: staffId ?? this.staffId,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
