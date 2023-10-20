import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../layout/home.dart';
import '../app.dart';

import '../features/task/ui/memo_list_item.dart';

import '../features/pet/application/pet_provider.dart';
import '../features/task/application/task_provider.dart';

/*todo:
共有ボタンを付けたらどうか？


 */

final isAddMemoDisplay = StateProvider.autoDispose((ref) => false);

class TimeLine extends ConsumerWidget {
  const TimeLine({super.key});

  @override
  Widget build(context, ref) {
    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();

    if (pets.isEmpty) {
      return const SliverToBoxAdapter();
    }

    final pet = pets[petIndex];

    final taskWorker = ref.watch(taskProvider.notifier);

    final petTaskActivities = taskWorker.findActivityAllByPetId(pet.id);

    final timelineSwitch = ref.watch(timelineSwitchProvider);

    bool isSameDay(DateTime? a, DateTime? b) {
      if (a == null || b == null) {
        return false;
      }

      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    getTimelineActivities(timelineSwitch) {
      final today = DateTime.now();

      return switch (timelineSwitch) {
        2 => petTaskActivities
            .where((activity) => isSameDay(activity!.createdAt, today))
            .toList(),
        1 => petTaskActivities
            .where((activity) => isSameDay(
                activity!.createdAt, today.subtract(const Duration(days: 1))))
            .toList(),
        0 => petTaskActivities
            .where((activity) => isSameDay(
                activity!.createdAt, today.subtract(const Duration(days: 2))))
            .toList(),
        _ => []
      };
    }

    final timelineActivities = getTimelineActivities(timelineSwitch);

    return SliverList.builder(
      itemCount: timelineActivities.length,
      itemBuilder: (context, index) {
        final activity = timelineActivities[index];
        // final DateTime(:hour, :minute) = activity!.createdAt!;

        return Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: Column(children: [
              ListTile(
                  onLongPress: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                              height: 130,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text('削除しますか？'),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(taskProvider.notifier)
                                                  .deleteActivity(activity);

                                              ref
                                                  .read(timelineSwitchProvider
                                                      .notifier)
                                                  .update((state) => state + 1);

                                              // ref.invalidate(
                                              //     timelineSwitchProvider);
                                              ref
                                                  .read(timelineSwitchProvider
                                                      .notifier)
                                                  .update((state) =>
                                                      timelineSwitch);

                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('削除する',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              context,
                                            ),
                                            child: const Text("キャンセル"),
                                          )
                                        ])
                                  ]));
                        });
                  },
                  minLeadingWidth: 70,
                  leading: SizedBox(
                      width: 65,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                DateFormat('H : mm')
                                    .format(activity!.createdAt!),
                                style: const TextStyle(fontSize: 12)),
                            Stack(children: [
                              Container(
                                height: 11,
                                width: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent.shade100,
                                ),
                              ),
                              Positioned(
                                  top: 1,
                                  left: 1,
                                  child: Container(
                                    height: 9,
                                    width: 9,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ref.watch(themeModeProvider)
                                          ? Colors.white.withOpacity(.6)
                                          : Colors.black.withOpacity(.8),
                                    ),
                                  )),
                            ]),
                          ])),
                  title: Text(activity!.taskName),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: () {
                          if (activity.memo == '' &&
                              activity.headerImagePath == null) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Consumer(
                                    builder: (context, ref, _) {
                                      return SimpleDialog(children: [
                                        if (!ref.watch(isAddMemoDisplay))
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text('メモがありません'),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    ref
                                                        .read(isAddMemoDisplay
                                                            .notifier)
                                                        .update(
                                                            (state) => true);
                                                  },
                                                )
                                              ])
                                        else
                                          MemoListItem(pet, activity)
                                      ]);
                                    },
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                      children: [MemoListItem(pet, activity)]);
                                });
                          }
                        },
                        icon: const Icon(Icons.edit, size: 16)),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${activity.amount} ${activity.unit}'),
                          if (activity.cost != null) Text('${activity.cost} 円')
                        ])
                  ])),
              if (index + 1 < timelineActivities.length)
                IntrinsicHeight(
                    child: Row(children: [
                  const SizedBox(width: 67),
                  VerticalDivider(
                    thickness: 1.2,
                    color:
                        Theme.of(context).colorScheme.onPrimary.withOpacity(.1),
                  ),
                  const Expanded(child: SizedBox(height: 40))
                ])),
              if (index == timelineActivities.length - 1)
                const SizedBox(height: 15)
            ]));
      },
    );
  }
}
