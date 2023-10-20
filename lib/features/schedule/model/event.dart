import 'package:isar/isar.dart';

part 'event.g.dart';

@collection
class Event {
  Id id = Isar.autoIncrement;
  String? title;
  String? content;

  bool everyMonth = false;
  bool everyWeek = false;
  byte dayOfWeek = 0;

  String? periodicId;
  short? periodicChildId;
  DateTime? deadline;
  var createdPeriodicEventDays = <DateTime>[];

  bool fiveMinute = false;
  bool tenMinute = false;
  bool half = false;

  DateTime? from;
  DateTime? to;

  late DateTime createdAt;
}
