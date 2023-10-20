import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../setting/application/tutorial_controller.dart';
import '../../../setting/application/app_setting_provider.dart';

import '../../../pet/model/pet.dart';
import '../../model/task.dart';

final pickedMemoImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final memoFormFieldProvider =
    Provider.autoDispose((ref) => GlobalKey<FormFieldState>());

class MemoInput extends ConsumerStatefulWidget {
  const MemoInput(this.pet, this.task, {super.key});
  final Pet pet;
  final Task? task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MemoInputState();
}

class MemoInputState extends ConsumerState<MemoInput>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey memoInputTutorial = GlobalKey();

  @override
  initState() {
    super.initState();
    if (ref.read(settingProvider.notifier).isTutorial) {
      final tutorialControllerNotifier =
          ref.read(tutorialControllerProvider.notifier);

      Future.delayed(
          const Duration(milliseconds: 800),
          () => tutorialControllerNotifier.tutorial(memoInputTutorial,
              'memoInputTutorial', 'costInputTutorial', context));
    }
  }

  @override
  Widget build(context) {
    super.build(context);

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

      ref.read(pickedMemoImageProvider.notifier).state =
          File(compressedFile!.path);

      File(pickedImage.path).deleteSync();
    }

    return WillPopScope(
        onWillPop: () async {
          if (ref.read(settingProvider.notifier).isTutorial) {
            return Future.value(false);
          }
          return true;
        },
        child: SizedBox(
            key: memoInputTutorial,
            width: 365,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Consumer(builder: (context, ref, _) {
                  final pickedImage = ref.watch(pickedMemoImageProvider);
                  return Container(
                      padding: const EdgeInsets.only(left: 5),
                      height: 105,
                      width: 200,
                      child: switch (pickedImage) {
                        File() => ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.file(pickedImage, fit: BoxFit.cover)),
                        _ => Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black12.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Center(child: Text("")),
                          ),
                      });
                }),
                SizedBox(
                  height: 100,
                  child: Column(children: [
                    const Spacer(),
                    IconButton(
                        onPressed: () => pickMedia(ImageSource.camera),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.camera, size: 18)),
                    const Spacer(),
                    IconButton(
                        onPressed: () => pickMedia(ImageSource.gallery),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.photo_outlined, size: 18)),
                    const Spacer()
                  ]),
                ),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 160,
                child: TextFormField(
                  onTapOutside: (_) {
                    final FocusScopeNode currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus &&
                        currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    }
                  },
                  key: memoFormField,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 6,
                  decoration: const InputDecoration(hintText: 'メモ'),
                  validator: (String? value) {
                    return value!.isEmpty ? '入力がありません' : null;
                  },
                ),
              )
            ])));
  }
}
