import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:easy_stepper/easy_stepper.dart';

import '../../task/model/task.dart';
import '../../pet/model/pet.dart';

import '../../../graph/line.dart';
import '../../../graph/stacked_bar.dart';

import 'input/direct_input.dart';
import 'input/time_input.dart';
import 'input/cost_input.dart';
import 'input/memo_input.dart';
import 'done.dart';
import 'memo_list.dart';

import '../model/task_activity.dart';
import '../../task/ui/task_edit.dart';

import '../../category/application/category_provider.dart';
import '../application/task_provider.dart';
import '../application/priority_task_provider.dart';
import '../../pet/application/pet_provider.dart';

final executedActivity =
    StateProvider.autoDispose<TaskActivity?>((ref) => null);

final activeStepProvider = StateProvider.autoDispose((ref) => 0);

final pageViewControllerProvider =
    Provider.family((id, ref) => PageController());

final isMemoListDisplayProvider = StateProvider.autoDispose((ref) => false);

final isErrorMessageDisplayProvider = StateProvider.autoDispose((ref) => false);

final amountProvider = StateProvider<int?>((ref) => null);

final tmpAmountProvider = StateProvider.autoDispose<int?>((ref) => null);

final tmpFromTimeProvider =
    StateProvider.autoDispose<TimeOfDay?>((ref) => null);
final tmpToTimeProvider = StateProvider.autoDispose<TimeOfDay?>((ref) => null);

final buttonOffsetProvider = StateProvider<Offset?>((ref) => null);

class TaskItem extends ConsumerWidget {
  const TaskItem(this.pet, this.task, {super.key});
  final Pet pet;
  final Task task;

