import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../layout/summary.dart';
import 'table.dart';

import '../features/pet/model/pet.dart';

import '../features/task/application/task_provider.dart';

import '../features/task/ui/memo_list_item.dart';

import '../features/task/model/task_activity.dart';

final indexProvider = StateProvider.autoDispose((ref) => 0);

final isYearProvider = StateProvider.autoDispose((ref) => false);

class ActivityList extends ConsumerWidget {
  const ActivityList(this.name, this.pet, {super.key});
  final String? name;
  final Pet? pet;

  @override
  Widget build(context, ref) {
    final isCostDisplay = ref.watch(isCostDisplayProvider);
    final now = ref.watch(dateTimeController);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final categoryId = ref.watch(categoryIdController);

    final petTaskWorker = ref.watch(taskProvider.notifier);

    final petTaskActivities =
        petTaskWorker.findActivityAllByPetId(pet!.id).nonNulls.toList();

    final acitivities = petTaskActivities
        .where((activity) => activity.taskName == name)
        .where((activity) => now.year == activity.createdAt!.year)
        .where((activity) => now.month == activity.createdAt!.month)
        .where((activity) => activity.categoryId == categoryId)
        .toList();

    final rows = List.generate(endOfMonth.day, (index) {
      final samedayActivities = acitivities
          .where((activity) => activity.createdAt?.day == index + 1)
          .toList();

      int totalAmountPerSameDay =
          samedayActivities.fold(0, (v1, v2) => v1 + (v2.amount ?? 0));

      int totalCostPerSameDay =
          samedayActivities.fold(0, (v1, v2) => v1 + (v2.cost ?? 0));

      return isCostDisplay ? totalCostPerSameDay : totalAmountPerSameDay;
    });

    rows.insert(0, rows.reduce((v1, v2) => v1 + v2));

    final memosActivities = petTaskActivities
        .where((activity) =>
            activity.memo != null &&
                activity.memo != '' &&
                activity.taskName == name ||
            activity.headerImagePath != null && activity.taskName == name)
        .toList();

    final isYear = ref.watch(isYearProvider);

    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(name!), actions: [
          ref.watch(indexProvider) == 0
              ? TextButton.icon(
                  onPressed: () {
                    ref
                        .read(isCostDisplayProvider.notifier)
                        .update((state) => !state);
                  },
                  icon: isCostDisplay
                      ? const Icon(Icons.assignment_outlined)
                      : const Icon(Icons.calculate_outlined),
                  label: isCostDisplay ? const Text('タスク') : const Text('コスト'),
                )
              : const SizedBox()
        ]),
        body: IndexedStack(index: ref.watch(indexProvider), children: [
          Column(children: [
            SizedBox(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              TextButton.icon(
                  onPressed: () {
                    ref.read(indexProvider.notifier).update((state) => 1);
                  },
                  icon: const Icon(Icons.create_outlined),
                  label: const Text('メモ一覧')),
              const Spacer(),
              InkWell(
                  onTap: () => ref
                      .read(isYearProvider.notifier)
                      .update((state) => !state),
                  child: Text('${now.year}年',
                      style: const TextStyle(fontSize: 16, letterSpacing: 1))),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  ref
                      .read(dateTimeController.notifier)
                      .update((state) => DateTime(state.year, state.month - 1));
                },
                icon: const Icon(Icons.navigate_before),
              ),
              const SizedBox(width: 12),
              Text('${now.month}月', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: () => ref
                    .read(dateTimeController.notifier)
                    .update((state) => DateTime(state.year, state.month + 1)),
              ),
              const SizedBox(width: 5),
            ])),
            if (isYear)
              Flexible(
                  child: YearPicker(
                onChanged: (value) {
                  ref
                      .read(dateTimeController.notifier)
                      .update((state) => value);

                  ref.read(isYearProvider.notifier).update((state) => false);
                },
                initialDate: now,
                firstDate: DateTime(2023),
                lastDate: DateTime(now.year + 20),
                selectedDate: now,
              )),
            Flexible(
                child: ListView.separated(
              shrinkWrap: true,
              itemCount: rows.length,
              itemBuilder: (context, dayIndex) {
                return ListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    onTap: () {},
                    leading: Container(
                        height: 50,
                        width: 40,
                        color: Theme.of(context).highlightColor,
                        child: Center(
                            child: dayIndex == 0
                                ? const Text('合計',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                                : Text('$dayIndex'))),
                    title: Text(rows[dayIndex].toString()));
              },
              separatorBuilder: (context, index) => const Divider(
                height: 0.1,
                thickness: .1,
              ),
            ))
          ]),
          Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                    onPressed: () =>
                        ref.read(indexProvider.notifier).update((state) => 0),
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('タスク一覧'))),
            if (memosActivities.isEmpty)
              const SizedBox(
                  height: 500, child: Center(child: Text('メモがありません')))
            else
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: memosActivities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(children: [
                                  MemoListItem(pet!, memosActivities[index])
                                ])),
                        contentPadding: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 10),
                        leading: switch (memosActivities[index]) {
                          TaskActivity(:final String headerImagePath)
                              when File(headerImagePath).existsSync() =>
                            Image.file(File(headerImagePath)),
                          _ => null
                        },
                        title: Text(memosActivities[index].memo!));
                  })
          ])
        ]));
  }
}
