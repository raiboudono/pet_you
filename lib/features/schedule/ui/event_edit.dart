import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'calender.dart';
import '../model/event.dart';
import '../application/schedule_provider.dart';
import '../../notification/application/local_notification.dart';

final notifyControllerProvider = StateProvider.autoDispose((ref) {
  return <Map<String, Object?>>[
    {'timing': '5', 'select': false},
    {'timing': '10', 'select': false},
    {'timing': '30', 'select': false},
  ];
});

final periodicControllerProvider = StateProvider.autoDispose((ref) {
  return <Map<String, Object?>>[
    {'timing': '毎週', 'select': false},
    {'timing': '毎月', 'select': false},
  ];
});

final notifiyMinuteErrorController =
    StateProvider.autoDispose.family((index, ref) => '');

class EventEdit extends ConsumerStatefulWidget {
  const EventEdit(this.event, {super.key});
  final Event? event;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EventEditState();
}

class EventEditState extends ConsumerState<EventEdit> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final saveTexts = [];
  TimeOfDay? saveFromTime;
  TimeOfDay? saveToTime;

  @override
  void initState() {
    if (widget.event case Event(:final from, :final to)
        when from is DateTime || to is DateTime) {
      final formatter = DateFormat('HH : mm');
      if (from != null) {
        fromController.text = formatter.format(from);
      }
      if (to != null) {
        toController.text = formatter.format(to);
      }
    }

    final notifies = ref.read(notifyControllerProvider);
    notifies[0]['select'] = widget.event!.fiveMinute;
    notifies[1]['select'] = widget.event!.tenMinute;
    notifies[2]['select'] = widget.event!.half;

    final periodicies = ref.read(periodicControllerProvider);

    periodicies[0]['select'] = widget.event!.everyWeek;
    periodicies[1]['select'] = widget.event!.everyMonth;

    super.initState();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final form = GlobalKey<FormState>();
    final selectDay = ref.watch(selectDayProvider);
    final event = widget.event!;

    return SizedBox(
        width: 300,
        child: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (event
                  case Event(
                    :final periodicId,
                    :final everyMonth,
                    :final everyWeek
                  )
                  when periodicId is String &&
                      [everyMonth, everyWeek].any((isPeriodic) => isPeriodic))
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      everyMonth
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('毎月 ${event.createdAt.day}日'))
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:
                                  Text('毎週 (${'日月火水木金土'[event.dayOfWeek]})')),
                      const SizedBox(width: 80),
                      Text(DateFormat('yyyy-MM-dd (E)', 'ja_JP')
                          .format(selectDay))
                    ])
              else
                Align(
                    widthFactor: 2.4,
                    alignment: Alignment.centerRight,
                    child: Text(DateFormat('yyyy-MM-dd (E)', 'ja_JP')
                        .format(selectDay))),
              const SizedBox(height: 20),
              SizedBox(
                  width: 280,
                  child: TextFormField(
                      initialValue: event.title,
                      decoration: const InputDecoration(
                        hintText: 'タイトル',
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "タイトルの入力がありません";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        saveTexts.add(value);
                      })),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Consumer(
                  builder: (context, ref, _) {
                    final periodicies = ref.watch(periodicControllerProvider);

                    return Flexible(
                        child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                                title: const Text('繰り返し'),
                                children: [
                                  ...periodicies.mapIndexed((index, periodic) {
                                    final [timing, select] =
                                        periodic.keys.toList();
                                    return CheckboxListTile(
                                      enabled: false,
                                      title: Text('${periodic[timing]}'),
                                      value: periodic[select] as bool,
                                      onChanged: (bool? value) {
                                        for (final periodic in periodicies) {
                                          periodic[select] = false;
                                        }
                                        periodic[select] = value;
                                        ref
                                            .read(periodicControllerProvider
                                                .notifier)
                                            .update((state) =>
                                                state = [...periodicies]);
                                      },
                                    );
                                  }).toList(),
                                  if (event.deadline != null)
                                    Container(
                                        width: 120,
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: TextFormField(
                                          initialValue:
                                              event.deadline.toString(),
                                          enabled: false,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: '期限',
                                          ),
                                        ))
                                ])));
                  },
                ),
                const SizedBox(width: 10),
                Consumer(
                  builder: (context, ref, _) {
                    final notifies = ref.watch(notifyControllerProvider);

                    return Flexible(
                        child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                childrenPadding: const EdgeInsets.only(left: 5),
                                title: const Text('事前通知'),
                                children: [
                                  ...notifies.mapIndexed((index, notify) {
                                    final [timing, _] = notify.keys.toList();

                                    return CheckboxListTile(
                                      onChanged: null,
                                      enabled: false,
                                      title: Text('${notify[timing]}分前'),
                                      value: [
                                        event.fiveMinute,
                                        event.tenMinute,
                                        event.half
                                      ][index],
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10)
                                ])));
                  },
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 78,
                  child: GestureDetector(
                      onTap: ![event.fiveMinute, event.tenMinute, event.half]
                              .any((_) => _)
                          ? () async {
                              final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  initialEntryMode: TimePickerEntryMode.input);

                              if (mounted && selectedTime != null) {
                                fromController.text =
                                    selectedTime.format(context);
                              }
                              saveFromTime = selectedTime;
                            }
                          : null,
                      child: TextFormField(
                          controller: fromController,
                          enabled: false,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            hintText: '開始時間',
                          ),
                          validator: (String? value) {
                            final [
                              {'timing': _, 'select': fiveMinute as bool},
                              {'timing': _, 'select': tenMinute as bool},
                              {'timing': _, 'select': half as bool}
                            ] = ref.read(notifyControllerProvider);

                            if (value == '' &&
                                [fiveMinute, tenMinute, half]
                                    .any((minute) => minute)) {
                              return '開始時間の入力がありません';
                            }
                            return null;
                          })),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: 78,
                  child: GestureDetector(
                      onTap: ![event.fiveMinute, event.tenMinute, event.half]
                              .any((_) => _)
                          ? () async {
                              final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  initialEntryMode: TimePickerEntryMode.input);

                              if (mounted && selectedTime != null) {
                                toController.text =
                                    selectedTime.format(context);
                              }
                              saveToTime = selectedTime;
                            }
                          : null,
                      child: TextFormField(
                        controller: toController,
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        decoration: const InputDecoration(
                          hintText: '終了時間',
                        ),
                      )),
                ),
                const SizedBox(width: 20),
              ]),
              const SizedBox(height: 20),
              if ([event.fiveMinute, event.tenMinute, event.half].any((_) => _))
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: const Text('事前通知を設定の場合は開始時間と終了時間の変更ができません',
                        style: TextStyle(fontSize: 11))),
              const SizedBox(height: 20),
              SizedBox(
                  width: 280,
                  child: TextFormField(
                      initialValue: event.content,
                      decoration: const InputDecoration(
                        hintText: 'メモ',
                        contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      ),
                      maxLines: null,
                      onSaved: (String? value) {
                        saveTexts.add(value);
                      })),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const SizedBox(width: 20),
                FilledButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                                height: event.everyMonth || event.everyWeek
                                    ? 170
                                    : 130,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text('削除しますか？'),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            if (event.everyMonth ||
                                                event.everyWeek)
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        if (event.everyMonth) {
                                                          ref
                                                              .read(
                                                                  scheduleProvider
                                                                      .notifier)
                                                              .removeEvent(
                                                                  event);
                                                        }

                                                        if (event.everyWeek) {
                                                          if (event
                                                                  .periodicId !=
                                                              null) {
                                                            final nextMonth =
                                                                DateTime(
                                                                    selectDay
                                                                        .year,
                                                                    selectDay
                                                                            .month +
                                                                        1,
                                                                    1);

                                                            final deadline =
                                                                event.deadline!;

                                                            if (!event
                                                                .createdPeriodicEventDays
                                                                .contains(
                                                                    nextMonth)) {
                                                              if (selectDay
                                                                      .month <
                                                                  deadline
                                                                      .month) {
                                                                var addCount = (event
                                                                            .dayOfWeek -
                                                                        nextMonth
                                                                            .weekday +
                                                                        7) %
                                                                    7;

                                                                var firstWeekOfNextMonth =
                                                                    nextMonth.add(
                                                                        Duration(
                                                                            days:
                                                                                addCount));

                                                                if (deadline.month ==
                                                                        firstWeekOfNextMonth
                                                                            .month &&
                                                                    deadline.day <
                                                                        firstWeekOfNextMonth
                                                                            .day) {
                                                                  ref
                                                                      .read(scheduleProvider
                                                                          .notifier)
                                                                      .removeEvent(
                                                                          event);
                                                                }

                                                                final remainingWeeksFromFirstWeekToDeadline = DateTimeRange(
                                                                            start:
                                                                                firstWeekOfNextMonth,
                                                                            end:
                                                                                deadline)
                                                                        .duration
                                                                        .inDays ~/
                                                                    7;

                                                                int remainingWeeksFromFirstWeekToNextMonth =
                                                                    0;

                                                                if (nextMonth
                                                                        .month ==
                                                                    deadline
                                                                        .month) {
                                                                  for (int i =
                                                                          0;
                                                                      i < remainingWeeksFromFirstWeekToDeadline;
                                                                      i++) {
                                                                    if (firstWeekOfNextMonth.add(Duration(days: (i + 1) * 7)).day <=
                                                                            deadline
                                                                                .day &&
                                                                        deadline.month ==
                                                                            nextMonth.month) {
                                                                      remainingWeeksFromFirstWeekToNextMonth++;
                                                                    }
                                                                  }
                                                                } else if (nextMonth
                                                                        .month <
                                                                    deadline
                                                                        .month) {
                                                                  for (int i =
                                                                          0;
                                                                      i < remainingWeeksFromFirstWeekToDeadline;
                                                                      i++) {
                                                                    if (firstWeekOfNextMonth
                                                                            .add(Duration(
                                                                                days: (i + 1) *
                                                                                    7))
                                                                            .month ==
                                                                        nextMonth
                                                                            .month) {
                                                                      remainingWeeksFromFirstWeekToNextMonth++;
                                                                    }
                                                                  }
                                                                }

                                                                final eventList =
                                                                    List.generate(
                                                                        remainingWeeksFromFirstWeekToNextMonth,
                                                                        (index) {
                                                                  return Event()
                                                                    ..periodicChildId =
                                                                        event.id
                                                                    ..title =
                                                                        event
                                                                            .title
                                                                    ..content =
                                                                        event
                                                                            .content
                                                                    ..from = event
                                                                        .from
                                                                        ?.copyWith(
                                                                      month: firstWeekOfNextMonth
                                                                          .month,
                                                                      day: firstWeekOfNextMonth
                                                                          .add(Duration(
                                                                              days: (index + 1) * 7))
                                                                          .day,
                                                                      isUtc:
                                                                          false,
                                                                    )
                                                                    ..to = event
                                                                        .to
                                                                        ?.copyWith(
                                                                      month: firstWeekOfNextMonth
                                                                          .month,
                                                                      day: firstWeekOfNextMonth
                                                                          .add(Duration(
                                                                              days: (index + 1) * 7))
                                                                          .day,
                                                                      isUtc:
                                                                          false,
                                                                    )
                                                                    ..fiveMinute =
                                                                        event
                                                                            .fiveMinute
                                                                    ..tenMinute =
                                                                        event
                                                                            .tenMinute
                                                                    ..half =
                                                                        event
                                                                            .half
                                                                    ..everyMonth =
                                                                        event
                                                                            .everyMonth
                                                                    ..everyWeek =
                                                                        event
                                                                            .everyWeek
                                                                    ..dayOfWeek =
                                                                        event
                                                                            .dayOfWeek
                                                                    ..deadline =
                                                                        event
                                                                            .deadline
                                                                    ..createdAt =
                                                                        firstWeekOfNextMonth.copyWith(
                                                                            day:
                                                                                firstWeekOfNextMonth.day + (index + 1) * 7);
                                                                }).nonNulls.toList();

                                                                ref
                                                                    .read(scheduleProvider
                                                                        .notifier)
                                                                    .updateEvent(
                                                                        event
                                                                          ..createdPeriodicEventDays
                                                                              .add(nextMonth)
                                                                          ..from = event
                                                                              .from
                                                                              ?.copyWith(
                                                                            month:
                                                                                firstWeekOfNextMonth.month,
                                                                            day:
                                                                                firstWeekOfNextMonth.day,
                                                                            isUtc:
                                                                                false,
                                                                          )
                                                                          ..to = event
                                                                              .to
                                                                              ?.copyWith(
                                                                            month:
                                                                                firstWeekOfNextMonth.month,
                                                                            day:
                                                                                firstWeekOfNextMonth.day,
                                                                            isUtc:
                                                                                false,
                                                                          )
                                                                          ..createdAt =
                                                                              firstWeekOfNextMonth);

                                                                eventList.forEach(ref
                                                                    .read(scheduleProvider
                                                                        .notifier)
                                                                    .saveEvent);
                                                              } else if (selectDay
                                                                      .month ==
                                                                  deadline
                                                                      .month) {
                                                                ref
                                                                    .read(scheduleProvider
                                                                        .notifier)
                                                                    .removeEvent(
                                                                        event);
                                                              }
                                                            } else {
                                                              ref
                                                                  .read(scheduleProvider
                                                                      .notifier)
                                                                  .removeEvent(
                                                                      event);
                                                            }
                                                          } else {
                                                            ref
                                                                .read(scheduleProvider
                                                                    .notifier)
                                                                .removeEvent(
                                                                    event);
                                                          }
                                                        }
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                                route.isFirst);
                                                      },
                                                      child: const Text(
                                                          'この繰り返しの予定日のみ削除する',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    TextButton(
                                                      onPressed: () {
                                                        final events = ref.read(
                                                            scheduleProvider);

                                                        if (event.periodicId !=
                                                            null) {
                                                          final children = events
                                                              .where((child) =>
                                                                  child
                                                                      .periodicChildId ==
                                                                  event.id);

                                                          children.forEach(ref
                                                              .read(
                                                                  scheduleProvider
                                                                      .notifier)
                                                              .removeEvent);

                                                          ref
                                                              .read(
                                                                  scheduleProvider
                                                                      .notifier)
                                                              .removeEvent(
                                                                  event);
                                                        } else {
                                                          final children = events
                                                              .where((child) =>
                                                                  child
                                                                      .periodicChildId ==
                                                                  event
                                                                      .periodicChildId);

                                                          children.forEach(ref
                                                              .read(
                                                                  scheduleProvider
                                                                      .notifier)
                                                              .removeEvent);

                                                          final parent = events
                                                              .firstWhereOrNull(
                                                                  (ev) =>
                                                                      ev.id ==
                                                                      event
                                                                          .periodicChildId);

                                                          if (parent != null) {
                                                            ref
                                                                .read(scheduleProvider
                                                                    .notifier)
                                                                .removeEvent(
                                                                    parent);
                                                          }
                                                        }

                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                                route.isFirst);
                                                      },
                                                      child: const Text(
                                                          'この繰り返しの予定を全て削除する',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ])
                                            else
                                              TextButton(
                                                onPressed: () async {
                                                  ref
                                                      .read(scheduleProvider
                                                          .notifier)
                                                      .removeEvent(event);

                                                  final localNotification =
                                                      LocalNotification();
                                                  final notificationRequests =
                                                      await localNotification
                                                          .getPendingNotificationRequests();

                                                  final deleteTargetIds = [];
                                                  for (final pending
                                                      in notificationRequests) {
                                                    final notificationDateTime =
                                                        DateTime.tryParse(
                                                            pending.payload!);

                                                    if (notificationDateTime !=
                                                        null) {
                                                      final local =
                                                          notificationDateTime
                                                              .toLocal();

                                                      final isExists = [
                                                        local.add(
                                                            const Duration(
                                                                minutes: 5)),
                                                        local.add(
                                                            const Duration(
                                                                minutes: 10)),
                                                        local.add(
                                                            const Duration(
                                                                minutes: 30)),
                                                      ].any((time) =>
                                                          time.isAtSameMomentAs(
                                                              event.from!));

                                                      if (isExists) {
                                                        deleteTargetIds
                                                            .add(pending.id);
                                                      }
                                                    }
                                                  }
                                                  if (deleteTargetIds
                                                      .isNotEmpty) {
                                                    await Future.wait(deleteTargetIds
                                                        .map((deleteId) =>
                                                            localNotification
                                                                .cancelNotifications(
                                                                    deleteId)));
                                                  }

                                                  if (mounted) {
                                                    Navigator.of(context)
                                                        .popUntil((route) =>
                                                            route.isFirst);
                                                  }
                                                },
                                                child: const Text('削除する',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("キャンセル"),
                                            )
                                          ])
                                    ]));
                          });
                    },
                    child: const Icon(Icons.delete)),
                const Spacer(),
                FilledButton(
                    onPressed: () {
                      if (form.currentState!.validate()) {
                        form.currentState!.save();
                        final [String title, String? content] = saveTexts;
                        final selectday = ref.read(selectDayProvider);
                        final DateTime? from = saveFromTime != null
                            ? selectday.copyWith(
                                hour: saveFromTime!.hour,
                                minute: saveFromTime!.minute,
                                isUtc: false)
                            : null;
                        final DateTime? to = saveToTime != null
                            ? selectday.copyWith(
                                hour: saveToTime!.hour,
                                minute: saveToTime!.minute,
                                isUtc: false)
                            : null;

                        final events = ref.read(scheduleProvider);

                        event
                          ..title = title
                          ..content = content
                          ..from = from ?? event.from
                          ..to = to ?? event.to
                          ..createdAt = event.createdAt;

                        if (event.everyMonth || event.everyWeek) {
                          if (event.periodicId == null) {
                            final periodicParent = events.firstWhere(
                                (ev) => ev.id == event.periodicChildId);

                            periodicParent
                              ..title = event.title
                              ..content = event.content
                              ..from = from ?? event.from
                              ..to = to ?? event.to
                              ..createdAt = periodicParent.createdAt;

                            final periodicChildren = events.where((ev) =>
                                ev.periodicChildId == event.periodicChildId);

                            for (final child in periodicChildren) {
                              child
                                ..title = event.title
                                ..content = event.content
                                ..from = from ?? event.from
                                ..to = to ?? event.to
                                ..createdAt = child.createdAt;
                            }

                            [periodicParent, ...periodicChildren].forEach(ref
                                .read(scheduleProvider.notifier)
                                .updateEvent);
                          } else {
                            final periodicChildren = events
                                .where((ev) => ev.periodicChildId == event.id);

                            for (final child in periodicChildren) {
                              child
                                ..title = event.title
                                ..content = event.content
                                ..from = from ?? event.from
                                ..to = to ?? event.to
                                ..createdAt = child.createdAt;
                            }

                            [event, ...periodicChildren].forEach(ref
                                .read(scheduleProvider.notifier)
                                .updateEvent);
                          }
                        } else {
                          ref
                              .read(scheduleProvider.notifier)
                              .updateEvent(event);
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Icon(Icons.check)),
                const SizedBox(width: 20)
              ]),
            ])));
  }
}
