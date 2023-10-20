import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/task.dart';
import '../../../pet/model/pet.dart';
// import '../../pet/model/pet_task_activity.dart';
// import '../../worker.dart';

import '../task_item.dart';
// import '../../../../features/other/setting/application/tutorial_controller.dart';
import '../../../setting/application/tutorial_controller.dart';
import '../../../setting/application/app_setting_provider.dart';

final focusProvider = Provider((ref) => FocusNode());

class DirectInput extends ConsumerStatefulWidget {
  const DirectInput(this.pet, this.task, {super.key});

  final Pet pet;
  final Task? task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => DirectInputState();
}

class DirectInputState extends ConsumerState<DirectInput>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController inputController = TextEditingController();
  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();

    if (ref.read(settingProvider.notifier).isTutorial) {
      final tutorialControllerNotifier =
          ref.read(tutorialControllerProvider.notifier);

      Future.delayed(
          const Duration(milliseconds: 800),
          () => tutorialControllerNotifier.tutorial(
              formFieldKey,
              'directInputTutorial',
              'directButtonTutorial',
              context,
              null,
              ref.read(focusProvider)));
    }
  }

  @override
  void dispose() {
    super.dispose();
    inputController.dispose();
  }

  @override
  Widget build(context) {
    super.build(context);
    final focus = ref.watch(focusProvider);

    final amount = ref.watch(amountProvider);
    inputController.text = amount != 0 ? amount.toString() : '';
    int? tmpAmount = ref.watch(tmpAmountProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tmpAmount is int) {
        ref.read(amountProvider.notifier).update((state) => tmpAmount);
      }
    });

    return WillPopScope(
        onWillPop: () async {
          if (ref.read(settingProvider.notifier).isTutorial) {
            return Future.value(false);
          }
          return true;
        },
        child: Material(
            child: Container(
                decoration: BoxDecoration(
                    // border: Border.all(width: .15),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                child: SizedBox(
                    child: Row(children: [
                  SizedBox(
                      // color: Colors.blue,
                      width: 190,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const SizedBox(height: 15),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 50),
                                  SizedBox(
                                      width: 90,
                                      child: Focus(
                                        child: TextFormField(
                                            focusNode: focus,
                                            controller: inputController,
                                            key: formFieldKey,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: ''),
                                            onFieldSubmitted: (value) {
                                              ref
                                                  .read(tmpAmountProvider
                                                      .notifier)
                                                  .update((state) =>
                                                      int.tryParse(value));
                                            }),
                                        onFocusChange: (hasFocus) {
                                          final value = int.tryParse(
                                              formFieldKey.currentState!.value);
                                          if (!hasFocus) {
                                            ref
                                                .read(
                                                    tmpAmountProvider.notifier)
                                                .update((state) => value);
                                          }

                                          if (!hasFocus &&
                                              value != null &&
                                              value != 0) {
                                            final tutorialControllerNotifier =
                                                ref.read(
                                                    tutorialControllerProvider
                                                        .notifier);

                                            if (tutorialControllerNotifier
                                                .isTutorial()) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 800),
                                                  () => tutorialControllerNotifier
                                                      .tutorial(
                                                          null,
                                                          'directButtonTutorial',
                                                          'memoInputTutorial',
                                                          context,
                                                          ref.read(
                                                              buttonOffsetProvider),
                                                          null));
                                            }
                                          }
                                        },
                                      )),
                                  const SizedBox(width: 10),
                                  Text(widget.task!.unit!),
                                ]),
                            const SizedBox(height: 15),
                          ])),
                  SizedBox(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        Container(
                            decoration: const ShapeDecoration(
                              color: Color.fromARGB(20, 3, 168, 244),
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(tmpAmountProvider.notifier)
                                    .update((state) => state = amount! + 1);
                              },
                              icon: const Icon(Icons.add),
                            )),
                        Container(
                            decoration: const ShapeDecoration(
                              color: Color.fromARGB(20, 233, 30, 98),
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (amount! <= 0) {
                                  return;
                                }
                                ref
                                    .read(tmpAmountProvider.notifier)
                                    .update((state) => state = amount - 1);
                              },
                              icon: const Icon(Icons.remove),
                            ))
                      ])),
                ])))));
  }
}
