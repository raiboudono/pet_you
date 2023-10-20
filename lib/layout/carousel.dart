import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'grid_category.dart';
import '../features/pet/model/pet.dart';
import '../features/category/model/category.dart';

import '../features/task/ui/task_list.dart';
import '../features/task/ui/task_item.dart';

class Carousel extends ConsumerWidget {
  const Carousel(this.pet, this.petCategories, {super.key});
  final Pet pet;
  final List<Category?> petCategories;

  @override
  Widget build(context, ref) {
    final carouselIndex = ref.watch(carouselIndexProvider);

    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, actions: [
          CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              // foregroundColor: Colors.transparent,
              child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const SimpleDialog(
                            contentPadding: EdgeInsets.all(15),
                            children: [
                              Text(
                                  'タスクは「量」「メモ」「コスト」の3つで構成されています\n\n どれか1つを入力しても全てを入力しても「今回のタスク」として記録されます\n\n 量でなくメモで記録したい、コストは毎回入力する必要がないなど、状況に適した入力が可能です ')
                            ]);
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.question_mark,
                    size: 11,
                  ))),
          const SizedBox(width: 10)
        ]),
        backgroundColor: Colors.transparent,
        body: Align(
            alignment: Alignment.topCenter,
            // height: 500,
            child: CarouselSlider(
                options: CarouselOptions(
                    initialPage: carouselIndex,
                    viewportFraction: 1,
                    height: 600,
                    onPageChanged:
                        (int index, CarouselPageChangedReason reason) {
                      if (carouselIndex < pet.categoryIds.length - 1) {
                        ref
                            .read(carouselIndexProvider.notifier)
                            .update((state) => state + 1);
                        ref.invalidate(selectExpansionIndexProvider);
                        ref.invalidate(pageViewControllerProvider);
                        ref.invalidate(activeStepProvider);
                        ref.invalidate(isMemoListDisplayProvider);
                      } else {
                        ref
                            .read(carouselIndexProvider.notifier)
                            .update((state) => state = 0);
                        ref.invalidate(selectExpansionIndexProvider);
                        ref.invalidate(pageViewControllerProvider);
                        ref.invalidate(activeStepProvider);
                        ref.invalidate(isMemoListDisplayProvider);
                      }
                    }),
                items: [TaskList(pet, petCategories)])));
  }
}
