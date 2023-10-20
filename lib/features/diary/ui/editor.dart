import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:light_compressor/light_compressor.dart';

import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';

import '../model/diary.dart';
import '../application/diary_provider.dart';

import '../../album/application/album_provider.dart';
import '../../album/model/media.dart';

import '../../folder/model/folder.dart';
import '../../folder/application/pet_folder_provider.dart';

import 'package:uuid/uuid.dart';
import 'package:gal/gal.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:collection/collection.dart';

final pickedPathProvider = StateProvider.autoDispose((ref) => []);

final quillControllerProvider =
    StateProvider.autoDispose((ref) => QuillController.basic());

final focusProvider = StateProvider.autoDispose((ref) => FocusNode());

final scrollController = StateProvider.autoDispose((ref) => ScrollController());

class Editor extends ConsumerWidget {
  const Editor(this.diary, this.folderId, {super.key});
  final Diary? diary;
  final int? folderId;

  String uniqueFileName(extention) =>
      path.join(const Uuid().v4() + '.' + extention);

  @override
  Widget build(context, ref) {
    final quillController = ref.watch(quillControllerProvider);
    final pickedPaths = ref.watch(pickedPathProvider);

    final petFolder = ref.watch(petFolderProvider);
    final drawer = ['未分類', ...petFolder];

    Future<void> insertNewLine() async {
      final controller = ref.read(quillControllerProvider);

      controller.document.insert(controller.document.length - 1, "\n\n\n");

      // var currentCusorPosition = controller.selection.base.offset;

      // controller.moveCursorToPosition(currentCusorPosition + 2);
    }

    /*
    note: クイル画像削除 (動画は試してない)
    非表示にするか削除するか選べる
    非表示の概念をゴミ箱にできる⇒期日自動削除必要だが
     */
    void deleteImageFromDiaryByPath(String imagePath) {
      if (imagePath.isEmpty) return;

      final diaries = ref.read(petDiaryProvider);

      for (final (i, diary) in diaries.indexed) {
        final contents = jsonDecode(diary.content!);

        int? diaryindex;
        int? imageindex;
        for (final (j, content) in (contents as List).indexed) {
          if (content["insert"] case {"image": final path}
              when path == imagePath) {
            diaryindex = i;
            imageindex = j;
          }
        }

        if (diaryindex != null && imageindex != null) {
          contents.removeAt(imageindex);
          final newDiary =
              diaries[diaryindex].copyWith(content: jsonEncode(contents));

          final media = ref
              .read(albumProvider)
              .firstWhereOrNull((media) => media.path == imagePath);
          if (File(imagePath).existsSync() && media != null) {
            ref.read(petDiaryProvider.notifier).updateDiary(newDiary);
            File(imagePath).deleteSync();
            ref.read(albumProvider.notifier).removeAlbum(media);
          }
        }
      }
    }

    Future<String> onImagePickCallback(File file) async {
      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          path.join(
              '/data/user/0/com.miya.pet_you/cache', uniqueFileName('jpg')),
          quality: 80);

      const album = 'PetYou';

      await Gal.putImage(compressedFile!.path, album: album);

      insertNewLine().then((_) {
        ref
            .read(scrollController)
            .animateTo(ref.read(scrollController).position.maxScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut)
            .then((_) => ref.read(focusProvider).unfocus());
      });

      final imagePath = path.join('/storage/emulated/0/Pictures', album,
          path.basename(compressedFile.path));

      Directory('/data/user/0/com.miya.pet_you/cache')
          .deleteSync(recursive: true);

      ref.read(pickedPathProvider.notifier).state.add(imagePath);

      return imagePath;
    }

    void syncEditorAndAppDirImagePaths(editorImagePaths) {
      pickedPaths
          .removeWhere((pickedPath) => editorImagePaths.contains(pickedPath));

      if (pickedPaths.isNotEmpty) {
        for (final pickedPath in pickedPaths) {
          if (File(pickedPath).existsSync()) {
            File(pickedPath).deleteSync();
          }
        }
      }
    }

