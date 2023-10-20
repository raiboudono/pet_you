import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'dart:ui';

import '../../pet/application/pet_provider.dart';
import '../../category/application/category_provider.dart';

import '../application/app_setting_provider.dart';
import '../../../../layout/carousel.dart';

import '../../pet/ui/pet_create.dart';
import '../../task/ui/task_list.dart';

final tutorialControllerProvider =
    StateNotifierProvider((ref) => TutorialController(ref));

class TutorialController extends StateNotifier<String> {
  TutorialController(this.ref) : super('settingTutorial');

  final Ref ref;

  bool isTutorial() {
    return ref.read(settingProvider.notifier).isTutorial;
  }

  void updateIdentify(String nextIdentify) {
    state = nextIdentify;
  }

  String get identify => state;

  void tutorial(
      GlobalKey? key, String currentIdentify, String nextIdentify, context,
      [otherKey, focus]) {
    if (!ref.watch(settingProvider.notifier).isTutorial) {
      return;
    }

    if (identify != currentIdentify) {
      return;
    }

    TutorialCoachMark(
        hideSkip: true,
        targets: [
          if (currentIdentify != 'directButtonTutorial')
            TargetFocus(
              identify: identify,
              keyTarget: key,
              enableOverlayTab: false,
              shape: ShapeLightFocus.Circle,
              contents: [
                TargetContent(
                  align: identify == 'petTutorial'
                      ? ContentAlign.top
                      : ContentAlign.bottom,
                  builder: (context, controller) {
                    return DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            switch (identify) {
                              'settingTutorial' => const Text(
                                  '設定画面を開きます',
                                ),
                              'createTutorial' => const Text(
                                  'ペット(家族) の新規作成画面を開きます',
                                ),
                              'petTutorial' => const Text(
                                  '名前のみ入力が必須です\n\n最後まで進むと「登録OK」が表示されます',
                                ),
                              'gridTutorial' => const Text(
                                  'ペット(家族)の登録ができました！\n\nそれでは次に「食事のタスク」をおこなってみましょう',
                                ),
                              'taskListTutorial' => const Text(
                                  '食事は「サンプルご飯」です\n項目をタップして開きます',
                                ),
                              'directInputTutorial' => const Text(
                                  'ご飯の量を入力してみましょう\n',
                                ),
                              'memoInputTutorial' => const Text(
                                  '\nメモを残すことができます\n\n画面をタップして今回は「次へ」で先に進みましょう',
                                ),
                              'costInputTutorial' => const Text(
                                  '\nコストを入力することができます\n\n画面をタップして今回は「次へ」で先に進みましょう',
                                ),
                              'doneTutorial' => const Text(
                                  'ご飯の量、メモ、コストの順に進んできました\n\nどれか1つが入力されていれば「今回のタスク」として登録することができます\n\n画面をタップして「登録」で完了してください',
                                ),
                              _ => const SizedBox()
                            }
                          ],
                        ));
                  },
                ),
              ],
            ),
          if (currentIdentify == 'directButtonTutorial')
            TargetFocus(
              identify: identify,
              targetPosition: TargetPosition(const Size(50, 50),
                  Offset((otherKey as Offset).dx + 14, otherKey.dy)),
              enableOverlayTab: false,
              shape: ShapeLightFocus.Circle,
              contents: [
                TargetContent(
                  builder: (context, controller) {
                    return DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            switch (identify) {
                              'directButtonTutorial' => const Text(
                                  '「次へ」で進んでください',
                                ),
                              _ => const SizedBox()
                            }
                          ],
                        ));
                  },
                ),
              ],
            ),
        ],
        colorShadow: Colors.indigo,
        paddingFocus: 10,
        opacityShadow: .7,
        imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        onClickTarget: (target) async {
          // updateIdentify(nextIdentify);
          if (target.identify == 'settingTutorial') {
            final scaffold = otherKey as GlobalKey<ScaffoldState>;
            scaffold.currentState!.openDrawer();
            Future.delayed(const Duration(milliseconds: 500),
                () => updateIdentify(nextIdentify));
          }
          if (target.identify == 'createTutorial') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return const PetCreate();
              }),
            );
            Future.delayed(const Duration(milliseconds: 500),
                () => updateIdentify(nextIdentify));
            // updateIdentify(nextIdentify);
          }
          if (target.identify == 'gridTutorial') {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Carousel(
                      ref.read(petProvider).first!, ref.read(categoryProvider));
                });
            updateIdentify(nextIdentify);
          }
          if (target.identify == 'taskListTutorial') {
            ref
                .read(selectExpansionIndexProvider.notifier)
                .update((state) => 0);
            Future.delayed(const Duration(milliseconds: 500),
                () => updateIdentify(nextIdentify));
            // updateIdentify(nextIdentify);
          }
          if (target.identify == 'directInputTutorial') {
            (focus as FocusNode).requestFocus();
          }
          if (target.identify == 'directButtonTutorial') {
            // (otherKey as PageController).nextPage(
            //     duration: const Duration(milliseconds: 500),
            //     curve: Curves.fastEaseInToSlowEaseOut);

            // controller.animateTo(offset, duration: duration, curve: curve)
            // controller.animateToPage(page, duration: duration, curve: curve)
            // controller.jumpTo(value)
            // (otherKey as PageController).jumpToPage(1);
          }
        },
        onFinish: () {
          // updateIdentify(nextIdentify);
          updateIdentify(nextIdentify);
        }).show(context: context);
  }
}
