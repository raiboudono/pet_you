import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'memo_list_item.dart';
import 'task_item.dart';
import '../../pet/model/pet.dart';
import '../../task/model/task.dart';

import '../application/task_provider.dart';

class MemoList extends ConsumerWidget {
  const MemoList(this.pet, this.task, {super.key});
  final Pet pet;
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities =
        ref.watch(taskProvider.notifier).findActivityAllByPetId(pet.id);

    final memosActivity = activities
        .where((activity) =>
            activity?.memo != null &&
                activity?.memo != '' &&
                activity?.taskId == task.id ||
            activity?.headerImagePath != null && activity?.taskId == task.id)
        .toList();

    return SizedBox(
        width: 240,
        height: 360,
        child: Column(children: [
          Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ref
                      .read(isMemoListDisplayProvider.notifier)
                      .update((state) => false);
                },
                child: const Text('タスク入力'),
              )),
          const Divider(
            thickness: .1,
            height: .1,
          ),
          SizedBox(
              height: 275,
              child: SingleChildScrollView(
                  child: memosActivity.isEmpty
                      ? const SizedBox(
                          height: 300, child: Center(child: Text('メモがありません')))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: memosActivity.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                // tileColor: Colors.indigo.withOpacity(.08),
                                // dense: true,
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(children: [
                                          MemoListItem(
                                              pet, memosActivity[index])
                                        ]);
                                      });
                                },
                                contentPadding:
                                    const EdgeInsets.only(left: 0, bottom: 0),
                                title: Text(memosActivity[index]!.memo!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14)),
                                leading: switch (
                                    memosActivity[index]!.headerImagePath) {
                                  final String path
                                      when File(path).existsSync() =>
                                    ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.file(
                                            height: 40,
                                            width: 50,
                                            File(path),
                                            fit: BoxFit.cover)),
                                  _ => null
                                });
                          })))
        ]));
  }
}
