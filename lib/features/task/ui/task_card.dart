import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'dart:io';

import '../../category/application/category_provider.dart';
import '../../task/application/task_provider.dart';
import '../../task/application/priority_task_provider.dart';
import '../../pet/application/pet_provider.dart';

import '../../../layout/home.dart';

import '../../task/model/priority_task.dart';

import 'task_register.dart';

import 'package:reorderables/reorderables.dart';

import 'package:intl/intl.dart';

import '../ui/task_item.dart';

final selectedDateProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

final selectExpansionIndexProvider =
    StateProvider.autoDispose<int?>((ref) => -1);

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key});

  /*danger:
  タスクリストからでなくタスクカードから進んだタスクエディットはリビルドされるが更新されないので再読み込み必要
   */

  @override
  Widget build(context, ref) {
    final categories = ref
        .watch(categoryProvider)
        .nonNulls
        .where((category) => category.visible)
        .toList();
    final tasks =
        ref.watch(taskProvider).nonNulls.where((task) => task.visible);

    final pets = ref.watch(petProvider).nonNulls.toList();
    final petIndex = ref.watch(petIndexProvider);
    final pet = pets[petIndex];

    final priorityTasks = ref
        .watch(priorityTaskProvider)
        .nonNulls
        .where((priorityTask) => priorityTask.petId == pet.id)
        .toList();

    int getExecutedCount(taskId, petId) {
      final activities = ref.read(taskProvider.notifier).findActivityAll();
      final executedActivities =
          activities.where((act) => act.taskId == taskId).where((act) {
        final now = DateTime.now();
        final nowDate = DateTime(now.year, now.month, now.day);

        return act.createdAt!.isAfter(nowDate);
      }).where((act) => act.petId == petId);

      return executedActivities.length;
    }

    final reorderItems = List.generate(
        priorityTasks.length,
        (index) => Container(
              // color: Colors.red.shade50,
              child: Stack(children: [
                if (categories.isNotEmpty)
                  Container(
                      width: 110,
                      height: 170,
                      // color: Colors.blue.shade50,
                      child: Card(
                          elevation: 3,
                          // surfaceTintColor: Colors.transparent,
                          // color: Colors.red.shade100.withOpacity(.8),
                          // shadowColor: Colors.transparent,
                          child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(children: [
                                const SizedBox(height: 4),
                                Text(priorityTasks[index].name,
                                    // textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 12),
                                Row(children: [
                                  // Icon(Icons.update_outlined, size: 12),
                                  if (priorityTasks[index].dueDate
                                      case DateTime dueDate)
                                    Text(
                                        DateFormat.MEd('ja_JP').format(dueDate),
                                        style: switch (
                                            DateTime.now().isAfter(dueDate)) {
                                          true
                                              when priorityTasks[index]
                                                      .status !=
                                                  Status.completed =>
                                            const TextStyle(
                                              fontSize: 11,
                                              color: Colors.red,
                                            ),
                                          _ => const TextStyle(
                                              fontSize: 11,
                                            )
                                        })
                                  else
                                    const Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text('期日なし',
                                            style: TextStyle(
                                              fontSize: 11,
                                            )))
                                ]),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: priorityTasks[index].times == 0
                                        ? [
                                            const Text('未定',
                                                style: TextStyle(fontSize: 12))
                                          ]
                                        : [
                                            Text(
                                                ('${(priorityTasks[index].executed / (priorityTasks[index].times) * 100).toStringAsFixed(0)}%'),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                )),
                                            Text(
                                                '${priorityTasks[index].executed}/${priorityTasks[index].times}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ))
                                          ]),
                                const SizedBox(height: 6),
                                Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                      gradient: switch (
                                          priorityTasks[index].executed) {
                                    0 => const LinearGradient(
                                        colors: [Colors.white], stops: [0.0]),
                                    _ => LinearGradient(colors: [
                                        ...List.generate(
                                            priorityTasks[index].times,
                                            (progress) {
                                          if (progress <=
                                              (priorityTasks[index].executed -
                                                  1)) {
                                            return Colors.tealAccent;
                                          }
                                          return Colors.white;
                                        })
                                      ], stops: [
                                        ...List.generate(
                                            priorityTasks[index].times,
                                            (progress) {
                                          return (1 /
                                                      priorityTasks[index]
                                                          .times)
                                                  .toDouble() *
                                              (progress + 1);
                                        })
                                      ]),
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment:
                                        priorityTasks[index].status ==
                                                Status.completed
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 0, 3, 3),
                                        decoration:
                                            priorityTasks[index].status ==
                                                    Status.completed
                                                ? null
                                                : BoxDecoration(
                                                    color: switch (
                                                        priorityTasks[index]
                                                            .priority) {
                                                      Priority.high =>
                                                        Colors.redAccent,
                                                      Priority.middle =>
                                                        Colors.yellowAccent,
                                                      Priority.low =>
                                                        Colors.blueAccent,
                                                    },
                                                    shape: BoxShape.circle),
                                        child: priorityTasks[index].status ==
                                                Status.completed
                                            ? null
                                            : Text(
                                                switch (priorityTasks[index]
                                                    .priority) {
                                                  Priority.high =>
                                                    Priority.high.name,
                                                  Priority.middle =>
                                                    Priority.middle.name,
                                                  Priority.low =>
                                                    Priority.low.name,
                                                },
                                                style: const TextStyle(
                                                    fontSize: 11)),
                                      ),
                                      Container(
                                        padding: priorityTasks[index].status ==
                                                Status.completed
                                            ? const EdgeInsets.fromLTRB(
                                                29, 2, 27, 2)
                                            : null,
                                        decoration: priorityTasks[index]
                                                    .status ==
                                                Status.completed
                                            ? BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin:
                                                      FractionalOffset.topLeft,
                                                  end: FractionalOffset
                                                      .bottomRight,
                                                  colors: [
                                                    Colors.white,
                                                    Colors.cyan
                                                        .withOpacity(0.5),
                                                    Colors.purpleAccent
                                                        .withOpacity(0.4),
                                                    // Colors.pinkAccent.withOpacity(0.4),
                                                    Colors.pinkAccent
                                                        .withOpacity(0.85),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: priorityTasks[index]
                                                            .status ==
                                                        Status.completed
                                                    ? Border.all(
                                                        color:
                                                            Colors.transparent)
                                                    : null,
                                              )
                                            : null,
                                        child: Text(
                                            switch (
                                                priorityTasks[index].status) {
                                              Status status => status.name,
                                              _
                                                  when priorityTasks[index]
                                                          .executed !=
                                                      0 =>
                                                Status.progress.name,
                                              _ => Status.waiting.name
                                            },
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  priorityTasks[index].status ==
                                                          Status.completed
                                                      ? FontWeight.bold
                                                      : null,
                                              color:
                                                  priorityTasks[index].status ==
                                                          Status.completed
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                            )),
                                      ),
                                    ]),
                                const SizedBox(height: 30)
                              ])))),
                Positioned(
                    bottom: -4,
                    right: -4,
                    child: Transform.scale(
                        scale: .7,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                      children: [TaskRegister(index, pet.id)]);
                                }).then((value) {
                              final priorityTask = priorityTasks[index];

                              if (priorityTask.times <= priorityTask.executed &&
                                  priorityTask.status != Status.completed) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        content: const Text('ステータスを完了にしますか？'),
                                        actions: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final priorityTask =
                                                        priorityTasks[index];

                                                    ref
                                                        .read(
                                                            priorityTaskProvider
                                                                .notifier)
                                                        .updatePriorityTask(
                                                            priorityTask.copyWith(
                                                                status: Status
                                                                    .completed));

                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ])
                                        ]);
                                  },
                                );
                              }
                            });
                          },
                          // style: FilledButton.styleFrom(
                          //   foregroundColor: Colors.blue.shade50,
                          // ),
                          icon: const Icon(Icons.more_horiz_outlined),
                        ))),
                if (priorityTasks[index].status != Status.completed)
                  Positioned(
                      bottom: -4,
                      left: -8,
                      child: Transform.scale(
                          scale: .5,
                          child: OutlinedButton(
                            onPressed: () {
                              final priorityTask = priorityTasks[index];

                              final task = tasks.firstWhere(
                                  (task) => task.id == priorityTask.taskId);

                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return Transform.translate(
                                        offset: const Offset(0, 50),
                                        child: Column(children: [
                                          SizedBox(
                                              height: 670,
                                              child: Scaffold(
                                                  resizeToAvoidBottomInset:
                                                      false,
                                                  // backgroundColor: Colors.blue,
                                                  appBar: AppBar(
                                                      title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if (pet.headerImagePath
                                                                case final String
                                                                    path
                                                                when File(path)
                                                                    .existsSync())
                                                              CircleAvatar(
                                                                  backgroundImage:
                                                                      Image
                                                                          .file(
                                                                File(path),
                                                              ).image)
                                                            else
                                                              SizedBox(
                                                                  width: 90,
                                                                  child: Text(
                                                                      pet.name,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                            const SizedBox(
                                                                width: 10),
                                                            const Icon(
                                                                Icons
                                                                    .arrow_right,
                                                                size: 22),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(task.name,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13))
                                                          ]),
                                                      centerTitle: true,
                                                      actions: [
                                                        // Builder(
                                                        //     builder: (context) {
                                                        //   return TextButton(
                                                        //     onPressed: () =>
                                                        //         Scaffold.of(
                                                        //                 context)
                                                        //             .openEndDrawer(),
                                                        //     child: const Text(
                                                        //         '編集'),
                                                        //   );
                                                        // }),
                                                        const SizedBox(
                                                            width: 10),
                                                      ]),
                                                  body: TaskItem(pet, task)))
                                        ]));
                                  }).then((value) {
                                final int executedCount = getExecutedCount(
                                    priorityTasks[index].taskId,
                                    priorityTasks[index].petId);

                                if (priorityTask.times <= executedCount) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: const Text('ステータスを完了にしますか？'),
                                          actions: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      final priorityTask =
                                                          priorityTasks[index];

                                                      ref
                                                          .read(
                                                              priorityTaskProvider
                                                                  .notifier)
                                                          .updatePriorityTask(
                                                              priorityTask.copyWith(
                                                                  status: Status
                                                                      .completed));

                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ])
                                          ]);
                                    },
                                  );
                                }
                              });
                            },
                            child: const Icon(Icons.thumb_up_alt_outlined),
                          )))
              ]),
            ));

    ScrollController? scrollController = ScrollController();

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          if (priorityTasks.isEmpty)
            const SizedBox(
                height: 217, child: Center(child: Text('管理しているタスクはありません')))
          else
            SizedBox(
                height: priorityTasks.length <= 3 ? 240 : 420,
                child: ReorderableWrap(
                    header: [
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(priorityTaskProvider);

                          final targets = [...priorityTasks];

                          targets.sortByCompare(
                              (priorityTask) => priorityTask.dueDate, (a, b) {
                            if (a == null || b == null) {
                              return -1;
                            }

                            return a.compareTo(b);
                          });

                          ref
                              .read(priorityTaskProvider.notifier)
                              .updateAll(targets);
                        },
                        child: const Text('期限'),
                      ),
                      // const SizedBox.shrink(),
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(priorityTaskProvider);

                          final targets = [...priorityTasks];

                          targets.sortByCompare(
                              (priorityTask) => priorityTask.priority, (a, b) {
                            return switch ((a, b)) {
                              (Priority.high, Priority.high) => 0,
                              (Priority.high, Priority.middle) => 1,
                              (Priority.high, Priority.low) => 1,
                              (Priority.middle, Priority.middle) => 0,
                              (Priority.middle, Priority.low) => 1,
                              (Priority.middle, Priority.high) => -1,
                              (Priority.low, Priority.low) => 0,
                              (Priority.low, Priority.middle) => -1,
                              (Priority.low, Priority.high) => -1,
                            };
                          });

                          ref
                              .read(priorityTaskProvider.notifier)
                              .updateAll([...targets.reversed]);
                        },
                        child: const Text('優先度'),
                      ),
                      const SizedBox.shrink(),
                    ],
                    controller: scrollController,
                    maxMainAxisCount: 3,
                    spacing: 10.0,
                    runSpacing: 10.0,
                    padding: const EdgeInsets.all(8),
                    children: reorderItems,
                    onReorder: (int oldIndex, int newIndex) {
                      final targets = [...priorityTasks];
                      targets.insert(newIndex, targets.removeAt(oldIndex));

                      ref
                          .read(priorityTaskProvider.notifier)
                          .updateAll([...targets]);
                    })),
        ]));
  }
}
