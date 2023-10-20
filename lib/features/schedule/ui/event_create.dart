import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
// ignore: unused_import
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

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

final notifyMinuteErrorControllerProvider =
    StateProvider.autoDispose.family((index, ref) => '');

final deadlineProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

class EventCreate extends ConsumerStatefulWidget {
  const EventCreate({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EventCreateState();
}

class EventCreateState extends ConsumerState<EventCreate> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final deadlineController = TextEditingController();

  final saveTexts = [];
  TimeOfDay? saveFromTime;
  TimeOfDay? saveToTime;

  void _onTextChanged() {
    ref.invalidate(notifyControllerProvider);
  }

  @override
  void initState() {
    fromController.addListener(_onTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    fromController.removeListener(_onTextChanged);
    fromController.dispose();
    toController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final form = GlobalKey<FormState>();
    final selectDay = ref.watch(selectDayProvider);
    final now = DateTime.now();

    return SizedBox(
        width: 300,
        child: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Align(
                  widthFactor: 2.2,
                  alignment: Alignment.centerRight,
                  child: Text(
                      DateFormat('yyyy-MM-dd (E)', 'ja_JP').format(selectDay))),
              const SizedBox(height: 20),
              SizedBox(
                  width: 280,
                  child: TextFormField(
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
              Row(children: [
                Consumer(
                  builder: (context, ref, _) {
                    final periodicies = ref.watch(periodicControllerProvider);
                    final deadlineWorker = ref.watch(deadlineProvider.notifier);
                    final [
                      {'timing': _, 'select': everyWeek as bool},
                      {'timing': _, 'select': everyMonth as bool}
                    ] = ref.watch(periodicControllerProvider);

                    return Flexible(
                        child: ExpansionTile(
                            shape: const Border(),
                            title: const Text('繰り返し'),
                            children: [
                          ...periodicies.mapIndexed((index, periodic) {
                            final [timing, select] = periodic.keys.toList();
                            return CheckboxListTile(
                              title: Text('${periodic[timing]}'),
                              subtitle: periodic[timing] == '毎週'
                                  ? Text(
                                      '(${'月火水木金土日'[selectDay.weekday - 1]}曜)',
                                      style: const TextStyle(fontSize: 11))
                                  : Text('(${selectDay.day}日)',
                                      style: const TextStyle(fontSize: 11)),
                              value: periodic[select] as bool,
                              onChanged: (bool? value) {
                                for (final periodic in periodicies) {
                                  periodic[select] = false;
                                }
                                periodic[select] = value;
                                ref
                                    .read(periodicControllerProvider.notifier)
                                    .update(
                                        (state) => state = [...periodicies]);
                              },
                            );
                          }).toList(),
                          // const Divider(
                          //     indent: 15, endIndent: 30, thickness: .1),
                          // CheckboxListTile(
                          //     title: const Text('期限なし'),
                          //     value: deadline != null ? false : true,
                          //     onChanged: (bool? value) {
                          //       if (value!) {
                          //         ref
                          //             .read(deadlineProvider.notifier)
                          //             .update((state) => null);
                          //         deadlineController.text = '';
                          //       }
                          //     }),
                          Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.only(left: 17, right: 39),
                              child: SizedBox(
                                  width: 78,
                                  child: GestureDetector(
                                      onTap: everyWeek || everyMonth
                                          ? () async {
                                              final selectedDeadline =
                                                  await showDatePicker(
                                                      context: context,
                                                      firstDate: everyWeek
                                                          ? selectDay.copyWith(
                                                              day: selectDay
                                                                      .day +
                                                                  7)
                                                          : selectDay.copyWith(
                                                              month: selectDay
                                                                      .month +
                                                                  1),
                                                      lastDate:
                                                          DateTime(2050, 1, 1),
                                                      initialDate: everyWeek
                                                          ? selectDay.copyWith(
                                                              day: selectDay
                                                                      .day +
                                                                  7)
                                                          : selectDay.copyWith(
                                                              month: selectDay
                                                                      .month +
                                                                  1));

                                              if (selectedDeadline != null) {
                                                deadlineController.text =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            selectedDeadline);

                                                deadlineWorker.update((state) =>
                                                    selectedDeadline);
                                              }
                                            }
                                          : null,
                                      child: TextFormField(
                                          controller: deadlineController,
                                          enabled: false,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: '繰り返し期限',
                                            errorMaxLines: 3,
                                          ),
                                          validator: (String? value) {
                                            if (everyWeek || everyMonth) {
                                              if (value!.isEmpty) {
                                                return '繰り返しは期限が必要です';
                                              }
                                            }
                                            return null;
                                          }))))
                        ]));
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final notifies = ref.watch(notifyControllerProvider);

                    return Flexible(
                        child: ExpansionTile(
                            shape: const Border(),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            childrenPadding: const EdgeInsets.only(left: 5),
                            title: const Text('事前通知'),
                            children: [
                          ...notifies.mapIndexed((index, notify) {
                            final [timing, select] = notify.keys.toList();

                            final error = ref.watch(
                                notifyMinuteErrorControllerProvider(index));

                            return CheckboxListTile(
                              title: Text('${notify[timing]}分前'),
                              isError: error.isNotEmpty ? true : false,
                              subtitle: switch (error.isNotEmpty) {
                                true => Text(error,
                                    style: const TextStyle(color: Colors.red)),
                                _ => null
                              },
                              value: notify[select] as bool,
                              onChanged: (bool? isChecked) {
                                final notifyMinuteErrorController = ref.read(
                                    notifyMinuteErrorControllerProvider(index)
                                        .notifier);
                                final notifyController =
                                    ref.read(notifyControllerProvider.notifier);
                                if (selectDay.day < now.day) {
                                  notifyMinuteErrorController.update(
                                      (state) => '本日よりも前に通知を送ることはできません');
                                  return;
                                }

                                if (isChecked!) {
                                  if (now.day < selectDay.day) {
                                    notifyMinuteErrorController
                                        .update((state) => '');

                                    notify[select] = isChecked;
                                    notifyController.update(
                                        (state) => state = [...notifies]);
                                  } else if (now.day == selectDay.day) {
                                    if (saveFromTime != null) {
                                      final TimeOfDay(:hour, :minute) =
                                          saveFromTime!;

                                      final from = selectDay.copyWith(
                                          hour: hour, minute: minute);
                                      final isBefore = now.isBefore(
                                          from.subtract(Duration(
                                              minutes: int.parse(
                                                  notify[timing] as String))));

                                      if (!isBefore) {
                                        notifyMinuteErrorController.update(
                                            (state) =>
                                                '予定開始時間を現在時間より${notify[timing]}分以上空けて下さい');
                                        return;
                                      } else {
                                        notifyMinuteErrorController
                                            .update((state) => '');

                                        notify[select] = isChecked;
                                        notifyController.update(
                                            (state) => state = [...notifies]);
                                      }
                                    } else {
                                      notify[select] = isChecked;
                                      notifyController.update(
                                          (state) => state = [...notifies]);
                                    }
                                  }
                                } else {
                                  notify[select] = isChecked;
                                  notifyController
                                      .update((state) => state = [...notifies]);
                                }
                              },
                            );
                          }).toList(),
                          const SizedBox(height: 10)
                        ]));
                  },
                ),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 78,
                  child: GestureDetector(
                      onTap: () async {
                        final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input);

                        if (mounted && selectedTime != null) {
                          fromController.text = selectedTime.format(context);
                        }
                        saveFromTime = selectedTime;
                      },
                      child: TextFormField(
                          controller: fromController,
                          enabled: false,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            hintText: '開始時間',
                            errorMaxLines: 3,
                          ),
                          validator: (String? value) {
                            final [
                              {'timing': _, 'select': isFiveMinute as bool},
                              {'timing': _, 'select': isTenMinute as bool},
                              {'timing': _, 'select': isHalfMinute as bool}
                            ] = ref.read(notifyControllerProvider);

                            if (value == '' &&
                                [isFiveMinute, isTenMinute, isHalfMinute]
                                    .any((isSelected) => isSelected)) {
                              return '開始時間の入力がありません';
                            }

                            if ((saveFromTime, saveToTime)
                                case (TimeOfDay from, final TimeOfDay to)) {
                              final fromTime = selectDay.copyWith(
                                  hour: from.hour, minute: from.minute);

                              final toTime = selectDay.copyWith(
                                  hour: to.hour, minute: to.minute);

                              if (!fromTime.isBefore(toTime)) {
                                return '終了時間より後にはできません';
                              }
                            }

                            return null;
                          })),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: 78,
                  child: GestureDetector(
                      onTap: () async {
                        final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input);

                        if (mounted && selectedTime != null) {
                          toController.text = selectedTime.format(context);
                        }
                        saveToTime = selectedTime;
                      },
                      child: TextFormField(
                          controller: toController,
                          enabled: false,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            hintText: '終了時間',
                            errorMaxLines: 3,
                          ),
                          validator: (String? value) {
                            if ((saveFromTime, saveToTime)
                                case (TimeOfDay from, final TimeOfDay to)) {
                              final fromTime = selectDay.copyWith(
                                  hour: from.hour, minute: from.minute);

                              final toTime = selectDay.copyWith(
                                  hour: to.hour, minute: to.minute);

                              if (!toTime.isAfter(fromTime)) {
                                return '開始時間より前にはできません';
                              }
                            }
                            return null;
                          })),
                ),
                const SizedBox(width: 20),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                  width: 280,
                  child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'メモ',
                        contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      ),
                      maxLines: null,
                      onSaved: (String? value) {
                        saveTexts.add(value);
                      })),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                FilledButton(
                  onPressed: () async {
                    if (form.currentState!.validate()) {
                      form.currentState!.save();
                      final [String title, String? content] = saveTexts;
                      final selectday = ref.read(selectDayProvider);
                      final event = Event();
                      final DateTime? from = saveFromTime != null
                          ? selectday.copyWith(
                              hour: saveFromTime!.hour,
                              minute: saveFromTime!.minute)
                          : null;
                      final DateTime? to = saveToTime != null
                          ? selectday.copyWith(
                              hour: saveToTime!.hour,
                              minute: saveToTime!.minute)
                          : null;

                      final [
                        {'timing': _, 'select': isFiveMinute as bool},
                        {'timing': _, 'select': isTenMinute as bool},
                        {'timing': _, 'select': isHalfMinute as bool}
                      ] = ref.read(notifyControllerProvider);

                      final [
                        {'timing': _, 'select': everyWeek as bool},
                        {'timing': _, 'select': everyMonth as bool}
                      ] = ref.read(periodicControllerProvider);

                      final deadline = ref.watch(deadlineProvider);
                      int remainingMonthsFromSelectMonthToDeadlineMonth = 0;
                      if (deadline != null) {
                        for (int i = selectDay.month;
                            i <= deadline.month;
                            i++) {
                          remainingMonthsFromSelectMonthToDeadlineMonth++;
                        }
                      }
                      final months = List.generate(
                          remainingMonthsFromSelectMonthToDeadlineMonth,
                          (index) => selectDay.copyWith(
                              month: selectDay.month + index));

                      event
                        ..periodicId =
                            everyWeek || everyMonth ? const Uuid().v4() : null
                        ..createdPeriodicEventDays = everyWeek
                            ? <DateTime>[selectday]
                            : everyMonth
                                ? months
                                : []
                        ..title = title
                        ..content = content
                        ..from = from
                        ..to = to
                        ..fiveMinute = isFiveMinute
                        ..tenMinute = isTenMinute
                        ..half = isHalfMinute
                        ..everyMonth = everyMonth
                        ..everyWeek = everyWeek
                        ..dayOfWeek = everyWeek ? selectday.weekday : 0
                        ..deadline = deadline
                        ..createdAt = selectday;

                      ref.read(scheduleProvider.notifier).saveEvent(event);

                      final selectedMinutes = ref
                          .read(notifyControllerProvider)
                          .map((entry) {
                            final isMinuteSelected = entry['select'] as bool;

                            if (isMinuteSelected) {
                              return entry['timing'] as String;
                            }
                          })
                          .nonNulls
                          .toList();

                      if (selectedMinutes.isNotEmpty) {
                        final notification = LocalNotification();
                        try {
                          final List<tz.TZDateTime?> reminderDateTimes =
                              selectedMinutes
                                  .map((minute) {
                                    return notification.getReminderTime(
                                        int.parse(minute), from!);
                                  })
                                  .nonNulls
                                  .toList();

                          if (reminderDateTimes.isNotEmpty) {
                            Future.forEach(reminderDateTimes,
                                (reminderDateTime) async {
                              await notification.schedule(reminderDateTime!,
                                  await notification.getCreateId(),
                                  dayOfWeekAndTime: everyWeek ? true : false);
                            });
                          } else {
                            throw Exception('事前の通知時間が有効ではありません');
                          }
                        } catch (e) {
                          print(e);
                        }

                        if (everyWeek) {
                          int remainingWeeksInSelectedMonth = 0;
                          if (deadline != null) {
                            if (selectDay.month < deadline.month) {
                              remainingWeeksInSelectedMonth = ref
                                  .read(scheduleProvider.notifier)
                                  .getCountRemainingWeeks(
                                      selectDay,
                                      DateTime(selectDay.year,
                                          selectDay.month + 1, 0));
                            } else if (selectDay.month == deadline.month) {
                              remainingWeeksInSelectedMonth = ref
                                  .read(scheduleProvider.notifier)
                                  .getCountRemainingWeeks(selectDay, deadline);
                            }
                          }

                          final eventList = List.generate(
                              remainingWeeksInSelectedMonth + 1, (index) {
                            if (index == 0) {
                              return null;
                            }

                            return Event()
                              ..periodicChildId = ref
                                  .read(scheduleProvider.notifier)
                                  .findByPeriodicId(event.periodicId)!
                                  .id
                              ..title = title
                              ..content = content
                              ..from =
                                  from?.add(Duration(days: index * 7)) ?? from
                              ..to = to?.add(Duration(days: index * 7)) ?? to
                              ..fiveMinute = isFiveMinute
                              ..tenMinute = isTenMinute
                              ..half = isHalfMinute
                              ..everyMonth = everyMonth
                              ..everyWeek = everyWeek
                              ..dayOfWeek = selectday.weekday
                              ..deadline = deadline
                              ..createdAt =
                                  selectday.add(Duration(days: index * 7));
                          }).nonNulls.toList();

                          eventList.forEach(
                              ref.read(scheduleProvider.notifier).saveEvent);
                        } else if (everyMonth) {
                          final eventList = List.generate(
                              deadline!.month - selectday.month, (index) {
                            return Event()
                              ..periodicChildId = ref
                                  .read(scheduleProvider.notifier)
                                  .findByPeriodicId(event.periodicId)!
                                  .id
                              ..title = title
                              ..content = content
                              ..from = from?.copyWith(
                                      year: from.year,
                                      month: from.month + index + 1) ??
                                  from
                              ..to = to?.copyWith(
                                      year: to.year,
                                      month: to.month + index + 1) ??
                                  to
                              ..fiveMinute = isFiveMinute
                              ..tenMinute = isTenMinute
                              ..half = isHalfMinute
                              ..everyMonth = everyMonth
                              ..everyWeek = everyWeek
                              ..dayOfWeek = everyWeek ? selectday.weekday : 0
                              ..deadline = deadline
                              ..createdAt = selectday.copyWith(
                                  month: now.month + index + 1,
                                  day: selectday.day);
                          });

                          eventList.forEach(
                              ref.read(scheduleProvider.notifier).saveEvent);
                        }
                      } else if (selectedMinutes.isEmpty) {
                        if (everyWeek) {
                          int remainingWeeksInSelectedMonth = 0;
                          if (deadline != null) {
                            final startEnd = DateTimeRange(
                                start: DateTime(selectDay.year, selectDay.month,
                                    selectDay.day),
                                // .copyWith(isUtc: false),
                                end: deadline);
                            int weekCountNumber = startEnd.duration.inDays ~/ 7;

                            for (var i = 0; i < weekCountNumber; i++) {
                              if (selectDay.month <
                                  selectDay
                                      .add(Duration(days: (i + 1) * 7))
                                      .month) {
                                break;
                              }

                              remainingWeeksInSelectedMonth++;
                            }
                          }

                          final eventList = List.generate(
                              remainingWeeksInSelectedMonth + 1, (index) {
                            if (index == 0) {
                              return null;
                            }

                            return Event()
                              ..periodicChildId = ref
                                  .read(scheduleProvider.notifier)
                                  .findByPeriodicId(event.periodicId)!
                                  .id
                              ..title = title
                              ..content = content
                              ..from = from != null
                                  ? from.add(Duration(days: index * 7))
                                  : from
                              ..to = to != null
                                  ? to.add(Duration(days: index * 7))
                                  : to
                              ..fiveMinute = isFiveMinute
                              ..tenMinute = isTenMinute
                              ..half = isHalfMinute
                              ..everyMonth = everyMonth
                              ..everyWeek = everyWeek
                              ..dayOfWeek = selectday.weekday
                              ..deadline = deadline
                              ..createdAt =
                                  selectday.add(Duration(days: index * 7));
                          }).nonNulls.toList();

                          eventList.forEach(
                              ref.read(scheduleProvider.notifier).saveEvent);
                        } else if (everyMonth) {
                          final eventList = List.generate(
                              deadline!.month - selectday.month, (index) {
                            return Event()
                              ..periodicChildId = ref
                                  .read(scheduleProvider.notifier)
                                  .findByPeriodicId(event.periodicId)!
                                  .id
                              ..title = title
                              ..content = content
                              ..fiveMinute = isFiveMinute
                              ..tenMinute = isTenMinute
                              ..half = isHalfMinute
                              ..everyMonth = everyMonth
                              ..everyWeek = everyWeek
                              ..dayOfWeek = everyWeek ? selectday.weekday : 0
                              ..deadline = deadline
                              ..createdAt = selectday.copyWith(
                                  month: selectday.month + index + 1,
                                  day: selectday.day);
                          });

                          eventList.forEach(
                              ref.read(scheduleProvider.notifier).saveEvent);
                        }
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.check),
                ),
                const SizedBox(width: 20)
              ]),
            ])));
  }
}
