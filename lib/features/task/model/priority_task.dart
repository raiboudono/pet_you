import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'priority_task.freezed.dart';
part 'priority_task.g.dart';

enum Status {
  completed('完了'),
  progress('進行中'),
  waiting('未着手');

  const Status(this.name);

  final String name;
}

enum Priority {
  high('高'),
  middle('中'),
  low('低');

  const Priority(this.name);

  final String name;
}

@freezed
@Collection(ignore: {'copyWith'})
class PriorityTask with _$PriorityTask {
  const PriorityTask._();

  const factory PriorityTask({
    required Id id,
    required String name,
    int? categoryId,
    int? taskId,
    int? petId,
    @Default(0) int executed,
    String? memo,
    @Default(0) double progress,
    @Default(1) int times,
    @Enumerated(EnumType.value, 'name') Status? status,
    @enumerated @Default(Priority.middle) Priority priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PriorityTask;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory PriorityTask.fromJson(Map<String, dynamic> json) =>
      _$PriorityTaskFromJson(json);
}
