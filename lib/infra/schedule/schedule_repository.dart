import 'package:isar/isar.dart';

import '../../features/schedule/model/event.dart';

class ScheduleRepository {
  ScheduleRepository(this.isar);
  Isar isar;

  List<Event> getEventsAll() {
    return isar.events.where().findAllSync();
  }

  Event? findByPeriodicId(id) {
    return isar.events.filter().periodicIdEqualTo(id).findFirstSync();
  }

  List<Event> findByPeriodicIdAll(id) {
    return isar.events.where().filter().periodicIdEqualTo(id).findAllSync();
  }

  deleteEvent(Event event) {
    isar.writeTxnSync(() {
      isar.events.deleteSync(event.id);
    });
  }

  List<Event> getPeriodicEventsByPeriodicIds() {
    return isar.events.filter().periodicIdIsNotNull().findAllSync();
  }

  insertEvent(Event event) {
    isar.writeTxnSync(() {
      isar.events.putSync(event);
    });
  }

  updateEvent(Event event) {
    isar.writeTxnSync(() {
      isar.events.putSync(event);
    });
  }
}
