import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/task.dart';
import '../../../pet/model/pet.dart';
import '../task_item.dart';

class TimeInput extends ConsumerStatefulWidget {
  const TimeInput(this.pet, this.task, {super.key});

  final Pet pet;
  final Task? task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TimeInputState();
}

class TimeInputState extends ConsumerState<TimeInput>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final fromController = TextEditingController();
  final toController = TextEditingController();
  final now = DateTime.now();
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  int diff(fromHour, fromMinute, toHour, toMinute) {
    final from = now.copyWith(hour: fromHour, minute: fromMinute);
    final to = now.copyWith(hour: toHour, minute: toMinute);

    final deffAmount = to.difference(from).inMinutes;

    return deffAmount;
  }

  @override
  Widget build(context) {
    super.build(context);

    final amount = ref.watch(amountProvider);

    TimeOfDay? fromTime = ref.watch(tmpFromTimeProvider);
    TimeOfDay? toTime = ref.watch(tmpToTimeProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((fromTime, toTime)
          case (
            TimeOfDay(hour: final fromHour, minute: final fromMinute),
            (TimeOfDay(hour: final toHour, minute: final toMinute))
          )) {
        ref
            .read(amountProvider.notifier)
            .update((state) => diff(fromHour, fromMinute, toHour, toMinute));
      }
    });

    return Container(
        padding: const EdgeInsets.only(top: 0, bottom: 10),
        child: SizedBox(
            width: 210,
            // color: Colors.blue.shade100,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 180,
                      height: 70,
                      // color: Colors.blue.shade200,
                      child: Form(
                          key: form,
                          child: Row(children: [
                            Flexible(
                              child: GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        initialEntryMode:
                                            TimePickerEntryMode.input);

                                    if (selectedTime case TimeOfDay()) {
                                      if (!mounted) return;

                                      fromController.text =
                                          selectedTime.format(context);
                                      ref
                                          .read(tmpFromTimeProvider.notifier)
                                          .update((state) => selectedTime);
                                    }
                                  },
                                  child: TextFormField(
                                    controller: fromController,
                                    enabled: false,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    decoration: const InputDecoration(
                                      labelText: '開始時間',
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 40),
                            Flexible(
                              child: GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        initialEntryMode:
                                            TimePickerEntryMode.input);

                                    if (selectedTime case TimeOfDay()) {
                                      if (!mounted) return;

                                      toController.text =
                                          selectedTime.format(context);
                                      ref
                                          .read(tmpToTimeProvider.notifier)
                                          .update((state) => selectedTime);
                                    }
                                  },
                                  child: TextFormField(
                                    controller: toController,
                                    enabled: false,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    decoration: const InputDecoration(
                                      labelText: '終了時間',
                                    ),
                                  )),
                            ),
                          ]))),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${amount == 0 ? "--" : amount}'),
                    const Text(' '),
                    Text(widget.task?.unit ?? "")
                  ]),
                ])));
  }
}
