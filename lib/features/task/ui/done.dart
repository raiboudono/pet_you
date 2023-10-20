import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../setting/application/tutorial_controller.dart';
import '../../setting/application/app_setting_provider.dart';

import '../../task/model/task.dart';
import 'task_item.dart';
import 'input/memo_input.dart';
import 'input/cost_input.dart';

class Done extends ConsumerStatefulWidget {
  const Done(this.task, {super.key});
  final Task task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => DoneState();
}

class DoneState extends ConsumerState<Done> {
  GlobalKey doneTutorial = GlobalKey();
  @override
  initState() {
    super.initState();

    if (!ref.read(settingProvider.notifier).isTutorial) {
      return;
    }

    final tutorialControllerNotifier =
        ref.read(tutorialControllerProvider.notifier);

    Future.delayed(
        const Duration(milliseconds: 800),
        () => tutorialControllerNotifier.tutorial(
              doneTutorial,
              'doneTutorial',
              'completeTutorial',
              context,
              null,
            ));
  }

  @override
  Widget build(context) {
    final task = widget.task;
    final amount = ref.watch(amountProvider);
    final String memo = ref.watch(memoFormFieldProvider).currentState?.value;
    final headerImagePath = ref.watch(pickedMemoImageProvider)?.path;
    final cost = ref.watch(costFormFieldProvider).currentState?.value;
    final isErrorMessageDisplay = ref.watch(isErrorMessageDisplayProvider);

    final controller = ref.watch(pageViewControllerProvider(task.id));
    return WillPopScope(
        onWillPop: () async {
          if (ref.read(settingProvider.notifier).isTutorial) {
            return Future.value(false);
          }
          return true;
        },
        child: SizedBox(
          key: doneTutorial,
          width: 210,
          // color: Colors.blue.shade100,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isErrorMessageDisplay)
                  ListTile(
                      title: Text('入力がありません',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      subtitle: Text('どれか1つ以上の入力が必要です',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.error))),
                ListTile(
                    onTap: () {
                      ref
                          .read(activeStepProvider.notifier)
                          .update((state) => 0);
                      controller.animateToPage(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    title: Text('量',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    trailing: amount != null && amount != 0
                        ? Text('$amount ${task.unit}')
                        : const Text('なし')),
                ListTile(
                    onTap: () {
                      ref
                          .read(activeStepProvider.notifier)
                          .update((state) => 1);
                      controller.animateToPage(1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    title: Text('メモ',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    trailing: SizedBox(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          if (memo.trim().isNotEmpty)
                            const Text('テキストあり')
                          else
                            const Text('テキストなし'),
                          if (headerImagePath != null)
                            const Text('画像あり')
                          else
                            const Text('画像なし'),
                        ]))),
                ListTile(
                    onTap: () {
                      ref
                          .read(activeStepProvider.notifier)
                          .update((state) => 2);
                      controller.animateToPage(2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    title: Text('コスト',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    trailing: cost != '' ? Text('$cost 円') : const Text('なし')),
              ]),
        ));
  }
}