    Future<MediaPickSetting?> selectCameraPickSetting(context) =>
        showDialog<MediaPickSetting>(
          context: context,
          builder: (ctx) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('カメラ'),
                  onPressed: () => Navigator.pop(ctx, MediaPickSetting.Camera),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.video_camera_back),
                  label: const Text('動画  '),
                  onPressed: () => Navigator.pop(ctx, MediaPickSetting.Video),
                )
              ],
            ),
          ),
        );

    Future<Result> compressVideo(path, name) async {
      final LightCompressor lightCompressor = LightCompressor();
      final Result response = await lightCompressor.compressVideo(
        path: path,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        video: Video(videoName: name),
        android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: true),
      );

      return response;
    }

    Future<String?> videoThumbnailPath(videoPath) async {
      final path = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getApplicationDocumentsDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        quality: 80,
      );

      return path;
    }

    Future<String> onVideoPickCallback(File file) async {
      const album = 'PetYou';

      await Gal.putVideo(file.path, album: album);

      final imagePath = path.join(
          '/storage/emulated/0/Pictures', album, path.basename(file.path));

      final response = await compressVideo(
          imagePath, path.basenameWithoutExtension(imagePath));

      File(imagePath).deleteSync();

      if (response is OnSuccess) {
        await Gal.putVideo(response.destinationPath, album: album);
      }

      Directory('/data/user/0/com.miya.pet_you/cache')
          .deleteSync(recursive: true);
      Directory('/data/user/0/com.miya.pet_you/files')
          .deleteSync(recursive: true);

      // ref.read(pickedPathProvider.notifier).state.add(imagePath);

      return imagePath;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quillControllerProvider.notifier).state.document =
          switch (diary) {
        Diary(:final content!) => Document.fromJson(jsonDecode(content)),
        _ => Document()
      };

      ref.read(pickedPathProvider.notifier).state.addAll(switch (diary) {
            Diary(:final content!) => <String>[
                for (final ct in jsonDecode(content))
                  if (ct case {'insert': {'image': final image}}) image
              ],
            _ => []
          });

      ref.read(focusProvider).unfocus();
    });

    Future<MediaPickSetting?> selectMediaPickSetting(BuildContext context) =>
        showDialog<MediaPickSetting>(
          context: context,
          builder: (ctx) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*
                MediaPickSetting の Camera と Video はタップしても Link になるので機能していない
                よって画像選択は Gallery のみ
                また動画ボタンの選択時にもコレが使われるので機能しなくなる
                また cameraPickSetting と一緒に使用するとカメラ起動時に落ちることになる
                なのでデフォルトのセレクタを使った方がよい

                 */
                TextButton.icon(
                  icon: const Icon(Icons.collections),
                  // 選択時の名称を変更できるが上記のため使用しない
                  // ただし onPressed で好きな関数割り当て可能？なのでカスタマイズしてもいいかも
                  label: const Text('ギャラリー'),
                  onPressed: () => Navigator.pop(ctx, MediaPickSetting.Gallery),
                ),
              ],
            ),
          ),
        );

    return Scaffold(
        endDrawer: Drawer(
            width: 230,
            child: Scaffold(
                appBar: AppBar(),
                body: ListView.builder(
                    itemCount: drawer.length,
                    itemBuilder: (context, index) {
                      return switch (drawer[index]) {
                        Folder(:final name, :final id) => ListTile(
                            onTap: () {
                              ref
                                  .read(petDiaryProvider.notifier)
                                  .updateDiary(diary!.copyWith(folderId: id));

                              Navigator.of(context)
                                ..pop()
                                ..pop();
                            },
                            title: Text(name),
                            trailing: diary?.folderId == id
                                ? const Icon(Icons.check)
                                : null),
                        _ => ListTile(
                            onTap: () {
                              ref
                                  .read(petDiaryProvider.notifier)
                                  .updateDiary(diary!.copyWith(folderId: null));

                              Navigator.of(context)
                                ..pop()
                                ..pop();
                            },
                            title: const Text('未分類'),
                            trailing: diary?.folderId == null
                                ? const Icon(Icons.check)
                                : null)
                      };
                    }))),
        appBar: AppBar(actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (diary != null) {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                          height: 130,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text('削除しますか？'),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(petDiaryProvider.notifier)
                                              .removeDiary(diary!);
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
              }
            },
          ),
          const SizedBox(width: 5),
          if (diary != null)
            Builder(builder: (context) {
              return TextButton.icon(
                label: const Text('移動'),
                icon: const Icon(Icons.drive_folder_upload),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }),
        ]),
        body: SizedBox(
            // color: Colors.blue.withOpacity(.5),
            child: Column(children: [
          const SizedBox(height: 20),
          QuillToolbar.basic(
              controller: quillController,
              toolbarIconAlignment: WrapAlignment.start,
              locale: const Locale('jp'),
              toolbarSectionSpacing: 24,
              multiRowsDisplay: true,
              showSearchButton: true,
              showUndo: true,
              showRedo: true,
              showDividers: false,
              showFontFamily: false,
              showFontSize: false,
              showItalicButton: false,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showClearFormat: false,
              showHeaderStyle: false,
              showListNumbers: false,
              showListBullets: false,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showSubscript: false,
              showSuperscript: false,
              embedButtons: FlutterQuillEmbeds.buttons(
                // 画像だけでなく動画ボタンにも変更した名称などの影響が出るので使えない
                // mediaPickSettingSelector: selectMediaPickSetting,
                onImagePickCallback: onImagePickCallback,
                //  mediaPickSettingSelector と一緒に使用すると debug が落ちる(lost ⇒ ネットでは ios でカメラパーミッションとかで同じエラー)と思っていたが flutter upgrade したからかもしれない (しかしそれでも使用しない)
                cameraPickSettingSelector: selectCameraPickSetting,
                onVideoPickCallback: onVideoPickCallback,
              )),
          const SizedBox(height: 14),
          Expanded(
              child: QuillEditor(
            controller: quillController,
            scrollController: ref.watch(scrollController),
            scrollable: true,
            readOnly: false,
            focusNode: ref.watch(focusProvider),
            autoFocus: false,
            padding: const EdgeInsets.fromLTRB(22, 55, 22, 10),
            expands: true,
            placeholder: "本文",
            embedBuilders: FlutterQuillEmbeds.builders(),
          ))
        ])),
        floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              final jsonDocuments = quillController.document.toDelta().toJson();

              final now = DateTime.now();

              final texts = <String>[
                for (final jsonDocument in jsonDocuments)
                  if (jsonDecode(jsonEncode(jsonDocument))
                      case {'insert': final String text}
                      when text.trim().isNotEmpty)
                    text.trim()
              ];

              final imagePaths = <String>[
                for (final jsonDocument in jsonDocuments)
                  if (jsonDecode(jsonEncode(jsonDocument))
                      case {'insert': {'image': final String path}})
                    path
              ];

              final videoPaths = <String>[
                for (final jsonDocument in jsonDocuments)
                  if (jsonDecode(jsonEncode(jsonDocument))
                      case {'insert': {'video': final String path}})
                    path
              ];

              syncEditorAndAppDirImagePaths(imagePaths);

              final videoExistsButImageNotExists =
                  videoPaths.isNotEmpty && imagePaths.isEmpty;

              Diary newDiary = Diary(
                  id: ref.read(petDiaryProvider.notifier).assignId(),
                  title: diary?.title ?? texts.firstOrNull,
                  content: jsonEncode(jsonDocuments),
                  searchContent: texts.firstOrNull,
                  headerImagePath: videoExistsButImageNotExists
                      ? await videoThumbnailPath(videoPaths.first)
                      : imagePaths.firstOrNull,
                  folderId: folderId,
                  createdAt: diary?.createdAt ?? now,
                  updatedAt: now);

              if (diary != null) {
                ref.read(petDiaryProvider.notifier).updateDiary(diary!.copyWith(
                    title: texts.firstOrNull,
                    content: jsonEncode(jsonDocuments),
                    searchContent: texts.firstOrNull,
                    headerImagePath: videoExistsButImageNotExists
                        ? videoPaths.firstOrNull
                        : imagePaths.firstOrNull,
                    folderId: folderId,
                    updatedAt: now));

                for (final imagePath in imagePaths) {
                  final media = ref
                      .read(albumProvider.notifier)
                      .findMediaByPath(imagePath);

                  if (media == null) {
                    ref.read(albumProvider.notifier).saveAlbum(Media(
                        id: ref.read(albumProvider.notifier).assignId(),
                        path: imagePath,
                        type: 'image',
                        createdAt: now,
                        updatedAt: now));
                  } else {
                    ref.read(albumProvider.notifier).updateAlbum(media.copyWith(
                        path: imagePath, type: 'image', updatedAt: now));
                  }
                }
                for (final videoPath in videoPaths) {
                  final media = ref
                      .read(albumProvider.notifier)
                      .findMediaByPath(videoPath);

                  if (media == null) {
                    ref.read(albumProvider.notifier).saveAlbum(Media(
                        id: ref.read(albumProvider.notifier).assignId(),
                        path: videoPath,
                        type: 'video',
                        createdAt: now,
                        updatedAt: now));
                  } else {
                    ref.read(albumProvider.notifier).updateAlbum(media.copyWith(
                        path: videoPath, type: 'video', updatedAt: now));
                  }
                }
              } else {
                ref.read(petDiaryProvider.notifier).saveDiary(newDiary);
                for (final imagePath in imagePaths) {
                  ref.read(albumProvider.notifier).saveAlbum(Media(
                      id: ref.read(albumProvider.notifier).assignId(),
                      path: imagePath,
                      type: 'image',
                      createdAt: now,
                      updatedAt: now));
                }
                for (final videoPath in videoPaths) {
                  ref.read(albumProvider.notifier).saveAlbum(Media(
                      id: ref.read(albumProvider.notifier).assignId(),
                      path: videoPath,
                      type: 'video',
                      createdAt: now,
                      updatedAt: now));
                }
              }

              ref.invalidate(petFolderProvider);

              Navigator.of(context).pop();
            },
            child: const Icon(Icons.done)));
  }
}
