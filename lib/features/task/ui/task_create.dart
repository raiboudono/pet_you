import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../application/task_provider.dart';

import '../model/task.dart';
import '../../category/model/category.dart';
import '../../../constants/type/type.dart';
import '../../../constants/unit/unit.dart';
import '../../../constants/day_count/day_count.dart';

final pickedImageProvider = StateProvider.autoDispose<File?>((ref) => null);

final formFiledKeyProvider =
    Provider.family.autoDispose((ref, id) => GlobalKey<FormFieldState>());

final isReachedProvider = StateProvider.autoDispose((ref) => false);

final amountRadioIsNoneProvider = StateProvider.autoDispose((ref) => false);

class TaskCreate extends ConsumerStatefulWidget {
  const TaskCreate(this.category, {super.key});
  final Category category;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TaskCreateState();
}

class TaskCreateState extends ConsumerState<TaskCreate> {
  int _steppIndex = 0;
  Type type = Type.direct;
  Unit unit = Unit.g;
  DayCount dayCount = DayCount.once;
  final amountRadioController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    amountRadioController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
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

      ref
          .read(pickedImageProvider.notifier)
          .update((state) => File(compressedFile!.path));

      File(pickedImage.path).deleteSync();
    }

    Future<void> cropImage() async {
      final pickedImage = ref.read(pickedImageProvider);
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage!.path,
          // compressFormat: ImageCompressFormat.jpg,
          // compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: '写真の調整',
                toolbarColor: Colors.blue.withOpacity(.8),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
          ]);

      if (croppedImage == null) {
        return;
      }

      final localpath = (await getApplicationDocumentsDirectory()).path;

      final copiedFile = File(croppedImage.path)
          .copySync('$localpath/${path.basename(croppedImage.path)}');

      pickedImage.deleteSync();
      File(croppedImage.path).deleteSync();

      ref.read(pickedImageProvider.notifier).update((state) => copiedFile);
    }

    return WillPopScope(
        onWillPop: () async {
          final pickedImage = ref.read(pickedImageProvider);

          if (pickedImage?.path case String path when File(path).existsSync()) {
            File(path).deleteSync();
          }
          return true;
        },
        child: Scaffold(
            floatingActionButton: !ref.watch(isReachedProvider)
                ? null
                : FloatingActionButton.extended(
                    onPressed: () {
                      if (ref
                          .watch(formFiledKeyProvider(0))
                          .currentState!
                          .validate()) {
                        var amount = amountRadioController.text;

                        final name = ref
                            .watch(formFiledKeyProvider(0))
                            .currentState!
                            .value;

                        final discription = ref
                            .watch(formFiledKeyProvider(1))
                            .currentState!
                            .value;

                        final pickedImage = ref.read(pickedImageProvider);

                        final task = Task(
                            id: ref.read(taskProvider.notifier).assignId(),
                            name: name,
                            headerImagePath: pickedImage?.path,
                            description: discription,
                            amount: amount.isEmpty ? 0 : int.tryParse(amount),
                            categoryId: widget.category.id,
                            type: type.name,
                            unit: unit.name,
                            dayCount: dayCount.name,
                            createdAt: DateTime.now());

                        ref
                            .read(taskProvider.notifier)
                            .saveTask(widget.category, task);

                        Navigator.of(context).pop();
                      }
                    },
                    label: const Row(
                      children: [
                        Icon(Icons.done),
                        SizedBox(width: 10),
                        Text('OK')
                      ],
                    ),
                  ),
            floatingActionButtonLocation: !ref.watch(isReachedProvider)
                ? null
                : FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(),
            body: SizedBox(
                child: Stepper(
              onStepContinue: () {
                if (_steppIndex < 4) {
                  setState(() => _steppIndex += 1);
                }
                if (_steppIndex == 4) {
                  ref.read(isReachedProvider.notifier).update((state) => true);
                }
              },
              onStepCancel: () {
                if (3 < _steppIndex) {
                  setState(() => _steppIndex -= 1);
                }
              },
              onStepTapped: (int index) {
                setState(() => _steppIndex = index);
                if (_steppIndex == 4) {
                  ref.read(isReachedProvider.notifier).update((state) => true);
                }
              },
              currentStep: _steppIndex,
              controlsBuilder: (context, details) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (details.currentStep == 0)
                    // Padding(
                    //     padding: const EdgeInsets.only(top: 15, left: 15),
                    //     child: FilledButton(
                    //       onPressed: details.onStepContinue,
                    //       child: const Text('今はしない'),
                    //     )),
                    if (details.currentStep == 0) const Spacer(),
                  if (details.currentStep != 4)
                    Padding(
                        padding: const EdgeInsets.only(top: 15, right: 15),
                        child: FilledButton(
                          onPressed: details.onStepContinue,
                          child: const Text('次へ'),
                        )),
                ]);
              },
              steps: [
                Step(
                    isActive: _steppIndex == 0 ? true : false,
                    title: const Text('画像'),
                    content: Container(
                      alignment: Alignment.centerLeft,
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_camera),
                                onPressed: () => pickMedia(ImageSource.camera),
                              ),
                              IconButton(
                                icon: const Icon(Icons.photo_outlined),
                                onPressed: () => pickMedia(ImageSource.gallery),
                              ),
                              if (ref.watch(pickedImageProvider) != null)
                                TextButton(
                                  child: const Text('調整'),
                                  onPressed: () => cropImage(),
                                ),
                            ]),
                        Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue.shade100)),
                            height: 200,
                            width: 300,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final pickedImage =
                                    ref.watch(pickedImageProvider);
                                return switch (pickedImage) {
                                  File() => Hero(
                                      tag: 'image',
                                      child: Image.file(pickedImage,
                                          fit: BoxFit.cover)),
                                  _ => const SizedBox(
                                      height: 200,
                                      child: Center(child: Text("画像が未登録です")),
                                    ),
                                };
                              },
                            ))
                      ]),
                    )),
                Step(
                  isActive: _steppIndex == 1 ? true : false,
                  title: const Text.rich(TextSpan(children: [
                    TextSpan(text: '名前と詳細'),
                    TextSpan(text: '  ※必須', style: TextStyle(color: Colors.red))
                  ])),
                  content: Column(children: [
                    const SizedBox(height: 5),
                    TextFormField(
                      key: ref.watch(formFiledKeyProvider(0)),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text.rich(
                          TextSpan(
                            text: '名前',
                            children: [
                              TextSpan(
                                  text: ' ※',
                                  style: TextStyle(color: Colors.red))
                            ],
                          ),
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          setState(() => _steppIndex = 1);

                          return '入力がありません';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                        key: ref.watch(formFiledKeyProvider(1)),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '詳細',
                        ),
                        keyboardType: TextInputType.multiline),
                  ]),
                ),
                Step(
                    isActive: _steppIndex == 2 ? true : false,
                    title: const Text('1日あたりの回数'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        Flexible(
                            child: RadioListTile.adaptive(
                          title: Text(DayCount.once.name),
                          subtitle: const Text('折れ線グラフが使われます',
                              style: TextStyle(fontSize: 12)),
                          value: DayCount.once,
                          groupValue: dayCount,
                          onChanged: (DayCount? value) =>
                              setState(() => dayCount = value!),
                        )),
                      ]),
                      Row(children: [
                        Flexible(
                            child: RadioListTile.adaptive(
                          title: Text(DayCount.multiple.name),
                          subtitle: const Text('積み上げ棒グラフが使われます',
                              style: TextStyle(fontSize: 12)),
                          value: DayCount.multiple,
                          groupValue: dayCount,
                          onChanged: (DayCount? value) =>
                              setState(() => dayCount = value!),
                        ))
                      ]),
                    ])),
                Step(
                  isActive: _steppIndex == 3 ? true : false,
                  title: const Text('単位と1回あたりの量'),
                  content: Column(children: [
                    Row(children: [
                      Flexible(
                          child: RadioListTile.adaptive(
                        title: Text(Unit.g.name),
                        value: Unit.g,
                        groupValue: unit,
                        onChanged: (Unit? value) =>
                            setState(() => unit = value!),
                      )),
                      Flexible(
                          child: RadioListTile.adaptive(
                        title: Text(Unit.mg.name),
                        value: Unit.mg,
                        groupValue: unit,
                        onChanged: (Unit? value) =>
                            setState(() => unit = value!),
                      )),
                    ]),
                    RadioListTile.adaptive(
                      title: Text(Unit.minute.name),
                      value: Unit.minute,
                      groupValue: unit,
                      onChanged: (Unit? value) => setState(() => unit = value!),
                    ),
                    const Divider(thickness: 0.05, indent: 25, endIndent: 30),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(children: [
                      const SizedBox(
                        width: 26,
                      ),
                      SizedBox(
                          width: 90,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: amountRadioController,
                            onTap: () {
                              // ref
                              //     .read(amountRadioIsNoneProvider.notifier)
                              //     .update((state) => false);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '1回の量',
                            ),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(unit.name),
                      const SizedBox(
                        width: 17,
                      ),
                      // Flexible(
                      //     child: RadioListTile.adaptive(
                      //   title: const Text('なし'),
                      //   value: ref.watch(amountRadioIsNoneProvider),
                      //   groupValue: true,
                      //   onChanged: (_) {
                      //     if (amountRadioController.text.isNotEmpty) {
                      //       amountRadioController.clear();
                      //       ref
                      //           .read(amountRadioIsNoneProvider.notifier)
                      //           .update((state) => true);
                      //     } else {
                      //       ref
                      //           .read(amountRadioIsNoneProvider.notifier)
                      //           .update((state) => true);
                      //     }
                      //   },
                      // )),
                    ])
                  ]),
                ),
                Step(
                  isActive: _steppIndex == 4 ? true : false,
                  title: const Text('入力の方法'),
                  content: Column(children: [
                    Row(children: [
                      Flexible(
                          child: RadioListTile.adaptive(
                        title: Text(Type.direct.name),
                        subtitle: const Text('キーボードで入力します',
                            style: TextStyle(fontSize: 12)),
                        value: Type.direct,
                        groupValue: type,
                        onChanged: (Type? value) =>
                            setState(() => type = value!),
                      )),
                    ]),
                    RadioListTile.adaptive(
                      title: Text(Type.time.name),
                      subtitle: const Text('時間を選択して入力します',
                          style: TextStyle(fontSize: 12)),
                      value: Type.time,
                      groupValue: type,
                      onChanged: (Type? value) => setState(() => type = value!),
                    ),
                  ]),
                ),
              ],
            ))));
  }
}
