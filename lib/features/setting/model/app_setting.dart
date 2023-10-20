import 'package:isar/isar.dart';

part 'app_setting.g.dart';

@collection
class AppSetting {
  Id id = Isar.autoIncrement;

  bool theme = true;
  String? font;
  bool premium = false;
  bool tutorial = true;

  DateTime? backupImageDate;
  DateTime? backupVideoDate;
  DateTime? backupTaskDate;

  DateTime? createdAt;
}
