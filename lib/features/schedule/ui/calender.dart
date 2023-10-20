import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import "package:intl/intl.dart";

import 'event_list.dart';
import 'event_create.dart';
import '../model/event.dart';
import '../application/schedule_provider.dart';

final selectDayProvider = StateProvider.autoDispose((ref) => DateTime.now());
final focusDayProvider = StateProvider.autoDispose((ref) => DateTime.now());

class Calendar extends ConsumerWidget {
  const Calendar({super.key});

  @override
  Widget build(context, ref) {
    var selectDay = ref.watch(selectDayProvider);
    var focusDay = ref.watch(focusDayProvider);
    final now = DateTime.now();

    // print(DateTime(now.year, now.month, 1));

    // print(now.add(Duration(days: -2)));

    final dayOfWeekMarkerColors = [
      Colors.yellow.shade200,
      Colors.purple.shade200,
      Colors.orange.shade200,
      Colors.pink.shade200,
      Colors.cyan.shade200,
      Colors.red.shade200,
      Colors.green.shade200,
    ];

    final dayOfWeekMarkers = List.generate(
        dayOfWeekMarkerColors.length,
        (index) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dayOfWeekMarkerColors[index],
              ),
              height: 5,
              width: 5,
            ));
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Consumer(
          builder: (context, ref, child) {
            final events = ref.watch(scheduleProvider);
            return TableCalendar(
                locale: 'ja_JP',
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2050, 1, 1),
                focusedDay: focusDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                calendarStyle: CalendarStyle(
                    tablePadding: const EdgeInsets.all(0),
                    markerMargin: const EdgeInsets.fromLTRB(1, 4, 1, 0),
                    markerSizeScale: 0.18,
                    markersMaxCount: 5,
                    markersAnchor: 0.5,
                    cellMargin: const EdgeInsets.all(10),
                    todayTextStyle: const TextStyle(),
                    selectedTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.cyan.withOpacity(0.5),
                          Colors.purpleAccent.withOpacity(0.4),
                          // Colors.pinkAccent.withOpacity(0.4),
                          Colors.pinkAccent.withOpacity(0.85),
                        ],
                      ),
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    )),
                selectedDayPredicate: (day) {
                  return isSameDay(selectDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(selectDay, selectedDay)) {
                    ref
                        .read(selectDayProvider.notifier)
                        .update((state) => selectedDay);

                    ref
                        .read(focusDayProvider.notifier)
                        .update((state) => focusedDay);
                  }
                },
                calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, List<Event> events) {
                  if (events.isNotEmpty) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: events.map((event) {
                          return switch (event) {
                            Event(:final everyMonth) when everyMonth =>
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.lime,
                                ),
                                height: 10,
                                width: 10,
                              ),
                            Event(:final everyWeek, :final dayOfWeek)
                                when everyWeek =>
                              dayOfWeekMarkers[dayOfWeek - 1],
                            _ => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade200,
                                ),
                                height: 5,
                                width: 5,
                              )
                          };
                        }).toList());
                  }
                  return null;
                }, dowBuilder: (_, day) {
                  return Center(
                    child: Text(
                      DateFormat.E('ja_JP').format(day),
                      style: switch (day.weekday) {
                        DateTime.sunday =>
                          const TextStyle(height: 0.8, color: Colors.red),
                        DateTime.saturday =>
                          const TextStyle(height: 0.8, color: Colors.blue),
                        _ => const TextStyle(height: 0.8)
                      },
                    ),
                  );
                }),
                eventLoader: (day) {
                  return events
                      .where((event) => isSameDay(event.createdAt, day))
                      .toList();
                },
                onPageChanged: (pageChangedDay) {
                  focusDay = pageChangedDay;

                  if (pageChangedDay.month < now.month) {
                    return;
                  }

                  final shouldCreatePeriodicEvents =
                      ref.read(scheduleProvider.notifier).getPeriodicEvents();

                  if (shouldCreatePeriodicEvents.isEmpty) {
                    return;
                  }

                  final targets = shouldCreatePeriodicEvents
                      .where((periodicEvent) =>
                          pageChangedDay.month <= periodicEvent.deadline!.month)
                      .toList();

                  if (targets.isEmpty) {
                    return;
                  }

                  for (final target in targets) {
                    if (target.everyMonth) {
                      continue;
                    }
                    // if (pageChangedDay.month <= target.createdAt.month) {
                    //   continue;
                    // }

                    final createdEvents = target.createdPeriodicEventDays
                        .where((createdEventDay) {
                      return ref
                          .read(scheduleProvider.notifier)
                          .isSameMonth(createdEventDay, pageChangedDay);
                    });

                    if (createdEvents.isNotEmpty) {
                      continue;
                    }

                    final addCount =
                        (target.dayOfWeek - pageChangedDay.weekday + 7) % 7;

                    final firstWeekDay =
                        pageChangedDay.add(Duration(days: addCount));
                    // .copyWith(isUtc: false);

                    if (target.deadline!.month == pageChangedDay.month &&
                        target.deadline!.day < firstWeekDay.day) {
                      continue;
                    }

                    if (pageChangedDay.month < target.deadline!.month) {
                      final endOfMonth = DateTime(
                          pageChangedDay.year, pageChangedDay.month + 1, 0);

                      int remainingWeeksFromFirstWeekToEndOfMonth =
                          DateTimeRange(start: firstWeekDay, end: endOfMonth)
                                  .duration
                                  .inDays ~/
                              7;

                      final eventList = List.generate(
                          remainingWeeksFromFirstWeekToEndOfMonth + 1, (index) {
                        return Event()
                          ..periodicChildId = target.id
                          ..title = target.title
                          ..content = target.content
                          ..from = target.from?.copyWith(
                              month: firstWeekDay.month,
                              day: firstWeekDay
                                  .add(Duration(days: index * 7))
                                  .day)
                          ..to = target.to?.copyWith(
                              month: firstWeekDay.month,
                              day: firstWeekDay
                                  .add(Duration(days: index * 7))
                                  .day)
                          ..fiveMinute = target.fiveMinute
                          ..tenMinute = target.tenMinute
                          ..half = target.half
                          ..everyMonth = target.everyMonth
                          ..everyWeek = target.everyWeek
                          ..dayOfWeek = target.dayOfWeek
                          ..deadline = target.deadline
                          ..createdAt =
                              firstWeekDay.add(Duration(days: index * 7));
                      }).nonNulls.toList();

                      eventList.forEach(
                          ref.read(scheduleProvider.notifier).saveEvent);

                      target.createdPeriodicEventDays.add(pageChangedDay);

                      ref.read(scheduleProvider.notifier).updateEvent(target);
                    }

                    if (pageChangedDay.month == target.deadline!.month) {
                      int remainingWeeksFromFirstWeekToDeadline = DateTimeRange(
                                  start: firstWeekDay, end: target.deadline!)
                              .duration
                              .inDays ~/
                          7;

                      final eventList = List.generate(
                          remainingWeeksFromFirstWeekToDeadline + 1, (index) {
                        return Event()
                          ..periodicChildId = target.id
                          ..title = target.title
                          ..content = target.content
                          ..from = target.from?.copyWith(
                              month: firstWeekDay.month,
                              day: firstWeekDay
                                  .add(Duration(days: index * 7))
                                  .day)
                          ..to = target.to?.copyWith(
                              month: firstWeekDay.month,
                              day: firstWeekDay
                                  .add(Duration(days: index * 7))
                                  .day)
                          ..fiveMinute = target.fiveMinute
                          ..tenMinute = target.tenMinute
                          ..half = target.half
                          ..everyMonth = target.everyMonth
                          ..everyWeek = target.everyWeek
                          ..dayOfWeek = target.dayOfWeek
                          ..deadline = target.deadline
                          ..createdAt =
                              firstWeekDay.add(Duration(days: index * 7));
                      }).nonNulls.toList();

                      eventList.forEach(
                          ref.read(scheduleProvider.notifier).saveEvent);

                      target.createdPeriodicEventDays.add(pageChangedDay);

                      ref.read(scheduleProvider.notifier).updateEvent(target);
                    }
                  }
                });
          },
        ),
        const SizedBox(height: 20),
        const Flexible(child: EventList())
      ]),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const SimpleDialog(
                    insetPadding: EdgeInsets.zero,
                    children: [
                      EventCreate(),
                    ]);
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
