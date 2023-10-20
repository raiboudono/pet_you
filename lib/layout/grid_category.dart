import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../layout/home.dart';

import 'carousel.dart';

import '../features/pet/application/pet_provider.dart';
import '../features/category/application/category_provider.dart';

import '../features/setting/application/tutorial_controller.dart';

import '../features/setting/application/app_setting_provider.dart';

final carouselIndexProvider = StateProvider((ref) => 0);

class GridCategory extends ConsumerStatefulWidget {
  const GridCategory({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => GridCategoryState();
}

class GridCategoryState extends ConsumerState<GridCategory> {
  GlobalKey gridTutorial = GlobalKey();

  @override
  initState() {
    super.initState();
    if (ref.read(settingProvider.notifier).isTutorial &&
        ref.read(tutorialControllerProvider.notifier).identify ==
            'gridTutorial') {
      final tutorialControllerNotifier =
          ref.read(tutorialControllerProvider.notifier);
      Future.delayed(
          const Duration(seconds: 3),
          () => tutorialControllerNotifier.tutorial(
              gridTutorial, 'gridTutorial', 'taskListTutorial', context));
    }
  }

  @override
  Widget build(context) {
    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();

    if (pets.isEmpty) {
      return const SliverToBoxAdapter();
    }

    final pet = pets[petIndex];

    final allCategories = ref.watch(categoryProvider).nonNulls.toList();

    final categories = [
      for (final category in allCategories)
        if (category.visible && pet.categoryIds.contains(category.id)) category
    ];

    if (categories.isNotEmpty) {
      categories.sort((a, b) => a.position!.compareTo(b.position!));
    }

    return SliverPadding(
        padding: const EdgeInsets.only(left: 45, right: 45),
        sliver: SliverGrid.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 0,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              return SizedBox(
                  child: Column(children: [
                IconButton(
                    key: index == 0 ? gridTutorial : null,
                    style: ButtonStyle(
                        iconSize: MaterialStateProperty.all(26),
                        fixedSize:
                            MaterialStateProperty.all(const Size(53, 53)),
                        overlayColor: MaterialStateProperty.all(
                            Colors.blue.withOpacity(.5)),
                        backgroundColor: MaterialStateProperty.all(
                            Colors.blue.withOpacity(.08)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ))),
                    color: Colors.black.withOpacity(.75),
                    icon: categories[index].iconCodePoint != null
                        ? Icon(IconData(categories[index].iconCodePoint!,
                            fontFamily: 'MaterialIcons'))
                        : Icon(Icons.select_all,
                            color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      ref
                          .read(carouselIndexProvider.notifier)
                          .update((state) => index);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return Carousel(pet, categories);
                          });
                    }),
                const SizedBox(height: 4),
                Text(categories[index].name,
                    style: const TextStyle(fontSize: 8)),
              ]));
            }));
  }
}
