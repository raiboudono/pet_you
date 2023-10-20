import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Pet with _$Pet {
  const Pet._();

  const factory Pet({
    required Id id,
    required String name,
    int? age,
    String? headerImagePath,
    String? message,
    String? sex,
    String? breed,
    DateTime? dateOfBirth,
    int? weight,
    int? stature,
    int? bodyLength,
    int? chest,
    int? neck,
    int? height,
    int? frontLeftShoe,
    int? frontRightShoe,
    int? hindLeftShoe,
    int? hindRightShoe,
    @Default([]) List<int> taskIds,
    @Default([]) List<int> categoryIds,
    @Default([]) List<int> diaryIds,
    @Default([]) List<int> eventIds,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) = _Pet;

  @override
  // ignore: recursive_getters
  Id get id => id;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}
