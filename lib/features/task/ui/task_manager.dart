import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'task_card.dart';
import 'task_selection_list.dart';
import '../../task/model/priority_task.dart';

import '../../task/application/priority_task_provider.dart';
import '../../pet/application/pet_provider.dart';

import '../../../layout/home.dart';

class TaskManager extends ConsumerWidget {
  const TaskManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[ref.watch(petIndexProvider)];
    final priorityTasks = ref
        .watch(priorityTaskProvider)
        .nonNulls
        .where((priorityTask) => priorityTask.petId == pet.id);

    return Scaffold(
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (pet.headerImagePath case final String path
                  when File(path).existsSync())
                CircleAvatar(
                    backgroundImage: Image.file(
                  File(path),
                ).image)
              else
                SizedBox(
                    width: 90,
                    child: Text(pet.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_right, size: 22),
              const SizedBox(width: 10),
              const Text('タスク管理', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
            ]),
            centerTitle: true,
            actions: [
              Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: const Text('完了済みを全て削除しますか？'),
                            actions: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (!priorityTasks.any((priorityTask) =>
                                            priorityTask.status ==
                                            Status.completed)) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Center(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      alignment:
                                                          Alignment.center,
                                                      width: 200,
                                                      height: 50,
                                                      child: Text('完了済みが存在しません',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer))));
                                            },
                                          ).then((value) =>
                                              Navigator.pop(context));
                                        } else {
                                          final targets = [...priorityTasks];

                                          for (final priorityTask in targets) {
                                            if (priorityTask.status ==
                                                Status.completed) {
                                              ref
                                                  .read(priorityTaskProvider
                                                      .notifier)
                                                  .deletePriorityTask(
                                                      priorityTask);
                                            }
                                          }
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ])
                            ]);
                      },
                    );
                  },
                  child: const Icon(Icons.delete_sweep_outlined),
                );
              }),
              const SizedBox(width: 10),
            ]),
        body: const SizedBox(
            // height: 810,
            // color: Colors.blue,
            child: Column(children: [TaskCard(), TaskSelectionList()])));
  }
}
