import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'task_activity.freezed.dart';
part 'task_activity.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class TaskActivity with _$TaskActivity {
  const TaskActivity._();

  const factory TaskActivity({
    required Id id,
    required String taskName,
    String? categoryName,
    String? memo,
    String? headerImagePath,
    String? unit,
    int? petId,
    int? taskId,
    int? categoryId,
    int? amount,
    int? cost,
    DateTime? createdAt,
  }) = _TaskActivity;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory TaskActivity.fromJson(Map<String, dynamic> json) =>
      _$TaskActivityFromJson(json);
}
