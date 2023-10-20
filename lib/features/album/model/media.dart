import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'media.freezed.dart';
part 'media.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Media with _$Media {
  const Media._();

  const factory Media({
    required Id id,
    required String path,
    required String type,
    @Default(true) bool visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Media;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
