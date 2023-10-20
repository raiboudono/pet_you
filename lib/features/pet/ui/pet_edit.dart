import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import "package:intl/intl.dart";
import 'package:image_cropper/image_cropper.dart';

import '../../../layout/home.dart';

import '../model/pet.dart';

import '../application/pet_provider.dart';

final pickedImageProvider = StateProvider.autoDispose<File?>((ref) => null);

class PetEdit extends ConsumerStatefulWidget {
  const PetEdit(this.pet, {super.key});
  final Pet pet;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PetEditState();
}

class PetEditState extends ConsumerState<PetEdit> {
  final form = GlobalKey<FormState>();
  TextEditingController? dateOfBirthController;
  TextEditingController? ageController;
  String name = '';
  DateTime? dateOfBirth;
  int? age;
  String? message;
  String? sex;
  String? breed;
  int? weight;
  int? stature;
  // 服
  int? bodyLength;
  int? chest;
  int? neck;
  int? height;
  int? frontLeftShoe;
  int? frontRightShoe;
  int? hindLeftShoe;
  int? hindRightShoe;

  @override
  initState() {
    if (widget.pet.dateOfBirth != null) {
      dateOfBirthController = TextEditingController(
          text: DateFormat.yMMMd('ja').format(widget.pet.dateOfBirth!));
    } else {
      dateOfBirthController = TextEditingController();
    }

    ageController = TextEditingController(text: widget.pet.age?.toString());
    super.initState();
  }

  @override
  dispose() {
    dateOfBirthController?.dispose();
    ageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
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
    }

    Future<void> cropImage() async {
      final pickedImage = ref.read(pickedImageProvider);

      final localpath = (await getApplicationDocumentsDirectory()).path;

      final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage?.path ?? widget.pet.headerImagePath!,
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

      final copiedFile = File(croppedImage.path)
          .copySync('$localpath/${path.basename(croppedImage.path)}');

      if (pickedImage != null) {
        pickedImage.deleteSync();
      }
      File(croppedImage.path).deleteSync();

      ref.read(pickedImageProvider.notifier).update((state) => copiedFile);
    }

