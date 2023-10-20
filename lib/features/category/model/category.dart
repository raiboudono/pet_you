import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Category with _$Category {
  const Category._();

  const factory Category({
    required Id id,
    required String name,
    String? description,
    int? position,
    int? iconCodePoint,
    @Default([]) List<int> taskIds,
    @Default(true) bool visible,
    DateTime? createdAt,
  }) = _Category;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
