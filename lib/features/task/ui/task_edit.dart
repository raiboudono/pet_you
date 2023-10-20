import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:image_cropper/image_cropper.dart';

import '../application/task_provider.dart';
import '../../pet/application/pet_provider.dart';

import '../model/task.dart';
import '../../category/model/category.dart';
import '../../../constants/type/type.dart';
import '../../../constants/unit/unit.dart';
import '../../../constants/day_count/day_count.dart';
import '../../pet/model/pet.dart';

final formKeyProvider = Provider((ref) => GlobalKey<FormState>());
final pickedImageProvider = StateProvider.autoDispose<File?>((ref) => null);

class TaskEdit extends ConsumerStatefulWidget {
  const TaskEdit(this.category, this.task, this.pet, {super.key});
  final Category category;
  final Task task;
  final Pet pet;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TaskEditState();
}

class TaskEditState extends ConsumerState<TaskEdit> {
  final profiles = ['名前', '詳細'];
  final options = ['1回の量', '単位', '入力タイプ', '1日の回数'];

  final selectedTypeController = TextEditingController();
  final selectedUnitController = TextEditingController();
  final selectedDayCountController = TextEditingController();

  @override
  void initState() {
    selectedTypeController.text = widget.task.type!;
    selectedUnitController.text = widget.task.unit!;
    selectedDayCountController.text = widget.task.dayCount!;

    super.initState();
  }

  @override
  void dispose() {
    selectedTypeController.dispose();
    selectedUnitController.dispose();
    selectedDayCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(formKeyProvider);

    late String? saveDiscription;
    late String? saveAmount;

    Future<void> getMedia(ImageSource source) async {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: source);

      if (pickedImage == null) {
        return;
      }

      final File imageFile = File(pickedImage.path);

      final localpath = (await getApplicationDocumentsDirectory()).path;

      final copiedImageFile =
          await imageFile.copy('$localpath/${path.basename(imageFile.path)}');

      ref.read(pickedImageProvider.notifier).state = copiedImageFile;

      imageFile.deleteSync();

      // /data/user/0/com.miya.pet_you/cache/cdd62a28-872a-4637-99c4-83df96fcc3ed8127331262108195544.jpg

      //  /data/user/0/com.miya.pet_you/cache/f7ce3fcb-3772-443f-9499-5e4a6e9cdaf0/1696487265785.jpg
    }

    Future<void> cropImage() async {
      final pickedImage = ref.read(pickedImageProvider);
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage?.path ?? widget.task.headerImagePath!,
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

      if (pickedImage != null) {
        pickedImage.deleteSync();
      }
      File(croppedImage.path).deleteSync();

      ref.read(pickedImageProvider.notifier).update((state) => copiedFile);
    }

    /*リビルド用 */
    ref.watch(taskProvider);

