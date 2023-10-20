import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Diary with _$Diary {
  const Diary._();

  const factory Diary({
    required Id id,
    String? title,
    String? content,
    String? searchContent,
    String? headerImagePath,
    int? folderId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Diary;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);
}
