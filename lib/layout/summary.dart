import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../../layout/home.dart';

import '../features/category/application/category_provider.dart';
import '../features/pet/application/pet_provider.dart';
import '../features/task/application/task_provider.dart';

import '../graph/pie_chart.dart';
import '../graph/table.dart' as summary;

final categoriyNamesIndexProvider = StateProvider((ref) => 0);

final isCostDisplayProvider = StateProvider.autoDispose((ref) => false);

final categoryIdController = StateProvider((ref) {
  final categories = ref.watch(categoryProvider).nonNulls.toList();

  final categoriyNamesIndex = ref.watch(categoriyNamesIndexProvider);

  if (categories.isEmpty) {
    return null;
  }

  return categories[categoriyNamesIndex].id;
});

class Summary extends ConsumerWidget {
  const Summary({super.key});

  @override
  Widget build(context, ref) {
    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[petIndex];
    final categories = ref
        .watch(categoryProvider)
        .nonNulls
        .where((category) => category.visible)
        .toList();

    final isCostDisplay = ref.watch(isCostDisplayProvider);

    final petTaskActivities =
        ref.watch(taskProvider.notifier).findActivityAllByPetId(pet.id);

    final categoryNames = petTaskActivities
        .map(
          (activity) {
            return activity!.categoryName!;
          },
        )
        .toSet()
        .toList();

    final categoryNamesIndex = ref.watch(categoriyNamesIndexProvider);

    // final activitiesByCategoryNames = categoryNames.mapIndexed(
    //   (index, name) {
    //     return petTaskActivities
    //         .where((activity) => activity!.categoryName! == name)
    //         .toList();
    //   },
    // ).toList();

    return Scaffold(
        drawerEdgeDragWidth: 0,
        endDrawer: Drawer(
            width: 230,
            child: Scaffold(
                appBar: AppBar(),
                body: ListView.builder(
                    itemCount: categoryNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            ref
                                .read(categoriyNamesIndexProvider.notifier)
                                .update((state) => index);
                            Navigator.of(context).pop();
                          },
                          title: Text(categoryNames[index]),
                          trailing: switch (index == categoryNamesIndex) {
                            true =>
                              const Icon(Icons.check, color: Colors.tealAccent),
                            _ => null
                          });
                    }))),
        appBar: AppBar(actions: [
          TextButton.icon(
            onPressed: () {
              ref
                  .read(isCostDisplayProvider.notifier)
                  .update((state) => !state);
            },
            icon: const Icon(Icons.calculate_outlined),
            label: isCostDisplay ? const Text('タスク') : const Text('コスト'),
          ),
          Builder(builder: (context) {
            return TextButton.icon(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.local_activity_outlined),
                label: const Text('カテゴリ'));
          }),
          const SizedBox(width: 5)
        ]),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(
              height: 50,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(width: 16),
                if (pet.headerImagePath case final String path
                    when File(path).existsSync())
                  CircleAvatar(
                      backgroundImage: Image.file(
                    File(path),
                  ).image),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_right, size: 22),
                const SizedBox(width: 5),
                const Text('まとめ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_right, size: 22),
                const SizedBox(width: 5),
                if (categories.isNotEmpty && categoryNames.isNotEmpty)
                  Text(categoryNames[categoryNamesIndex],
                      style: const TextStyle(fontSize: 13)),
              ])),
          const PieChart(),
          const summary.Table(),
        ])));
  }
}
