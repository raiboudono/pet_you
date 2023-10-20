import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../layout/home.dart';

import '../../category/ui/category_edit_box.dart';

import '../../pet/application/pet_provider.dart';
import '../../category/application/category_provider.dart';

class ReorderableCategoryCheckboxList extends ConsumerWidget {
  const ReorderableCategoryCheckboxList({super.key});

  @override
  Widget build(context, ref) {
    final categories = ref
        .watch(categoryProvider)
        .nonNulls
        .where((category) => category.visible)
        .toList();

    categories.sort((a, b) => a.position!.compareTo(b.position!));

    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[petIndex];

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            actions: [
              TextButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                              children: [CategoryEditBox(null, pet)]);
                        });
                  },
                  label: const Text('カテゴリ新規作成',
                      style: TextStyle(color: Colors.white)),
                  icon: const Icon(color: Colors.white, Icons.add, size: 20)),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  ref
                      .read(editableSwitchProvider.notifier)
                      .update((state) => !state);
                },
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(
                //         Colors.indigoAccent.withOpacity(.2))),
                child:
                    const Text("タスク編集", style: TextStyle(color: Colors.white)),
              ),
            ]),
        body: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
                shadowColor: Colors.transparent),
            child: ReorderableListView.builder(
                itemCount: categories.length,
                onReorder: (int oldIndex, int newIndex) {
                  ref
                      .read(categoryProvider.notifier)
                      .reorder(oldIndex, newIndex);

                  ref.read(petProvider.notifier).updatePet(pet);
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                      key: Key('$index'),
                      height: 73,
                      child: FractionallySizedBox(
                          key: Key('$index'),
                          heightFactor: .88,
                          widthFactor: .95,
                          child: CheckboxListTile(
                              key: Key('$index'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 0, 10, 0),
                              tileColor: Colors.white.withOpacity(.9),
                              title: Row(children: [
                                categories[index].iconCodePoint != null
                                    ? Icon(
                                        IconData(
                                            categories[index].iconCodePoint!,
                                            fontFamily: 'MaterialIcons'),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withOpacity(.8))
                                    : Icon(Icons.select_all,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(children: [
                                              CategoryEditBox(
                                                  categories[index], pet)
                                            ]);
                                          });
                                    },
                                    child: Text(categories[index].name,
                                        style: const TextStyle(fontSize: 16)))
                              ]),
                              onChanged: (_) {
                                ref
                                    .read(petProvider.notifier)
                                    .addOrRemoveCategoryId(
                                        pet, categories[index].id);
                              },
                              value: pet.categoryIds
                                  .contains(categories[index].id))));
                })));
  }
}
