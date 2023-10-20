import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:futter_you/features/setting/model/app_setting.dart';

import '../layout/layout.dart';

import '../features/category/application/category_provider.dart';
import '../features/task/application/task_provider.dart';

import '../features/category/model/category.dart';
import '../features/task/model/task.dart';

import '../features/setting/application/app_setting_provider.dart';

final selectedIndexProvider = StateProvider.autoDispose((ref) => 0);
final pageViewControllerProvider =
    StateProvider.autoDispose((ref) => PageController());

class Onbording extends ConsumerWidget {
  const Onbording({super.key});

  @override
  Widget build(context, ref) {
    final overviews = [
      'PetYouは、ペット(家族)の活動を記録したり、タスクとして管理できます。',
      '活動の履歴は「リスト」「グラフ」「まとめ」など、様々な方法で確認。',
      '様々な活動は、食事やお出かけなどのカテゴリに分けて管理。\n\n表示、非表示を切り替えて必要な情報に素早くアクセス。',
      'それではペット(家族)の登録をしてみましょう',
    ];

    final selectedIndex = ref.watch(selectedIndexProvider);

    final PageController controller = PageController();

    return Scaffold(
        body: SizedBox(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(
          child: PageView.builder(
        onPageChanged: (index) {
          ref.read(selectedIndexProvider.notifier).update((state) => index);
        },
        itemCount: overviews.length,
        controller: controller,
        itemBuilder: (context, index) {
          return Column(children: [
            const SizedBox(height: 100),
            Image.asset(
                width: index != overviews.length - 1 ? 400 : null,
                height: index != overviews.length - 1 ? 300 : null,
                cacheWidth: index == overviews.length - 1 ? 400 : null,
                cacheHeight: index == overviews.length - 1 ? 300 : null,
                switch (index) {
                  0 => 'assets/onbording/task.jpg',
                  1 => 'assets/onbording/graph.jpg',
                  2 => 'assets/onbording/check.jpg',
                  _ => 'assets/images/harinezumi.jpg',
                }),
            const SizedBox(height: 50),
            Builder(
              builder: (context) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 2500),
                  builder: (context, opacity, child) {
                    return Opacity(
                        opacity: opacity,
                        child: Container(
                            // color: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                            ),
                            child: Text(overviews[index],
                                style: const TextStyle(
                                    fontSize: 20, letterSpacing: 2))));
                  },
                );
              },
            ),
          ]);
        },
      )),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Visibility(
            visible: 0 < ref.watch(selectedIndexProvider),
            replacement: const SizedBox(width: 80),
            child: FilledButton(
                onPressed: () {
                  controller.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                  ref
                      .read(selectedIndexProvider.notifier)
                      .update((state) => state - 1);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent.shade100),
                child: const Icon(Icons.navigate_before))),
        const SizedBox(width: 80),
        FilledButton(
            onPressed: () {
              controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
              ref
                  .read(selectedIndexProvider.notifier)
                  .update((state) => state + 1);

              if (selectedIndex == 3) {
                ref
                    .read(settingProvider.notifier)
                    .saveSetting(AppSetting()..createdAt = DateTime.now());

                final category = Category(
                    id: ref.read(categoryProvider.notifier).assignId(),
                    name: '食事',
                    description: 'ドライフードや手作りご飯',
                    createdAt: DateTime.now());
                ref.read(categoryProvider.notifier).saveCategory(category);

                ref.read(taskProvider.notifier).saveTask(
                    ref.read(categoryProvider).first!,
                    Task(
                        id: ref.read(taskProvider.notifier).assignId(),
                        name: 'サンプルご飯',
                        description: 'タンパク質、炭水化物のバランスのとれたご飯',
                        categoryId: 1,
                        amount: 0,
                        headerImagePath: 'assets/images/dog_food.jpg',
                        type: '直接',
                        unit: 'g',
                        dayCount: '1回',
                        createdAt: DateTime.now()));

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const Layout()));
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent.shade100),
            child: const Icon(Icons.navigate_next))
      ]),
      const SizedBox(height: 30)
    ])));
  }
}
