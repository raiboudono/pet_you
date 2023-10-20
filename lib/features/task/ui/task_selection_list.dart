import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../category/application/category_provider.dart';
import '../../task/application/task_provider.dart';
import '../../task/application/priority_task_provider.dart';
import '../../pet/application/pet_provider.dart';

import '../../task/model/task.dart';
import '../../task/model/priority_task.dart';

import '../../../layout/home.dart';

final selectExpansionIndexProvider =
    StateProvider.autoDispose<int?>((ref) => -1);

class TaskSelectionList extends ConsumerWidget {
  const TaskSelectionList({super.key});

  @override
  Widget build(context, ref) {
    final selectExpansionIndex = ref.watch(selectExpansionIndexProvider);

    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[ref.watch(petIndexProvider)];

    final categories = ref
        .watch(categoryProvider)
        .nonNulls
        .where((category) =>
            category.visible && pet.categoryIds.contains(category.id))
        .toList();

    final tasksByCategory = List.generate(categories.length, (index) {
      return categories[index]
          .taskIds
          .map(
              (taskId) => ref.watch(taskProvider.notifier).findTaskById(taskId))
          .where((task) => task!.visible)
          .nonNulls
          .toList();
    });

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

    return Expanded(
        // maxHeight: 200,
        child: ListView.builder(
            key: Key('select_$selectExpansionIndex'),
            itemCount: categories.length,
            itemBuilder: (context, categoryIndex) {
              return ExpansionTile(
                  onExpansionChanged: (isOpen) {
                    if (isOpen) {
                      ref
                          .read(selectExpansionIndexProvider.notifier)
                          .update((state) => categoryIndex);
                    }
                  },
                  initiallyExpanded: categoryIndex == selectExpansionIndex,
                  shape: const Border(),
                  title: Text(categories[categoryIndex].name),
                  children: [
                    Row(children: [
                      Flexible(
                          flex: 5,
                          child: SizedBox(
                              child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minHeight: 60, maxHeight: 300),
                                  child: Container(
                                      height: tasksByCategory[categoryIndex]
                                              .length *
                                          60,
                                      color: Colors.black12.withOpacity(0.05),
                                      // height: 250,
                                      child: ListView.builder(
                                          itemCount:
                                              tasksByCategory[categoryIndex]
                                                  .length,
                                          itemBuilder: (context, taskIndex) {
                                            return CheckboxListTile(
                                                title: Text(tasksByCategory[
                                                            categoryIndex]
                                                        [taskIndex]
                                                    .name),
                                                value: priorityTasks
                                                    .any((priority) {
                                                  return priority.taskId ==
                                                      tasksByCategory[
                                                                  categoryIndex]
                                                              [taskIndex]
                                                          .id;
                                                }),
                                                onChanged:
                                                    (bool? isChecked) async {
                                                  final Task task =
                                                      tasksByCategory[
                                                              categoryIndex]
                                                          [taskIndex];

                                                  if (isChecked!) {
                                                    const addlimit = 6;
                                                    if (priorityTasks.length ==
                                                        addlimit) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Center(
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: 200,
                                                                  height: 50,
                                                                  child: const Text(
                                                                      '追加できる数を超えました')));
                                                        },
                                                      );
                                                      return;
                                                    }
                                                    ref
                                                        .read(
                                                            priorityTaskProvider
                                                                .notifier)
                                                        .addPriorityTask(
                                                            PriorityTask(
                                                          id: ref
                                                              .read(
                                                                  priorityTaskProvider
                                                                      .notifier)
                                                              .assignId(),
                                                          name: task.name,
                                                          petId: pet.id,
                                                          taskId: task.id,
                                                          categoryId:
                                                              task.categoryId!,
                                                          executed:
                                                              getExecutedCount(
                                                                  task.id,
                                                                  pet.id),
                                                        ));
                                                  } else {
                                                    final createdOrNull =
                                                        priorityTasks
                                                            .firstWhere((pt) =>
                                                                pt.taskId ==
                                                                task.id)
                                                            .createdAt;

                                                    if (createdOrNull != null) {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          builder: (context) {
                                                            return SizedBox(
                                                                height: 130,
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    children: [
                                                                      const Text(
                                                                          '削除しますか？'),
                                                                      Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                ref.read(priorityTaskProvider.notifier).deletePriorityTask(priorityTasks.firstWhere((pt) => pt.taskId == task.id));

                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: const Text('削除する', style: TextStyle(color: Colors.red)),
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
                                                    } else {
                                                      ref
                                                          .read(
                                                              priorityTaskProvider
                                                                  .notifier)
                                                          .removePriorityTask(
                                                              priorityTasks
                                                                  .firstWhere((pt) =>
                                                                      pt.taskId ==
                                                                      task.id));
                                                    }
                                                  }
                                                });
                                          }))))),
                      const Flexible(child: SizedBox()),
                    ])
                  ]);
            }));
  }
}
