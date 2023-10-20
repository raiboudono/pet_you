import 'package:isar/isar.dart';
part 'folder.g.dart';

@collection
class Folder {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;
}
