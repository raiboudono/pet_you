import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../layout/home.dart';
import 'task_create.dart';
import 'task_edit.dart';
import '../../pet/model/pet.dart';

import '../../task/application/task_provider.dart';
import '../../category/application/category_provider.dart';

class CategoryTaskEditList extends ConsumerWidget {
  const CategoryTaskEditList(this.pet, {super.key});
  final Pet pet;

  @override
  Widget build(context, ref) {
    final taskWorker = ref.watch(taskProvider.notifier);

    final categories = ref
        .watch(categoryProvider)
        .nonNulls
        .where((category) => category.visible)
        .toList();

    final tasks = categories.map(
      (category) {
        final taskIds = category.taskIds;
        final tasks = taskIds
            .map(
              (taskId) {
                final task = taskWorker.findTaskById(taskId);
                if (task != null && task.visible) {
                  return task;
                } else {
                  return null;
                }
              },
            )
            .nonNulls
            .toList();

        return tasks;
      },
    ).toList();

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                  onPressed: () {
                    ref
                        .read(editableSwitchProvider.notifier)
                        .update((state) => !state);
                  },
                  child: const Text('カテゴリ編集',
                      style: TextStyle(color: Colors.white)))
            ]),
        body: SizedBox(
            child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                  // shadowColor: Colors.transparent,
                ),
                child: categories.isEmpty
                    ? const Center(
                        child: Text('カテゴリの作成が必要です',
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 5),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                              key: Key('$index'),
                              width: double.infinity,
                              child: FractionallySizedBox(
                                  key: Key('$index'),
                                  widthFactor: .95,
                                  child: Padding(
                                      padding: const EdgeInsets.only(bottom: 9),
                                      child: ExpansionTile(
                                          collapsedIconColor: Theme.of(context)
                                              .colorScheme
                                              .onSecondary
                                              .withOpacity(.5),
                                          iconColor: Colors.black,
                                          title: Row(children: [
                                            categories[index].iconCodePoint !=
                                                    null
                                                ? Icon(IconData(
                                                    categories[index]
                                                        .iconCodePoint!,
                                                    fontFamily:
                                                        'MaterialIcons'))
                                                : Icon(Icons.select_all,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary),
                                            TextButton(
                                                onPressed: null,
                                                child: Text(
                                                    categories[index].name,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black)))
                                          ]),
                                          backgroundColor: Colors.white,
                                          collapsedBackgroundColor:
                                              Colors.white,
                                          tilePadding:
                                              const EdgeInsets.fromLTRB(
                                                  15, 0, 10, 0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          collapsedShape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                      return TaskCreate(
                                                          categories[index]);
                                                    }),
                                                  );
                                                },
                                                icon: const Icon(
                                                    color: Colors.indigoAccent,
                                                    Icons.add)),
                                            SizedBox(
                                                height: 300,
                                                child: ListView.builder(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        20, 0, 20, 15),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        tasks[index].length,
                                                    itemBuilder:
                                                        (context, taskIndex) {
                                                      return SizedBox(
                                                          height: 70,
                                                          child: Material(
                                                              child: Center(
                                                                  child: ListTile(
                                                                      onTap: () {
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return TaskEdit(
                                                                                categories[index],
                                                                                tasks[index][taskIndex],
                                                                                pet);
                                                                          }),
                                                                        );
                                                                      },
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      tileColor: Colors.grey.shade100.withOpacity(.6),
                                                                      title: switch (categories[index].taskIds.isNotEmpty) {
                                                                        true => Text(
                                                                            tasks[index][taskIndex]
                                                                                .name,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black,
                                                                            )),
                                                                        false =>
                                                                          const SizedBox()
                                                                      }))));
                                                    })),
                                          ]))));
                        }))));
  }
}
