import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';
import '../../../infra/schedule/schedule_repository.dart';
import '../model/event.dart';

final scheduleProvider =
    StateNotifierProvider.autoDispose<ScheduleStateNotifier, List<Event>>(
        (ref) {
  final repository = ref.watch(repositoryProvider(Work.schedule));
  return ScheduleStateNotifier(repository);
});

class ScheduleStateNotifier extends StateNotifier<List<Event>> {
  ScheduleStateNotifier(this._repository) : super(_repository.getEventsAll());
  final ScheduleRepository _repository;

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isSameMonth(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month;
  }

  int getCountRemainingWeeks(DateTime start, DateTime end) {
    return DateTimeRange(start: start, end: end).duration.inDays ~/ 7;
  }

  List<Event> getEventForDay(DateTime selectedDay) {
    List<Event> selectedDayEvents = state
        .where((event) => isSameDay(event.createdAt, selectedDay))
        .toList();

    return selectedDayEvents;
  }

  List<Event> getPeriodicEvents() {
    return _repository.getPeriodicEventsByPeriodicIds();
  }

  void removeEvent(Event event) {
    _repository.deleteEvent(event);
    state = _repository.getEventsAll();
  }

  saveEvent(Event event) {
    _repository.insertEvent(event);
    state = _repository.getEventsAll();
  }

  updateEvent(Event event) {
    _repository.updateEvent(event);
    state = _repository.getEventsAll();
  }

  Event? findByPeriodicId(id) {
    return _repository.findByPeriodicId(id);
  }

  List<Event> findByPeriodicIdAll(id) {
    return _repository.findByPeriodicIdAll(id);
  }
}