    int calculateAge(DateTime dateOfBirth) {
      final now = DateTime.now();
      int age = now.year - dateOfBirth.year;

      if (now.month < dateOfBirth.month ||
          now.month == dateOfBirth.month && now.day < dateOfBirth.day) {
        age--;
      }

      return age;
    }

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
                      height: 230,
                      width: double.infinity,
                      child: switch (
                          pickedImage?.path ?? widget.pet.headerImagePath) {
                        String path when File(path).existsSync() => Hero(
                            tag: 'image_${widget.pet.name}',
                            child: Image.file(File(path), fit: BoxFit.cover)),
                        _ => const SizedBox(
                            height: 230,
                            child: Center(child: Text("画像が未登録です")),
                          ),
                      });
                },
              ),
              SizedBox(
                height: 80,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                      onPressed: () => getMedia(ImageSource.gallery),
                      icon: const Icon(Icons.photo_camera)),
                  const SizedBox(width: 20),
                  IconButton(
                      onPressed: () => getMedia(ImageSource.gallery),
                      icon: const Icon(Icons.photo_outlined)),
                  if (ref.watch(pickedImageProvider) != null ||
                      widget.pet.headerImagePath != null)
                    const SizedBox(width: 20),
                  if (ref.watch(pickedImageProvider) != null ||
                      widget.pet.headerImagePath != null)
                    TextButton(
                      child: const Text('調整'),
                      onPressed: () => cropImage(),
                    ),
                  const SizedBox(width: 20)
                ]),
              ),
              SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: IntrinsicHeight(
                      child: Form(
                          key: form,
                          onWillPop: () {
                            return Future.value(true);
                          },
                          child: Consumer(
                            builder: (context, ref, _) {
                              return Column(children: [
                                TextFormField(
                                  initialValue: widget.pet.name,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text.rich(
                                      TextSpan(
                                        text: '名前',
                                        children: [
                                          TextSpan(
                                              text: ' ※',
                                              style:
                                                  TextStyle(color: Colors.red))
                                        ],
                                      ),
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return '入力がありません';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    name = value!;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Flexible(
                                      flex: 2,
                                      child: FocusScope(
                                        canRequestFocus: false,
                                        child: TextFormField(
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final DateTime?
                                                selecteddateOfBirth =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: now,
                                              firstDate:
                                                  now.copyWith(year: 2000),
                                              lastDate: now,
                                              builder: (context, child) {
                                                return child!;
                                              },
                                            );
                                            if (selecteddateOfBirth != null) {
                                              setState(
                                                () {
                                                  dateOfBirthController
                                                      ?.text = DateFormat.yMMMd(
                                                          'ja')
                                                      .format(
                                                          selecteddateOfBirth);

                                                  dateOfBirth =
                                                      selecteddateOfBirth;

                                                  ageController
                                                      ?.text = calculateAge(
                                                          selecteddateOfBirth)
                                                      .toString();

                                                  age = calculateAge(
                                                      selecteddateOfBirth);
                                                },
                                              );
                                            }
                                          },
                                          controller: dateOfBirthController,
                                          readOnly: true,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '生年月日',
                                          ),
                                        ),
                                      )),
                                  const SizedBox(width: 20),
                                  Flexible(
                                      child: TextFormField(
                                    controller: ageController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '年齢',
                                    ),
                                    onSaved: (value) {
                                      age = int.tryParse(value!);
                                    },
                                  )),
                                ]),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Flexible(
                                      child: TextFormField(
                                    initialValue: widget.pet.sex,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '性別',
                                    ),
                                    // keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    onSaved: (value) {
                                      sex = value;
                                    },
                                  )),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Flexible(
                                      child: TextFormField(
                                    initialValue: widget.pet.breed,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '種類',
                                    ),
                                    // keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    onSaved: (value) {
                                      breed = value;
                                    },
                                  )),
                                ]),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  initialValue: widget.pet.message,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'メッセージ',
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  onSaved: (value) {
                                    message = value;
                                  },
                                ),
                                SizedBox(
                                    // height: 130,
                                    child: ExpansionTile(
                                        shape: const Border(),
                                        title: const Text('体重、体高、体長'),
                                        children: [
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.weight?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '体重',
                                          ),
                                          onSaved: (value) {
                                            weight = int.tryParse(value!);
                                          },
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.stature?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '体高',
                                          ),
                                          onSaved: (value) {
                                            stature = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        const Flexible(
                                            child: Text('地面から背中までの高さ'))
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.bodyLength?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '体長',
                                          ),
                                          onSaved: (value) {
                                            bodyLength = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        const Flexible(
                                            child: Text('胸から尾の付け根までの長さ')),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ])),
                                SizedBox(
                                    // height: 130,
                                    child: ExpansionTile(
                                        shape: const Border(),
                                        title: const Text('服のサイズ'),
                                        children: [
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.chest?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '胸囲',
                                          ),
                                          onSaved: (value) {
                                            chest = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        const Flexible(
                                            child: Text('胸の一番太い部分を一周した長さ'))
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.neck?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '首囲',
                                          ),
                                          onSaved: (value) {
                                            neck = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        const Flexible(child: Text('首を一周した長さ'))
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue:
                                              widget.pet.height?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '背丈',
                                          ),
                                          onSaved: (value) {
                                            height = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        const Flexible(
                                            child: Text('首から尾の付け根までの長さ'))
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ])),
                                ExpansionTile(
                                    shape: const Border(),
                                    title: const Text('足のサイズ'),
                                    children: [
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue: widget.pet.frontLeftShoe
                                              ?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '左前足',
                                          ),
                                          onSaved: (value) {
                                            frontLeftShoe =
                                                int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(width: 20),
                                        Flexible(
                                            child: TextFormField(
                                          initialValue: widget
                                              .pet.frontRightShoe
                                              ?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '右前足',
                                          ),
                                          onSaved: (value) {
                                            frontRightShoe =
                                                int.tryParse(value!);
                                          },
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                          initialValue: widget.pet.hindLeftShoe
                                              ?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '左後ろ脚',
                                          ),
                                          onSaved: (value) {
                                            hindLeftShoe = int.tryParse(value!);
                                          },
                                        )),
                                        const SizedBox(width: 20),
                                        Flexible(
                                            child: TextFormField(
                                          initialValue: widget.pet.hindRightShoe
                                              ?.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: '右後ろ足',
                                          ),
                                          onSaved: (value) {
                                            hindRightShoe =
                                                int.tryParse(value!);
                                          },
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ]),
                                const SizedBox(
                                  height: 25,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      FilledButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                    height: 100,
                                                    child: Center(
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                          FilledButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          '削除しますか？'),
                                                                      content:
                                                                          const SingleChildScrollView(
                                                                        child:
                                                                            ListBody(
                                                                          children: <Widget>[
                                                                            Text('この操作は取り消しできません'),
                                                                            Text(''),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child: const Text(
                                                                              '削除する',
                                                                              style: TextStyle(color: Colors.red)),
                                                                          onPressed:
                                                                              () {
                                                                            ref.read(petProvider.notifier).removePet(widget.pet.id);
                                                                            ref.invalidate(petIndexProvider);
                                                                            Navigator.of(context)
                                                                              ..pop()
                                                                              ..pop()
                                                                              ..pop();
                                                                          },
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                40),
                                                                        TextButton(
                                                                          child: const Text(
                                                                              'キャンセル',
                                                                              style: TextStyle()),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context)
                                                                              ..pop()
                                                                              ..pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(Colors
                                                                        .red
                                                                        .withOpacity(
                                                                            .2))),
                                                            child: const Icon(
                                                                color:
                                                                    Colors.red,
                                                                Icons.delete),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            style:
                                                                const ButtonStyle(),
                                                            child: const Text(
                                                                "キャンセル"),
                                                          )
                                                        ])));
                                              });
                                        },
                                        child: const Icon(Icons.delete),
                                      ),
                                      FilledButton.icon(
                                          onPressed: () {
                                            if (form.currentState!.validate()) {
                                              form.currentState?.save();

                                              final pickedImage =
                                                  ref.read(pickedImageProvider);

                                              if (pickedImage != null &&
                                                  widget.pet.headerImagePath !=
                                                      null) {
                                                if (File(widget
                                                        .pet.headerImagePath!)
                                                    .existsSync()) {
                                                  File(widget
                                                          .pet.headerImagePath!)
                                                      .deleteSync();

                                                  // widget.pet.headerImagePath =
                                                  //     null;
                                                }
                                              }

                                              final now = DateTime.now();
                                              final pet = widget.pet.copyWith(
                                                  name: name,
                                                  dateOfBirth: dateOfBirth ??
                                                      widget.pet.dateOfBirth,
                                                  age: age ?? widget.pet.age,
                                                  message: message ??
                                                      widget.pet.message,
                                                  sex: sex ?? widget.pet.sex,
                                                  breed:
                                                      breed ?? widget.pet.breed,
                                                  weight: weight ??
                                                      widget.pet.weight,
                                                  stature: stature ??
                                                      widget.pet.stature,
                                                  headerImagePath:
                                                      pickedImage?.path ??
                                                          widget.pet
                                                              .headerImagePath,
                                                  bodyLength: bodyLength ??
                                                      widget.pet.bodyLength,
                                                  chest:
                                                      chest ?? widget.pet.chest,
                                                  neck: neck ?? widget.pet.neck,
                                                  height: height ??
                                                      widget.pet.height,
                                                  frontLeftShoe: frontLeftShoe ??
                                                      widget.pet.frontLeftShoe,
                                                  frontRightShoe:
                                                      frontRightShoe ??
                                                          widget.pet
                                                              .frontRightShoe,
                                                  hindLeftShoe: hindLeftShoe ??
                                                      widget.pet.hindLeftShoe,
                                                  hindRightShoe: hindRightShoe ??
                                                      widget.pet.hindRightShoe,
                                                  createdAt: widget.pet.createdAt,
                                                  updatedAt: now);

                                              ref
                                                  .read(petProvider.notifier)
                                                  .updatePet(pet);

                                              Navigator.of(context).pop();
                                            }
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text("OK"))
                                    ]),
                                const SizedBox(
                                  height: 25,
                                ),
                              ]);
                            },
                          ))))
            ]))));
  }
}
