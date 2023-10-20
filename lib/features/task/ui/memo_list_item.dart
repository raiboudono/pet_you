import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../application/task_provider.dart';

import '../../pet/model/pet.dart';
import '../model/task_activity.dart';
// import '../../task/model/task.dart';

import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';

final imageProvider = StateProvider.autoDispose<File?>((ref) => null);

final memoFormFieldProvider =
    StateProvider.autoDispose((ref) => GlobalKey<FormFieldState>());

class MemoListItem extends ConsumerWidget {
  const MemoListItem(this.pet, this.activity, {super.key});
  final Pet pet;
  final TaskActivity? activity;

  @override
  Widget build(context, ref) {
    final memoFormField = ref.watch(memoFormFieldProvider);

    Future<void> pickMedia(ImageSource source) async {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: source);

      if (pickedImage == null) {
        return;
      }

      final localpath = (await getApplicationDocumentsDirectory()).path;

      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedImage.path, '$localpath/${path.basename(pickedImage.path)}',
          quality: 100);

      ref.read(imageProvider.notifier).state = File(compressedFile!.path);

      File(pickedImage.path).deleteSync();
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Consumer(
              builder: (context, ref, _) {
                final image = ref.watch(imageProvider);
                return switch (image?.path ?? activity?.headerImagePath) {
                  final String path when File(path).existsSync() => ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                  ),
                                  body: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: PhotoView(
                                              wantKeepAlive: false,
                                              imageProvider: Image.file(
                                                File(path),
                                                fit: BoxFit.cover,
                                              ).image))),
                                  bottomNavigationBar: SizedBox(
                                      height: 80,
                                      child: BottomNavigationBar(
                                        backgroundColor: Colors.black,
                                        selectedItemColor:
                                            Colors.green.shade200,
                                        unselectedItemColor:
                                            Colors.green.shade200,
                                        onTap: (index) async {
                                          if (index == 0) {
                                            await Share.shareXFiles(
                                                [XFile(File(path).path)],
                                                subject: '', text: '');
                                          } else {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return SizedBox(
                                                      height: 130,
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Text(
                                                                '削除しますか？'),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      ref.read(taskProvider.notifier).updateActivity(activity!.copyWith(
                                                                          headerImagePath:
                                                                              null));

                                                                      ref.invalidate(
                                                                          memoFormFieldProvider);

                                                                      Navigator.of(
                                                                          context)
                                                                        ..pop()
                                                                        ..pop();
                                                                    },
                                                                    child: const Text(
                                                                        '削除する',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red)),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child: const Text(
                                                                        "キャンセル"),
                                                                  )
                                                                ])
                                                          ]));
                                                });
                                          }
                                        },
                                        items: const [
                                          BottomNavigationBarItem(
                                            label: '共有',
                                            icon: Icon(Icons.share),
                                          ),
                                          BottomNavigationBarItem(
                                              label: '削除',
                                              icon: Icon(Icons.delete)),
                                        ],
                                      )));
                            }));
                          },
                          child: Image.file(
                              height: 130,
                              width: 190,
                              File(path),
                              fit: BoxFit.cover))),
                  _ => const SizedBox(child: Center(child: Text('画像がありません')))
                };
              },
            ),
            SizedBox(
                height: 100,
                child: Column(children: [
                  IconButton(
                      onPressed: () => pickMedia(ImageSource.camera),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.photo_camera,
                      )),
                  const Spacer(),
                  IconButton(
                      onPressed: () => pickMedia(ImageSource.gallery),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.photo_outlined,
                      ))
                ])),
          ]),
          const SizedBox(height: 20),
          TextFormField(
            key: memoFormField,
            initialValue: activity?.memo ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            FilledButton(
                child: const Icon(Icons.delete),
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
                                                .read(taskProvider.notifier)
                                                .updateActivity(activity!
                                                    .copyWith(
                                                        memo: null,
                                                        headerImagePath: null));

                                            Navigator.of(context)
                                              ..pop()
                                              ..pop();
                                          },
                                          child: const Text('削除する',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                          ),
                                          child: const Text("キャンセル"),
                                        )
                                      ])
                                ]));
                      });
                }),
            FilledButton(
                child: const Icon(Icons.done),
                onPressed: () {
                  ref.read(taskProvider.notifier).updateActivity(activity!
                      .copyWith(
                          memo: memoFormField.currentState?.value,
                          headerImagePath: ref.read(imageProvider)?.path ??
                              activity!.headerImagePath));

                  ref.invalidate(taskProvider);

                  Navigator.of(context).pop();
                })
          ])
        ]));
  }
}
