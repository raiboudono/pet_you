import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../application/task_provider.dart';
import '../../pet/application/pet_provider.dart';
import '../../task/application/priority_task_provider.dart';
import '../../setting/application/app_setting_provider.dart';
import '../../../layout/home.dart';
import '../../../layout/grid_category.dart';
import 'task_item.dart';
import 'task_create.dart';
import 'task_edit.dart';

import '../../pet/model/pet.dart';
import '../../category/model/category.dart';

import '../../setting/application/tutorial_controller.dart';

final selectExpansionIndexProvider =
    StateProvider.autoDispose<int?>((ref) => -1);

class TaskList extends ConsumerStatefulWidget {
  const TaskList(this.pet, this.petCategories, {super.key});
  final Pet pet;
  final List<Category?> petCategories;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TaskListState();
}

class TaskListState extends ConsumerState<TaskList> {
  GlobalKey taskListTutorial = GlobalKey();

  @override
  initState() {
    super.initState();
    if (ref.read(settingProvider.notifier).isTutorial) {
      final tutorialControllerNotifier =
          ref.read(tutorialControllerProvider.notifier);
      Future.delayed(
          const Duration(milliseconds: 800),
          () => tutorialControllerNotifier.tutorial(taskListTutorial,
              'taskListTutorial', 'directInputTutorial', context));
    }
  }

  @override
  Widget build(context) {
    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[petIndex];

    final carouselIndex = ref.watch(carouselIndexProvider);

    final categories = widget.petCategories
        .where((category) => category?.visible ?? false)
        .nonNulls
        .toList();

    categories.sort((a, b) => a.position!.compareTo(b.position!));
    final petCategory = categories[carouselIndex];
    final taskWorker = ref.watch(taskProvider.notifier);

    /*リビルドのために category.taskIds でなくプロバイダから取得 */
    final tasks = ref
        .watch(taskProvider)
        .where((task) => task?.categoryId == petCategory.id)
        .where((task) => task?.visible ?? false)
        .nonNulls
        .toList();

    final petTasks = pet.taskIds
        .map((taskId) => taskWorker.findTaskById(taskId))
        .where((task) => task?.categoryId == petCategory.id)
        .toList();

    final selectExpansionIndex = ref.watch(selectExpansionIndexProvider);

    final priorityTasks = ref
        .watch(priorityTaskProvider)
        .nonNulls
        .where((priorityTask) => priorityTask.petId == pet.id)
        .where((priorityTask) {
      return priorityTask.petId == pet.id &&
          priorityTask.categoryId == petCategory.id;
    }).toList();

    // for (final v in priorityTasks) {
    //   print(v.name);
    // }

    return Scaffold(
        // resizeToAvoidBottomInset: false,
        drawerEdgeDragWidth: 0,
        endDrawer: Drawer(
            width: 280,
            child: SingleChildScrollView(
                child: SizedBox(
                    child: Column(children: [
              SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      const Spacer(flex: 2),
                      TextButton.icon(
                        label: Text(petCategory.name,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        icon: petCategory.iconCodePoint != null
                            ? Icon(
                                IconData(petCategory.iconCodePoint!,
                                    fontFamily: 'MaterialIcons'),
                                size: 19,
                                color: Theme.of(context).colorScheme.onPrimary)
                            : const Icon(Icons.select_all),
                        onPressed: null,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return TaskCreate(petCategory);
                            }),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  )),
              SizedBox(
                  // height: 820,
                  child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      title: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return TaskEdit(
                                        petCategory, tasks[index], pet);
                                  }),
                                );
                              },
                              child: Text(tasks[index].name,
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis))),
                      onChanged: (_) {
                        ref
                            .read(taskProvider.notifier)
                            .addOrRemoveTaskId(pet, tasks[index].id);
                      },
                      value: pet.taskIds.contains(tasks[index].id));
                },
              ))
            ])))),
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
              petCategory.iconCodePoint != null
                  ? Icon(
                      IconData(petCategory.iconCodePoint!,
                          fontFamily: 'MaterialIcons'),
                      size: 19)
                  : const Icon(Icons.select_all),
              const SizedBox(width: 5),
              Text(petCategory.name, style: const TextStyle(fontSize: 13))
            ]),
            centerTitle: true,
            actions: [
              Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: const Text('編集'),
                );
              }),
              const SizedBox(width: 10),
            ]),
        // backgroundColor: Colors.transparent,
        body: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: petTasks.isEmpty
                ? const Center(child: SizedBox(child: Text('タスクがありません')))
                : ListView.builder(
                    key: Key('select_$selectExpansionIndex'),
                    itemCount: petTasks.length,
                    itemBuilder: (context, index) {
                      final taskIds = priorityTasks
                          .map((priorityTask) => priorityTask.taskId);

                      return ExpansionTile(
                        subtitle: priorityTasks.isNotEmpty &&
                                taskIds.contains(petTasks[index]?.id)
                            ? Text('管理中',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withOpacity(.5)))
                            : const Text(''),
                        trailing: index == 0
                            ? Icon(
                                key: taskListTutorial,
                                Icons.keyboard_arrow_down)
                            : null,
                        key: Key('$index'),
                        textColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        onExpansionChanged: (isOpen) {
                          if (isOpen) {
                            ref
                                .read(selectExpansionIndexProvider.notifier)
                                .update((state) => index);

                            ref.invalidate(pageViewControllerProvider);
                            ref.invalidate(activeStepProvider);
                            ref.invalidate(isMemoListDisplayProvider);
                          }
                        },
                        initiallyExpanded: index == selectExpansionIndex,
                        title: Text(petTasks[index]!.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        children: [TaskItem(pet, petTasks[index]!)],
                      );
                    },
                  )));
  }
}
