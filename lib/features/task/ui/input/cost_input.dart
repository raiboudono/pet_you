import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setting/application/tutorial_controller.dart';
import '../../../setting/application/app_setting_provider.dart';

import '../../../task/application/task_provider.dart';

import '../../../pet/model/pet.dart';
import '../../model/task.dart';

final costFormFieldProvider =
    Provider.autoDispose((ref) => GlobalKey<FormFieldState>());

class CostInput extends ConsumerStatefulWidget {
  const CostInput(this.pet, this.task, {super.key});
  final Pet pet;
  final Task task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CostInputState();
}

class CostInputState extends ConsumerState<CostInput>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey costInputTutorial = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (ref.read(settingProvider.notifier).isTutorial) {
      final tutorialControllerNotifier =
          ref.read(tutorialControllerProvider.notifier);
      Future.delayed(
          const Duration(milliseconds: 800),
          () => tutorialControllerNotifier.tutorial(
                costInputTutorial,
                'costInputTutorial',
                'doneTutorial',
                context,
              ));
    }
  }

  @override
  Widget build(context) {
    super.build(context);

    final costFormField = ref.watch(costFormFieldProvider);

    final activities =
        ref.watch(taskProvider.notifier).findActivityAllByPetId(widget.pet.id);

    final now = DateTime.now();

    final costActivity = activities
        .where((activity) =>
            activity?.cost != null &&
            activity?.taskId == widget.task.id &&
            activity?.createdAt?.month == now.month)
        .toList();

    final int? totalCost;
    if (costActivity.isNotEmpty) {
      totalCost = costActivity
          .map((activity) => activity!.cost)
          .reduce((v1, v2) => v1! + v2!);
    } else {
      totalCost = 0;
    }

    return WillPopScope(
        onWillPop: () async {
          if (ref.read(settingProvider.notifier).isTutorial) {
            return Future.value(false);
          }
          return true;
        },
        child: SizedBox(
          key: costInputTutorial,
          width: 210,
          // color: Colors.blue.shade100,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(child: Text('${now.month}月: 累計金額')),
                      Text('$totalCost 円')
                    ]),
                SizedBox(
                    height: 117,
                    // width: 220,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                              width: 110,
                              child: TextFormField(
                                  key: costFormField,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '金額',
                                  ))),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('円')
                        ])),
              ]),
        ));
  }
}
