import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import "package:intl/intl.dart";
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../setting/application/app_setting_provider.dart';
import '../../setting/application/tutorial_controller.dart';

import '../model/pet.dart';
import '../application/pet_provider.dart';

final pickedImageProvider = StateProvider.autoDispose<File?>((ref) => null);

final isReachedProvider = StateProvider.autoDispose((ref) => false);

class PetCreate extends ConsumerStatefulWidget {
  const PetCreate({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PetCreateState();
}

class PetCreateState extends ConsumerState<PetCreate> {
  int _steppIndex = 0;
  final form = GlobalKey<FormState>();
  TextEditingController? dateOfBirthController = TextEditingController();
  TextEditingController? ageController = TextEditingController();
  String name = '';
  DateTime? dateOfBirth;
  int? age;
  String? message;
  String? sex;
  String? breed;
  int? weight;
  int? stature;
  int? bodyLength;
  int? chest;
  int? neck;
  int? height;
  int? frontLeftShoe;
  int? frontRightShoe;
  int? hindLeftShoe;
  int? hindRightShoe;

  GlobalKey? petTutorial;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tutorialControllerNotifier =
        ref.read(tutorialControllerProvider.notifier);

    petTutorial = GlobalKey();

    Future.delayed(
        const Duration(milliseconds: 1200),
        () => tutorialControllerNotifier.tutorial(
            petTutorial, 'petTutorial', 'gridTutorial', context, null));
  }

  @override
  dispose() {
    dateOfBirthController?.dispose();
    ageController?.dispose();
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

      ref.read(pickedImageProvider.notifier).state = File(compressedFile!.path);

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
          if (ref.read(settingProvider.notifier).isTutorial) {
            return Future.value(false);
          }
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
                      if (form.currentState!.validate()) {
                        form.currentState!.save();

                        final pickedImage = ref.read(pickedImageProvider);
                        final now = DateTime.now();
                        final pet = Pet(
                            id: ref.read(petProvider.notifier).assignId(),
                            name: name,
                            dateOfBirth: dateOfBirth,
                            age: age,
                            message: message,
                            sex: sex,
                            breed: breed,
                            weight: weight,
                            stature: stature,
                            headerImagePath: pickedImage?.path,
                            bodyLength: bodyLength,
                            chest: chest,
                            neck: neck,
                            height: height,
                            frontLeftShoe: frontLeftShoe,
                            frontRightShoe: frontRightShoe,
                            hindLeftShoe: hindLeftShoe,
                            hindRightShoe: hindRightShoe,
                            createdAt: now,
                            updatedAt: now);

                        ref.read(petProvider.notifier).savePet(pet);

                        if (ref.read(settingProvider.notifier).isTutorial) {
                          final pet = ref.read(petProvider).first!;
                          final updatePet = pet.copyWith(categoryIds: [
                            1,
                          ], taskIds: [
                            1
                          ]);

                          ref.read(petProvider.notifier).updatePet(updatePet);

                          // Navigator.of(context).pushAndRemoveUntil(
                          //     MaterialPageRoute(
                          //         builder: (context) => const Layout()),
                          //     (_) => false);

                          Navigator.of(context)
                            ..pop()
                            ..pop()
                            ..pop();
                        } else {
                          Navigator.of(context).pop();
                        }
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
            body: Form(
                key: form,
                // color: Colors.blue.withOpacity(.1),
                child: Stepper(
                  onStepContinue: () {
                    if (_steppIndex < 5) {
                      setState(() => _steppIndex += 1);
                    }
                    if (_steppIndex == 5) {
                      ref
                          .read(isReachedProvider.notifier)
                          .update((state) => true);
                    }
                  },
                  onStepCancel: () {
                    if (3 < _steppIndex) {
                      setState(() => _steppIndex -= 1);
                    }
                  },
                  onStepTapped: (int index) {
                    setState(() => _steppIndex = index);
                    if (_steppIndex == 5) {
                      ref
                          .read(isReachedProvider.notifier)
                          .update((state) => true);
                    }
                  },
                  currentStep: _steppIndex,
                  controlsBuilder: (context, details) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (details.currentStep == 0)
                            // Padding(
                            //     padding: const EdgeInsets.only(top: 15, left: 15),
                            //     child: FilledButton(
                            //       onPressed: details.onStepContinue,
                            //       child: const Text('今はしない'),
                            //     )),
                            if (details.currentStep == 0) const Spacer(),
                          if (details.currentStep != 5)
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, right: 15),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.photo_camera),
                                    onPressed: () =>
                                        pickMedia(ImageSource.camera),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.photo_outlined),
                                    onPressed: () =>
                                        pickMedia(ImageSource.gallery),
                                  ),
                                  if (ref.watch(pickedImageProvider) != null)
                                    TextButton(
                                      child: const Text('調整'),
                                      onPressed: () => cropImage(),
                                    ),
                                ]),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue.shade100)),
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
                                          child:
                                              Center(child: Text("画像が未登録です")),
                                        ),
                                    };
                                  },
                                ))
                          ]),
                        )),
                    Step(
                      isActive: _steppIndex == 1 ? true : false,
                      title: Text.rich(
                          key: petTutorial,
                          const TextSpan(children: [
                            TextSpan(text: '名前 ・ 生年月日'),
                            TextSpan(
                                text: '  ※必須',
                                style: TextStyle(color: Colors.red))
                          ])),
                      content: Column(children: [
                        const SizedBox(height: 5),
                        TextFormField(
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
                          onSaved: (value) {
                            name = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Flexible(
                              flex: 2,
                              child: FocusScope(
                                  canRequestFocus: false,
                                  child: TextFormField(
                                    controller: dateOfBirthController,
                                    onTap: () async {
                                      final now = DateTime.now();
                                      final DateTime? selectedDateOfBirth =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: now,
                                        firstDate: now.copyWith(year: 2000),
                                        lastDate: now,
                                        builder: (context, child) {
                                          return child!;
                                        },
                                      );
                                      if (selectedDateOfBirth != null) {
                                        setState(
                                          () {
                                            dateOfBirthController?.text =
                                                DateFormat.yMMMd('ja').format(
                                                    selectedDateOfBirth);

                                            dateOfBirth = selectedDateOfBirth;

                                            ageController?.text = calculateAge(
                                                    selectedDateOfBirth)
                                                .toString();

                                            age = calculateAge(
                                                selectedDateOfBirth);
                                          },
                                        );
                                      }
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '生年月日',
                                    ),
                                  ))),
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
                      ]),
                    ),
                    Step(
                      isActive: _steppIndex == 2 ? true : false,
                      title: const Text('性別 ・ 種類'),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                        ]),
                        const SizedBox(
                          height: 15,
                        ),
                        Flexible(
                            child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '種類',
                          ),
                          // keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onSaved: (value) {
                            breed = value;
                          },
                        ))
                      ]),
                    ),
                    Step(
                      isActive: _steppIndex == 3 ? true : false,
                      title: const Text('メッセージ'),
                      content: Column(children: [
                        const SizedBox(height: 3),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'メッセージ',
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onSaved: (value) {
                            message = value;
                          },
                        )
                      ]),
                    ),
                    Step(
                      isActive: _steppIndex == 4 ? true : false,
                      title: const Text('体重 ・ 体高 ・ 体長'),
                      content: Column(children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '体重',
                            ),
                            onSaved: (value) {
                              weight = int.tryParse(value!);
                            },
                          )),
                          const SizedBox(
                            width: 161,
                          ),
                        ]),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                          const Flexible(child: Text('地面から背中までの高さ'))
                        ]),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                          const Flexible(child: Text('胸から尾の付け根までの長さ'))
                        ]),
                        const SizedBox(
                          height: 25,
                        ),
                      ]),
                    ),
                    Step(
                      isActive: _steppIndex == 5 ? true : false,
                      title: const Text('服のサイズ'),
                      content: Column(children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                          const Flexible(child: Text('胸の一番太い部分を一周した長さ'))
                        ]),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                          height: 25,
                        ),
                        Row(children: [
                          Flexible(
                              child: TextFormField(
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
                          const Flexible(child: Text('首から尾の付け根までの長さ'))
                        ]),
                        const SizedBox(
                          height: 25,
                        ),
                        const Center(
                          child: Text('足のサイズ'),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(children: [
                          Row(children: [
                            Flexible(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '左前足',
                              ),
                              onSaved: (value) {
                                frontLeftShoe = int.tryParse(value!);
                              },
                            )),
                            const SizedBox(width: 20),
                            Flexible(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '右前足',
                              ),
                              onSaved: (value) {
                                frontRightShoe = int.tryParse(value!);
                              },
                            )),
                          ]),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(children: [
                            Flexible(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '左後ろ足',
                              ),
                              onSaved: (value) {
                                frontLeftShoe = int.tryParse(value!);
                              },
                            )),
                            const SizedBox(width: 20),
                            Flexible(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '右後ろ足',
                              ),
                              onSaved: (value) {
                                hindRightShoe = int.tryParse(value!);
                              },
                            )),
                          ])
                        ]),
                        const SizedBox(
                          height: 100,
                        ),
                      ]),
                    ),
                  ],
                ))));
  }
}