  @override
  Widget build(context, ref) {
    final activeStep = ref.watch(activeStepProvider);
    final isMemoListDisplay = ref.watch(isMemoListDisplayProvider);

    final category =
        ref.watch(categoryProvider.notifier).findById(task.categoryId);

    final PageController controller =
        ref.watch(pageViewControllerProvider(task.id));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(amountProvider.notifier).update((state) => task.amount ?? 0);
    });

    return Container(
        padding: const EdgeInsets.only(top: 5, left: 5),
        decoration: BoxDecoration(
            // color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          SizedBox(
              /*テスト時はステッパーでエラーでるのでコメントアウトしている時に無くなった分だけ高さが必要になる*/
              // height: 375,
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  // color: Colors.blue.shade100,
                  height: 380,
                  width: 100,
                  child: Column(children: [
                    Card(
                        margin: const EdgeInsets.all(0),
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.01),
                        shadowColor: Colors.transparent,
                        child: SizedBox(
                            height: 325,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: switch (task.headerImagePath) {
                                        final String path
                                            when File(path).existsSync() =>
                                          Image.file(
                                            gaplessPlayback: true,
                                            File(task.headerImagePath!),
                                            // width: double.infinity,
                                            width: 110,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        final String path
                                            when path.startsWith('asset') =>
                                          Image.asset(path),
                                        _ => const SizedBox(
                                            width: 110,
                                            height: 80,
                                            child: Center(
                                                child: Text('No Image',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey))))
                                      }),
                                  Container(
                                    // height: double.infinity,
                                    // color: Colors.blue.shade300,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Column(children: [
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.more_horiz,
                                                size: 16),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                  return TaskEdit(
                                                      category!, task, pet);
                                                }),
                                              ).then((_) {
                                                ref.invalidate(
                                                    tmpAmountProvider);
                                                ref.invalidate(
                                                    tmpFromTimeProvider);
                                                ref.invalidate(
                                                    tmpToTimeProvider);
                                                ref.invalidate(
                                                    categoryProvider);
                                              });
                                            },
                                          )),
                                      Text('${task.description}',
                                          maxLines: 8,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12)),
                                    ]),
                                  ),
                                  const Spacer(),
                                  const SizedBox(height: 10)
                                ]))),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(),
                      onPressed: () {
                        ref
                            .read(isMemoListDisplayProvider.notifier)
                            .update((state) => true);
                      },
                      child: const Text('メモ一覧',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    )
                  ])),
              const SizedBox(width: 5),
              Stack(children: [
                SizedBox(
                    height: isMemoListDisplay ? 370 : 0,
                    child: MemoList(pet, task)),
                SizedBox(
                    // color: Colors.pink,
                    width: isMemoListDisplay ? 0 : 250,
                    height: isMemoListDisplay ? 0 : 380,
                    child: GestureDetector(
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: Column(children: [
                          EasyStepper(
                            onStepReached: (activeStep) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.animateToPage(activeStep,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease);

                              ref
                                  .read(activeStepProvider.notifier)
                                  .update((state) => activeStep);
                            },
                            activeStep: activeStep,
                            maxReachedStep: 3,
                            // unreachedStepBackgroundColor: Colors.red,
                            activeStepBackgroundColor: Colors.blue.shade200,
                            // unreachedStepIconColor: Colors.red,
                            activeStepBorderColor: Colors.blue.shade200,
                            activeStepIconColor: Colors.blue,
                            finishedStepBackgroundColor: Colors.black12,
                            unreachedLineColor: Colors.black12,
                            alignment: Alignment.bottomCenter,
                            stepRadius: 11,
                            lineLength: 30,
                            stepShape: StepShape.circle,
                            stepBorderRadius: 15,
                            borderThickness: 2,
                            internalPadding: 80,
                            padding: const EdgeInsets.only(top: 5),
                            // finishedStepBorderColor: Colors.deepOrange,
                            // finishedStepTextColor: Colors.deepOrange,
                            // finishedStepBackgroundColor: Colors.deepOrange,
                            // activeStepIconColor: Colors.deepOrange,
                            showLoadingAnimation: false,
                            showScrollbar: true,
                            steps: const [
                              EasyStep(
                                icon: Icon(Icons.av_timer),
                                activeIcon: Icon(
                                  Icons.av_timer,
                                ),
                                customTitle: Text(
                                  '量',
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              EasyStep(
                                icon: Icon(Icons.create_outlined),
                                activeIcon: Icon(Icons.create),
                                customTitle: Text(
                                  'メモ',
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              EasyStep(
                                icon: Icon(Icons.calculate_outlined),
                                activeIcon: Icon(Icons.calculate),
                                customTitle: Text(
                                  'コスト',
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              EasyStep(
                                icon: Icon(Icons.done_outlined),
                                activeIcon: Icon(Icons.done),
                                customTitle: Text(
                                  '完了',
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              // color: Colors.tealAccent,
                              height: 274,
                              child: PageView.builder(
                                  onPageChanged: (activeStep) {
                                    ref
                                        .read(activeStepProvider.notifier)
                                        .update((state) => activeStep);
                                  },
                                  controller: controller,
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return switch (task.type) {
                                      '時間' => [
                                          TimeInput(pet, task),
                                          MemoInput(pet, task),
                                          CostInput(pet, task),
                                          Done(task)
                                        ][index],
                                      '直接' => [
                                          DirectInput(pet, task),
                                          MemoInput(pet, task),
                                          CostInput(pet, task),
                                          Done(task)
                                        ][index],
                                      _ => [
                                          DirectInput(pet, task),
                                          MemoInput(pet, task),
                                          CostInput(pet, task),
                                          Done(task)
                                        ][index],
                                    };
                                  })),
                          Align(
                              alignment: Alignment.centerRight,
                              widthFactor: 2.8,
                              child: Builder(
                                builder: (context) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    final renderBox = context.findRenderObject()
                                        as RenderBox?;
                                    if (renderBox != null &&
                                        renderBox.hasSize) {
                                      final offset =
                                          renderBox.localToGlobal(Offset.zero);
                                      ref
                                          .read(buttonOffsetProvider.notifier)
                                          .update((state) => offset);
                                    }
                                  });

                                  return FilledButton(
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      controller.nextPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve:
                                              Curves.fastEaseInToSlowEaseOut);

                                      if (activeStep < 3) {
                                        ref
                                            .read(activeStepProvider.notifier)
                                            .update((state) => state + 1);
                                      }
                                      if (activeStep == 3) {
                                        final amount = ref.read(amountProvider);
                                        final memo = ref
                                            .read(memoFormFieldProvider)
                                            .currentState
                                            ?.value;
                                        final headerImagePath = ref
                                            .read(pickedMemoImageProvider)
                                            ?.path;

                                        final cost = int.tryParse(ref
                                                .read(costFormFieldProvider)
                                                .currentState
                                                ?.value ??
                                            '');

                                        if ((amount == null || amount == 0) &&
                                            memo == '' &&
                                            headerImagePath == null &&
                                            cost == null) {
                                          ref
                                              .read(
                                                  isErrorMessageDisplayProvider
                                                      .notifier)
                                              .update((state) => true);
                                          return;
                                        }

                                        final activity = TaskActivity(
                                            id: ref
                                                .read(taskProvider.notifier)
                                                .assignId(),
                                            categoryName: category?.name,
                                            taskName: task.name,
                                            memo: memo,
                                            headerImagePath: headerImagePath,
                                            petId: pet.id,
                                            taskId: task.id,
                                            categoryId: task.categoryId,
                                            amount: amount,
                                            cost: cost,
                                            unit: task.unit,
                                            createdAt: DateTime.now());

                                        ref
                                            .read(taskProvider.notifier)
                                            .saveActivity(activity);

                                        final priorityTasks = ref
                                            .watch(priorityTaskProvider)
                                            .nonNulls
                                            .where((priorityTask) =>
                                                priorityTask.petId == pet.id)
                                            .where((priorityTask) =>
                                                priorityTask.taskId ==
                                                activity.taskId)
                                            .where((priorityTask) {
                                          final now = DateTime.now();
                                          final nowDate = DateTime(
                                              now.year, now.month, now.day);

                                          return priorityTask.createdAt!
                                              .isAfter(nowDate);
                                        });

                                        if (priorityTasks.isNotEmpty) {
                                          final priorityTask =
                                              priorityTasks.first;

                                          final result = priorityTask.copyWith(
                                              executed:
                                                  priorityTask.executed + 1);

                                          ref
                                              .read(
                                                  priorityTaskProvider.notifier)
                                              .updatePriorityTask(result);
                                        }

                                        ref.invalidate(petProvider);

                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: activeStep == 3
                                        ? const Text('登録',
                                            style:
                                                TextStyle(color: Colors.white))
                                        : const Text('次へ'),
                                  );
                                },
                              )),
                        ])))
              ]),
            ],
          )),
          switch (task.dayCount) {
            '1回' => Line(pet, task),
            '複数回' => StackedBar(pet, task),
            _ => StackedBar(pet, task)
          }
        ]));
  }
}
