import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../task/application/priority_task_provider.dart';
import '../../task/model/priority_task.dart';

class TaskRegister extends ConsumerWidget {
  const TaskRegister(this.index, this.petId, {super.key});
  final int index;
  final int petId;

  @override
  Widget build(context, ref) {
    final priorityTasks = ref
        .watch(priorityTaskProvider)
        .nonNulls
        .where((priorityTask) => priorityTask.petId == petId)
        .toList();
    final priorityTask = priorityTasks[index];

    return GestureDetector(
        onTap: () async {
          final now = DateTime.now();
          final selectedDate = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: now,
              lastDate: now.copyWith(year: 2050));

          ref
              .read(priorityTaskProvider.notifier)
              .updatePriorityTask(priorityTask.copyWith(dueDate: selectedDate));
        },
        child: Column(children: [
          const SizedBox(height: 10),
          Text(priorityTask.name, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          SizedBox(
            width: 180,
            child: TextFormField(
              key: GlobalKey<FormFieldState>(),
              initialValue: priorityTask.dueDate != null
                  ? DateFormat.yMEd('ja_JP').format(priorityTask.dueDate!)
                  : '',
              enabled: false,
              decoration: const InputDecoration(
                labelText: '期日',
                errorMaxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
              width: 180,
              // height: 200,
              child: Column(
                  // crossAxisAlignment:
                  //     CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              // color: Colors.blue,
                              child: Center(
                                  child: TextFormField(
                                      initialValue:
                                          priorityTask.times.toString(),
                                      key: GlobalKey<FormFieldState>(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '回数',
                                        border: OutlineInputBorder(),
                                      ),
                                      onFieldSubmitted: (value) {
                                        // ignore: unused_result
                                        priorityTask.copyWith(
                                            times: int.tryParse(value)!);
                                      }))),
                          Container(
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(20, 233, 30, 98),
                                  borderRadius: BorderRadius.circular(8)),
                              child: IconButton(
                                onPressed: () {
                                  if (priorityTask.times <= 0) {
                                    return;
                                  }
                                  ref
                                      .read(priorityTaskProvider.notifier)
                                      .updatePriorityTask(priorityTask.copyWith(
                                          times: priorityTask.times - 1));
                                },
                                icon: const Icon(Icons.remove),
                              )),
                          Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(20, 3, 168, 244),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  ref
                                      .read(priorityTaskProvider.notifier)
                                      .updatePriorityTask(priorityTask.copyWith(
                                          times: priorityTask.times + 1));
                                },
                                icon: const Icon(Icons.add),
                              ))
                        ]),
                    const SizedBox(height: 20),
                    priorityTask.times == 0
                        ? const SizedBox(height: 30, child: Text('未定'))
                        : const SizedBox.shrink(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('優先度:'),
                    ),
                    ...Priority.values.map(
                      (priority) {
                        return SizedBox(
                            // color: Colors.pink,
                            width: 150,
                            child: RadioListTile.adaptive(
                              controlAffinity: ListTileControlAffinity.trailing,
                              title: Text(priority.name),
                              value: priority,
                              onChanged: (value) {
                                ref
                                    .read(priorityTaskProvider.notifier)
                                    .updatePriorityTask(priorityTask.copyWith(
                                        priority: value!));
                              },
                              groupValue: priorityTask.priority,
                            ));
                      },
                    ).toList()
                  ])),
          const SizedBox(height: 20),
          SizedBox(
              width: 200,
              // color: Colors.blue,
              child: TextFormField(
                  onFieldSubmitted: (value) {
                    ref
                        .read(priorityTaskProvider.notifier)
                        .updatePriorityTask(priorityTask.copyWith(memo: value));
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  key: GlobalKey<FormFieldState>(),
                  initialValue: priorityTask.memo ?? '',
                  decoration: const InputDecoration(labelText: 'メモ'))),
          const SizedBox(height: 20),
          SegmentedButton<Status>(
              showSelectedIcon: false,
              onSelectionChanged: (p0) {
                if (p0.first == Status.progress ||
                    p0.first == Status.completed) {
                  if (priorityTask.executed == 0) {
                    return;
                  } else {
                    ref.read(priorityTaskProvider.notifier).updatePriorityTask(
                        priorityTask.copyWith(status: p0.first));
                  }
                }
              },
              selected: {
                switch (priorityTask.status) {
                  Status status => status,
                  _ when priorityTask.executed != 0 => Status.progress,
                  _ => Status.waiting
                }
              },
              segments: [
                ButtonSegment(
                    value: Status.waiting,
                    label: Text(Status.waiting.name),
                    icon: const Icon(Icons.pending_outlined,
                        color: Colors.pinkAccent)),
                ButtonSegment(
                    value: Status.progress,
                    label: Text(Status.progress.name),
                    icon: const Icon(Icons.more_outlined,
                        color: Colors.indigoAccent)),
                ButtonSegment(
                    value: Status.completed,
                    label: Text(Status.completed.name),
                    icon: const Icon(Icons.done_outline_outlined,
                        color: Colors.greenAccent)),
              ]),
          const SizedBox(height: 20),
          Align(
              alignment: Alignment.centerRight,
              widthFactor: 3.5,
              child: FilledButton(
                onPressed: () {
                  final now = DateTime.now();

                  if (priorityTask.createdAt != null) {
                    ref.read(priorityTaskProvider.notifier).updatePriorityTask(
                        priorityTask.copyWith(updatedAt: now));
                  } else {
                    // print('yes');

                    // print(this.pt.petId);

                    // final pt = PriorityTask(
                    //     id: ref.read(taskProvider.notifier).assignId(),
                    //     name: priorityTask.name,
                    //     petId: petId,
                    //     taskId: priorityTask.taskId,
                    //     executed: getExecutedCount(priorityTask.taskId, petId),
                    //     categoryId: priorityTask.categoryId!,
                    //     createdAt: now,
                    //     updatedAt: now
                    //     );

                    // final priorityTask =  PriorityTask(id: ref.read(taskProvider.notifier).assignId())
                    ref.read(priorityTaskProvider.notifier).savePriorityTask(
                        priorityTask.copyWith(createdAt: now, updatedAt: now));

                    // ref.invalidate(categoryProvider);
                  }

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.check),
              ))
        ]));
  }
}
