import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'calender.dart';
import 'event_edit.dart';
import '../model/event.dart';
import '../application/schedule_provider.dart';

class EventList extends ConsumerWidget {
  const EventList({super.key});

  @override
  Widget build(context, ref) {
    final selectDay = ref.watch(selectDayProvider);
    final events = ref
        .watch(scheduleProvider)
        .where((event) => isSameDay(event.createdAt, selectDay))
        .toList();

    return SizedBox(
        child: ListView.builder(
            itemCount: events.length,
            itemBuilder: ((context, index) {
              final formatter = DateFormat('HH : mm');

              return ListTile(
                  title: ExpansionTile(
                      tilePadding: const EdgeInsets.only(left: 0),
                      leading: TextButton.icon(
                        icon: Row(children: [
                          if (events[index].dayOfWeek != 0 ||
                              events[index].everyMonth)
                            const Icon(Icons.event_repeat)
                          else
                            const Icon(Icons.event),
                        ]),
                        label: switch (events[index]) {
                          Event(
                            :final from,
                            :final to,
                            :final fiveMinute,
                            :final tenMinute,
                            :final half
                          )
                              when from is DateTime && to is DateTime =>
                            Stack(children: [
                              if (fiveMinute || tenMinute || half)
                                const Icon(Icons.notifications_active_outlined,
                                    color: Colors.yellowAccent, size: 12),
                              Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: Text(
                                      ' ${formatter.format(from)}  -  ${formatter.format(to)}'))
                            ]),
                          Event(
                            :final from,
                            :final to,
                            :final fiveMinute,
                            :final tenMinute,
                            :final half
                          )
                              when from is DateTime && to is! DateTime =>
                            Stack(
                              children: [
                                if (fiveMinute || tenMinute || half)
                                  const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.yellowAccent,
                                      size: 12),
                                Padding(
                                    padding: const EdgeInsets.only(left: 9),
                                    child:
                                        Text(' ${formatter.format(from)} ～')),
                              ],
                            ),
                          Event(
                            :final from,
                            :final to,
                            :final fiveMinute,
                            :final tenMinute,
                            :final half
                          )
                              when from is! DateTime && to is DateTime =>
                            Stack(
                              children: [
                                if (fiveMinute || tenMinute || half)
                                  const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.yellowAccent,
                                      size: 12),
                                Padding(
                                    padding: const EdgeInsets.only(left: 9),
                                    child: Text(' ～ ${formatter.format(to)}')),
                              ],
                            ),
                          _ => const Text('指定なし')
                        },
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return SimpleDialog(
                                    children: [EventEdit(events[index])]);
                              });
                        },
                      ),
                      expandedAlignment: Alignment.centerLeft,
                      childrenPadding: const EdgeInsets.fromLTRB(10, 5, 20, 10),
                      title: Text(events[index].title!),
                      children: [Text(events[index].content!)]));
            })));
  }
}
