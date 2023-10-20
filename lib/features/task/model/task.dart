import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Task with _$Task {
  const Task._();

  const factory Task({
    required Id id,
    required String name,
    int? amount,
    String? headerImagePath,
    String? description,
    String? type,
    String? unit,
    String? dayCount,
    int? categoryId,
    @Default(true) bool visible,
    DateTime? createdAt,
  }) = _Task;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
