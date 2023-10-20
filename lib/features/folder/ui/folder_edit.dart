import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/folder.dart';
import '../application/pet_folder_provider.dart';

import '../../diary/ui/diary_list.dart';
import '../../diary/application/diary_provider.dart';

class FolderEdit extends ConsumerWidget {
  FolderEdit(this.folder, {super.key});
  final Folder folder;

  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(context, ref) {
    return IntrinsicWidth(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: TextFormField(
            key: formFieldKey,
            initialValue: folder.name,
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        FilledButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 150,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('${folder.name}に日記がある場合は未分類に移動されます'),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      final idMatchedDiaries = ref
                                          .read(petDiaryProvider)
                                          .where((diary) =>
                                              diary.folderId == folder.id);

                                      final petDiaryWorker =
                                          ref.read(petDiaryProvider.notifier);
                                      for (final diary in idMatchedDiaries) {
                                        petDiaryWorker.updateDiary(
                                            diary.copyWith(folderId: null));
                                      }

                                      ref
                                          .read(petFolderProvider.notifier)
                                          .removeFolder(folder);

                                      Navigator.of(context)
                                        ..pop()
                                        ..pop()
                                        ..pop()
                                        ..pop()
                                        ..push(
                                          MaterialPageRoute(builder: (context) {
                                            return const DiaryList();
                                          }),
                                        );
                                    },
                                    child: const Text('削除する',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
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
            if (formFieldKey.currentState!.validate()) {
              final now = DateTime.now();

              final petFolderWorker = ref.read(petFolderProvider.notifier);

              petFolderWorker.updateFolder(folder
                ..name = formFieldKey.currentState!.value
                ..createdAt = folder.createdAt
                ..updatedAt = now);

              Navigator.of(context)
                ..pop()
                ..pop()
                ..pop()
                ..push(
                  MaterialPageRoute(builder: (context) {
                    return const DiaryList();
                  }),
                );
            }
          },
          child: const Icon(Icons.check),
        ),
      ])
    ]));
  }
}
