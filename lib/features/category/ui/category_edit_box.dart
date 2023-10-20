import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/category_provider.dart';
import '../../pet/application/pet_provider.dart';
import '../model/category.dart';
import '../../pet/model/pet.dart';

import '../../../features/task/ui/icon.dart';

class CategoryEditBox extends ConsumerStatefulWidget {
  const CategoryEditBox(this.category, this.pet, {super.key});
  final Category? category;
  final Pet pet;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CategoryEditBoxState();
}

class CategoryEditBoxState extends ConsumerState<CategoryEditBox> {
  final form = GlobalKey<FormState>();
  final controller = ExpansionTileController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  int? iconCodePoint;

  @override
  void initState() {
    nameController.text = widget.category != null ? widget.category!.name : '';
    descriptionController.text =
        (widget.category != null ? widget.category!.description : '') ?? '';
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return IntrinsicWidth(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      ExpansionTile(
          childrenPadding: const EdgeInsets.only(top: 10, left: 30, bottom: 10),
          shape: const Border(),
          controller: controller,
          controlAffinity: ListTileControlAffinity.leading,
          title: Form(
              key: form,
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'カテゴリ名',
                  prefixIcon: iconCodePoint != null
                      ? Icon(
                          IconData(iconCodePoint!, fontFamily: 'MaterialIcons'))
                      : widget.category?.iconCodePoint != null
                          ? Icon(IconData(widget.category!.iconCodePoint!,
                              fontFamily: 'MaterialIcons'))
                          : const Icon(Icons.select_all),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "カテゴリ名の入力がありません";
                  }
                  return null;
                },
              )),
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: GridView.count(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 4,
                    children: [
                      ...List.generate(
                          icons.length,
                          (index) => IconButton(
                              onPressed: () {
                                setState(() {
                                  iconCodePoint = icons[index];
                                });

                                controller.isExpanded
                                    ? controller.collapse()
                                    : controller.expand();
                              },
                              icon: Icon(IconData(icons[index],
                                  fontFamily: 'MaterialIcons'))))
                    ])),
          ]),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: '詳細',
            ),
          )),
      const SizedBox(height: 20),
      Row(
          mainAxisAlignment: widget.category != null
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.end,
          children: [
            if (widget.category != null)
              FilledButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                            height: 130,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text('削除しますか？'),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(categoryProvider.notifier)
                                                .removeCategory(
                                                    widget.category!);

                                            final categoryIdSelectedList = [
                                              ...widget.pet.categoryIds
                                            ];
                                            categoryIdSelectedList
                                                .remove(widget.category!.id);

                                            // widget.pet.categoryIds =
                                            //     categoryIdSelectedList;

                                            ref
                                                .read(petProvider.notifier)
                                                .updatePet(widget.pet.copyWith(
                                                    categoryIds: [
                                                      ...categoryIdSelectedList
                                                    ]));

                                            Navigator.of(context)
                                              ..pop()
                                              ..pop();
                                          },
                                          child: const Text('削除する',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop(),
                                          child: const Text("キャンセル"),
                                        )
                                      ])
                                ]));
                      });
                },
                child: const Icon(Icons.delete),
              ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) {
                  final (name, description) =
                      (nameController.text, descriptionController.text);
                  Category category;
                  if (widget.category != null) {
                    category = widget.category!.copyWith(
                        name: name,
                        description: description,
                        iconCodePoint:
                            iconCodePoint ?? widget.category?.iconCodePoint,
                        createdAt: widget.category!.createdAt);

                    ref
                        .read(categoryProvider.notifier)
                        .updateCategory(category);
                  } else {
                    category = Category(
                        id: ref.read(categoryProvider.notifier).assignId(),
                        name: name,
                        description: description,
                        iconCodePoint: iconCodePoint,
                        createdAt: DateTime.now());

                    ref.read(categoryProvider.notifier).saveCategory(category);
                  }

                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.check),
            ),
            if (widget.category == null) const SizedBox(width: 20)
          ])
    ]));
  }
}
