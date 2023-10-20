import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/folder.dart';
import '../application/pet_folder_provider.dart';

import '../../diary/ui/diary_list.dart';

class FolderCreate extends ConsumerWidget {
  FolderCreate({super.key});

  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(context, ref) {
    return IntrinsicWidth(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: TextFormField(
            key: formFieldKey,
            decoration: const InputDecoration(
              hintText: 'フォルダ名',
            ),
            validator: (String? value) {
              if (value!.isEmpty) {
                return "入力がありません";
              }
              return null;
            },
          )),
      Align(
          widthFactor: 3.5,
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              if (formFieldKey.currentState!.validate()) {
                final now = DateTime.now();

                final petFolderWorker = ref.read(petFolderProvider.notifier);

                petFolderWorker.saveFolder(Folder()
                  ..name = formFieldKey.currentState!.value
                  ..createdAt = now
                  ..updatedAt = now);
              }

              Navigator.of(context)
                ..pop()
                ..pop()
                ..pop()
                ..push(
                  MaterialPageRoute(builder: (context) {
                    return const DiaryList();
                  }),
                );
            },
            child: const Icon(Icons.check),
          )),
    ]));
  }
}