    return WillPopScope(
        onWillPop: () async {
          final pickedImage = ref.read(pickedImageProvider);

          if (pickedImage?.path case final String path
              when File(path).existsSync()) {
            File(path).deleteSync();
          }
          return true;
        },
        child: Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
                child: Column(children: [
              Consumer(
                builder: (context, ref, _) {
                  final pickedImage = ref.watch(pickedImageProvider);
                  return SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: switch (
                          pickedImage?.path ?? widget.task.headerImagePath) {
                        String path when File(path).existsSync() => Hero(
                            tag: 'image',
                            child:
                                Image.file(File(path), fit: BoxFit.fitWidth)),
                        String path when path.startsWith('asset') =>
                          Image.asset(path),
                        _ => const SizedBox(
                            height: 350,
                            child: Center(child: Text("画像が未登録です")),
                          ),
                      });
                },
              ),
              SizedBox(
                height: 80,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                      onPressed: () => getMedia(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera)),
                  const SizedBox(width: 20),
                  IconButton(
                      onPressed: () => getMedia(ImageSource.gallery),
                      icon: const Icon(Icons.photo_outlined)),
                  if (ref.watch(pickedImageProvider) != null ||
                      widget.task.headerImagePath != null)
                    const SizedBox(width: 20),
                  if (ref.watch(pickedImageProvider) != null ||
                      widget.task.headerImagePath != null)
                    TextButton(
                      child: const Text('調整'),
                      onPressed: () => cropImage(),
                    ),
                  const SizedBox(width: 30)
                ]),
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                      width: 300,
                      child: Form(
                          key: form,
                          onWillPop: () {
                            return Future.value(true);
                          },
                          child: Column(children: [
                            ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: profiles.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: TextFormField(
                                          initialValue: profiles[index] == '名前'
                                              ? widget.task.name
                                              : widget.task.description,
                                          keyboardType: profiles[index] == '詳細'
                                              ? TextInputType.multiline
                                              : null,
                                          maxLines: profiles[index] == '詳細'
                                              ? null
                                              : 1,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            label: profiles[index] == '名前'
                                                ? Text.rich(
                                                    TextSpan(
                                                      text: profiles[index],
                                                      children: const [
                                                        TextSpan(
                                                            text: ' ※',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red))
                                                      ],
                                                    ),
                                                  )
                                                : Text(profiles[index]),
                                          ),
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty &&
                                                    profiles[index] == '名前') {
                                              return "名前の入力がありません";
                                            }

                                            saveDiscription = value;

                                            return null;
                                          },
                                          onSaved: (String? value) {
                                            if (profiles[index] == '名前') {
                                              final pickedImage =
                                                  ref.read(pickedImageProvider);

                                              if (pickedImage != null &&
                                                  widget.task.headerImagePath !=
                                                      null) {
                                                if (File(widget
                                                        .task.headerImagePath!)
                                                    .existsSync()) {
                                                  File(widget.task
                                                          .headerImagePath!)
                                                      .deleteSync();

                                                  // widget.task.headerImagePath =
                                                  //     null;
                                                }
                                              }
                                              final (type, unit, dayCount) = (
                                                selectedTypeController.text,
                                                selectedUnitController.text,
                                                selectedDayCountController.text
                                              );

                                              final task = widget.task.copyWith(
                                                  name: value!,
                                                  headerImagePath:
                                                      pickedImage?.path ??
                                                          widget.task
                                                              .headerImagePath,
                                                  description: saveDiscription,
                                                  amount: int.tryParse(
                                                          saveAmount ?? '0') ??
                                                      0,
                                                  dayCount: dayCount,
                                                  categoryId:
                                                      widget.category.id,
                                                  type: type,
                                                  unit: unit,
                                                  createdAt: DateTime.now());

                                              ref
                                                  .read(taskProvider.notifier)
                                                  .updateTask(task);

                                              Navigator.of(context).pop();
                                            }
                                          }));
                                }),
                            Row(children: [
                              Flexible(
                                  child: TextFormField(
                                      initialValue:
                                          widget.task.amount.toString(),
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: options[0],
                                      ),
                                      keyboardType: TextInputType.number,
                                      onSaved: (String? value) {
                                        saveAmount = value;
                                      })),
                              const SizedBox(width: 15),
                              Flexible(
                                  child: PopupMenuButton<Unit>(
                                child: TextFormField(
                                  controller: selectedUnitController,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    border: const OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    labelText: options[1],
                                  ),
                                  enabled: false,
                                ),
                                onSelected: (Unit item) {
                                  selectedUnitController.text = item.name;
                                },
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      value: Unit.g,
                                      child: Text(Unit.g.name),
                                    ),
                                    PopupMenuItem(
                                      value: Unit.mg,
                                      child: Text(Unit.mg.name),
                                    ),
                                    PopupMenuItem(
                                      value: Unit.cm,
                                      child: Text(Unit.cm.name),
                                    ),
                                    PopupMenuItem(
                                      value: Unit.minute,
                                      child: Text(Unit.minute.name),
                                    ),
                                  ];
                                },
                              )),
                            ]),
                            const SizedBox(height: 20),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Row(children: [
                                Flexible(
                                    child: SizedBox(
                                        width: 142,
                                        child: PopupMenuButton<DayCount>(
                                          child: TextFormField(
                                            controller:
                                                selectedDayCountController,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                              labelText: options[3],
                                            ),
                                            enabled: false,
                                          ),
                                          onSelected: (DayCount item) {
                                            setState(
                                              () => selectedDayCountController
                                                  .text = item.name,
                                            );
                                          },
                                          itemBuilder: (context) {
                                            return [
                                              PopupMenuItem(
                                                value: DayCount.once,
                                                child: Text(DayCount.once.name),
                                              ),
                                              PopupMenuItem(
                                                value: DayCount.multiple,
                                                child: Text(
                                                    DayCount.multiple.name),
                                              ),
                                            ];
                                          },
                                        ))),
                                const SizedBox(width: 14),
                                Flexible(
                                    child:
                                        selectedDayCountController.text == '1回'
                                            ? const Text('折れ線グラフが使われます')
                                            : const Text('積み上げ棒グラフが使われます'))
                              ]),
                              const SizedBox(height: 20),
                              Row(children: [
                                Flexible(
                                    child: SizedBox(
                                        width: 142,
                                        child: PopupMenuButton<Type>(
                                          child: TextFormField(
                                            controller: selectedTypeController,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                              labelText: options[2],
                                            ),
                                            enabled: false,
                                          ),
                                          onSelected: (Type item) {
                                            setState(() =>
                                                selectedTypeController.text =
                                                    item.name);
                                          },
                                          itemBuilder: (context) {
                                            return [
                                              PopupMenuItem(
                                                value: Type.direct,
                                                child: Text(Type.direct.name),
                                              ),
                                              PopupMenuItem(
                                                value: Type.time,
                                                child: Text(Type.time.name),
                                              ),
                                            ];
                                          },
                                        ))),
                                const SizedBox(width: 14),
                                Flexible(
                                    child: selectedTypeController.text == '直接'
                                        ? const Text('キーボードで直接入力します')
                                        : const Text('時間を選択して入力します'))
                              ])
                            ]),
                            const SizedBox(height: 30),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const SizedBox(width: 10),
                                  FilledButton(
                                      onPressed: () {
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
                                                        const Text('削除しますか？'),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  ref
                                                                      .read(taskProvider
                                                                          .notifier)
                                                                      .removeTask(
                                                                          widget
                                                                              .task);

                                                                  final target =
                                                                      [
                                                                    ...widget
                                                                        .pet
                                                                        .taskIds
                                                                  ];

                                                                  target.remove(
                                                                      widget
                                                                          .task
                                                                          .id);

                                                                  ref
                                                                      .read(petProvider
                                                                          .notifier)
                                                                      .updatePet(widget
                                                                          .pet
                                                                          .copyWith(
                                                                              taskIds: target));

                                                                  Navigator.of(
                                                                      context)
                                                                    ..pop()
                                                                    ..pop();
                                                                },
                                                                child: const Text(
                                                                    '削除する',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator
                                                                        .pop(
                                                                  context,
                                                                ),
                                                                child:
                                                                    const Text(
                                                                        "キャンセル"),
                                                              )
                                                            ])
                                                      ]));
                                            });
                                      },
                                      child: const Icon(Icons.delete)),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: () {
                                      form.currentState!.validate()
                                          ? form.currentState?.save()
                                          : null;
                                    },
                                    child: const Icon(Icons.check),
                                  ),
                                  const SizedBox(width: 10),
                                ]),
                            const SizedBox(height: 40)
                          ]))))
            ]))));
  }
}
