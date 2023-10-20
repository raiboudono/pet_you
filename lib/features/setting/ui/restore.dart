import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sign_in_button/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:collection/collection.dart';

import 'dart:io' as io;

import '../../album/application/album_provider.dart';

import '../application/app_setting_provider.dart';

import '../application/GoogleSignInService.dart';
import '../application/driveService.dart';

import '../../album/model/media.dart';

final processingProvider = StateProvider.autoDispose((ref) => false);

/*firebase auth 用 */
final userProvider = StateProvider<User?>((ref) => null);

class Restore extends ConsumerStatefulWidget {
  const Restore({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => RestoreState();
}

class RestoreState extends ConsumerState<Restore> {
  final restoreNames = ['写真', '動画', 'タスク'];
  final restoreCheckList = <bool>[false, false, false, false];
  late final List<Media?> images;
  late final List<Media?> videos;
  final task = io.File('/data/user/0/com.miya.pet_you/app_flutter/Pet.isar');
  late final List<double?> fileSizes;
  late final double totalSize;
  late final double backedupTotalSize;

  void cleanBackupCheckedList() {
    setState(() {
      for (final (i, _) in restoreCheckList.indexed) {
        restoreCheckList[i] = false;
      }
    });
  }

  double convertUnitToMega(byte) {
    return byte / 1024 / 1024;
  }

  @override
  initState() {
    super.initState();

    final medias = ref
        .read(albumProvider)
        .nonNulls
        .where((media) => io.File(media.path).existsSync());
    images = medias.where((e) => e.type == 'image').toList();
    videos = medias.where((e) => e.type == 'video').toList();

    double totalImagesSize = 0.0;
    if (images.isNotEmpty) {
      totalImagesSize =
          images.fold(0.0, (v1, v2) => v1 + io.File(v2!.path).lengthSync());
    }
    double totalVideosSize = 0.0;
    if (videos.isNotEmpty) {
      totalVideosSize =
          videos.fold(0.0, (v1, v2) => v1 + io.File(v2!.path).lengthSync());
    }

    fileSizes = <double>[
      convertUnitToMega(totalImagesSize),
      convertUnitToMega(totalVideosSize),
      convertUnitToMega(task.lengthSync())
    ];

    totalSize = fileSizes.fold(0.0, (v1, v2) => v1 + v2!);
  }

  @override
  Widget build(
    context,
  ) {
    final appSetting = ref.watch(settingProvider)!;
    final client = ref.watch(googleSignInServiceProvider);
    final notifier = ref.watch(googleSignInServiceProvider.notifier);
    final account = notifier.account;

    DriveService? driveService;
    Future<double>? backedupTotalSize;
    if (client != null) {
      driveService = ref.watch(driveServiceProvider(client));
      backedupTotalSize = driveService!.backedupTotalSize();
    }

    // showLocalAssets() async {
    //   final localPath = await getApplicationDocumentsDirectory();

    //   for (final io.FileSystemEntity v in localPath.listSync()) {
    //     print(v.path);
    //   }
    // }

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Container(
                // width: 50,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100,
                    borderRadius: BorderRadius.circular(5)),
                child: const Center(
                    child: Text('復元', style: TextStyle(fontSize: 16)))),
            actions: const [
              SizedBox(width: 48),
            ]),
        body: account == null
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // SizedBox(
                    //     height: 50,
                    //     child: SignInButton(
                    //       Buttons.email,
                    //       onPressed: () async => Navigator.of(context)
                    //           .push(MaterialPageRoute(builder: (context) {
                    //         return const EmailForm();
                    //       })),
                    //     )),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        height: 50,
                        child: SignInButton(
                          Buttons.google,
                          onPressed: () async => await notifier.signIn(),
                        ))
                  ]))
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  const SizedBox(height: 20),
                  const Center(
                      child: Text('アプリ < < < < < Googleドライブ',
                          style: TextStyle(fontSize: 16))),
                  CheckboxListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) {
                        for (int i = 0; i < restoreCheckList.length; i++) {
                          setState(() => restoreCheckList[i] = isChecked!);
                        }
                      },
                      value: restoreCheckList[0],
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(children: [
                              Icon(Icons.backup_outlined),
                              SizedBox(width: 7),
                              Text(
                                '全て',
                              ),
                            ]),
                            Text(
                              '   ${totalSize.toStringAsFixed(2)}MB',
                            ),
                            if (driveService != null)
                              FutureBuilder(
                                  future: backedupTotalSize,
                                  builder: (context, snapshot) {
                                    final data = snapshot.data;
                                    double buTotalSize = 0.0;
                                    if (data != null) {
                                      buTotalSize =
                                          convertUnitToMega(snapshot.data!);
                                    }

                                    return switch (snapshot) {
                                      AsyncSnapshot s when s.hasData =>
                                        Text(buTotalSize.toStringAsFixed(2) ==
                                                '0.00'
                                            ? '未完了'
                                            : '${buTotalSize.toStringAsFixed(2)}MB'),
                                      AsyncSnapshot s when s.hasError =>
                                        const Text('エラー'),
                                      _ => const CircularProgressIndicator(),
                                    };
                                  })
                          ])),
                  CheckboxListTile.adaptive(
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      if (!isChecked!) {
                        if (restoreCheckList[0]) {
                          setState(() {
                            restoreCheckList[0] = isChecked;
                            restoreCheckList[1] = isChecked;
                          });
                        } else {
                          setState(() => restoreCheckList[1] = isChecked);
                        }
                      } else {
                        setState(() => restoreCheckList[1] = isChecked);
                        if (restoreCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => restoreCheckList[0] = true);
                        }
                      }
                    },
                    value: restoreCheckList[1],
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.photo_size_select_actual_outlined),
                            SizedBox(width: 7),
                            Text(
                              '写真',
                            ),
                          ]),
                          Text(
                            '   ${fileSizes[0]!.toStringAsFixed(2)}MB',
                          ),
                          if (driveService != null)
                            FutureBuilder(
                                future: driveService
                                    .backedupFileSizeByExtension('jpg'),
                                builder: (context, snapshot) {
                                  final data = snapshot.data;
                                  double buTotalSize = 0.0;
                                  if (data != null) {
                                    buTotalSize =
                                        convertUnitToMega(snapshot.data!);
                                  }

                                  return switch (snapshot) {
                                    AsyncSnapshot s when s.hasData =>
                                      Text(buTotalSize.toStringAsFixed(2) ==
                                              '0.00'
                                          ? '未完了'
                                          : '${buTotalSize.toStringAsFixed(2)}MB'),
                                    AsyncSnapshot s when s.hasError =>
                                      const Text('エラー'),
                                    _ => const CircularProgressIndicator(),
                                  };
                                })
                        ]),
                  ),
                  CheckboxListTile.adaptive(
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      if (!isChecked!) {
                        if (restoreCheckList[0]) {
                          setState(() {
                            restoreCheckList[0] = isChecked;
                            restoreCheckList[2] = isChecked;
                          });
                        } else {
                          setState(() => restoreCheckList[2] = isChecked);
                        }
                      } else {
                        setState(() => restoreCheckList[2] = isChecked);
                        if (restoreCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => restoreCheckList[0] = true);
                        }
                      }
                    },
                    value: restoreCheckList[2],
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.video_camera_back_outlined),
                            SizedBox(width: 7),
                            Text(
                              '動画',
                            ),
                          ]),
                          Text(
                            '   ${fileSizes[1]!.toStringAsFixed(2)}MB',
                          ),
                          if (driveService != null)
                            FutureBuilder(
                                future: driveService
                                    .backedupFileSizeByExtension('mp4'),
                                builder: (context, snapshot) {
                                  final data = snapshot.data;
                                  double buTotalSize = 0.0;
                                  if (data != null) {
                                    buTotalSize =
                                        convertUnitToMega(snapshot.data!);
                                  }

                                  return switch (snapshot) {
                                    AsyncSnapshot s when s.hasData =>
                                      Text(buTotalSize.toStringAsFixed(2) ==
                                              '0.00'
                                          ? '未完了'
                                          : '${buTotalSize.toStringAsFixed(2)}MB'),
                                    AsyncSnapshot s when s.hasError =>
                                      const Text('エラー'),
                                    _ => const CircularProgressIndicator(),
                                  };
                                })
                        ]),
                  ),
                  CheckboxListTile.adaptive(
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      if (!isChecked!) {
                        if (restoreCheckList[0]) {
                          setState(() {
                            restoreCheckList[0] = isChecked;
                            restoreCheckList[3] = isChecked;
                          });
                        } else {
                          setState(() => restoreCheckList[3] = isChecked);
                        }
                      } else {
                        setState(() => restoreCheckList[3] = isChecked);
                        if (restoreCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => restoreCheckList[0] = true);
                        }
                      }
                    },
                    value: restoreCheckList[3],
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.task_alt_outlined),
                            SizedBox(width: 7),
                            Text(
                              'タスク',
                            ),
                          ]),
                          Text(
                            '${fileSizes[2]!.toStringAsFixed(2)}MB',
                          ),
                          if (driveService != null)
                            FutureBuilder(
                                future: driveService
                                    .backedupFileSizeByExtension('isar'),
                                builder: (context, snapshot) {
                                  final data = snapshot.data;
                                  double buTotalSize = 0.0;
                                  if (data != null) {
                                    buTotalSize =
                                        convertUnitToMega(snapshot.data!);
                                  }

                                  return switch (snapshot) {
                                    AsyncSnapshot s when s.hasData =>
                                      Text(buTotalSize.toStringAsFixed(2) ==
                                              '0.00'
                                          ? '未完了'
                                          : '${buTotalSize.toStringAsFixed(2)}MB'),
                                    AsyncSnapshot s when s.hasError =>
                                      const Text('エラー'),
                                    _ => const CircularProgressIndicator(),
                                  };
                                })
                        ]),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                          'Googleドライブにあるバックアップ済みのデータをアプリに復元します\n\nGoogleドライブにあるデータが削除などの理由で存在しない場合、今回の復元によってアプリにおいても存在しない状態となります')),
                  const Spacer(),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () async {
                      if (restoreCheckList
                          .where((isChecked) => isChecked)
                          .isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                                content: Text('復元の対象が選択されていません'));
                          },
                        );
                        return;
                      }

                      final restoreCheckSubList = restoreCheckList.sublist(1);
                      final restoreTargetExistsList =
                          await driveService!.getRestoreTargetExistsList();

                      final isNotDefferences = <bool>[];
                      for (final (
                            i,
                            v,
                          ) in restoreCheckSubList.indexed) {
                        isNotDefferences.add(v == restoreTargetExistsList[i]);
                      }

                      final notRestoreTargetList = [];
                      for (final (i, isNotDefference)
                          in isNotDefferences.indexed) {
                        if (!isNotDefference) {
                          final isChecked = restoreCheckSubList[i];
                          if (isChecked) {
                            notRestoreTargetList.add(restoreNames[i]);
                          }
                        }
                      }

                      if (mounted) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Consumer(
                                  builder: (context, ref, _) {
                                    final processing =
                                        ref.watch(processingProvider);
                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!processing)
                                            const Text('復元を開始しますか？')
                                          else
                                            const CircularProgressIndicator
                                                .adaptive()
                                        ]);
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        ref
                                            .read(processingProvider.notifier)
                                            .update((state) => true);
                                        final isRestoreAll =
                                            restoreCheckList.first;
                                        if (isRestoreAll) {
                                          final restoreTargetExistsList =
                                              await driveService!
                                                  .getRestoreTargetExistsList();

                                          final isExistsAll =
                                              restoreTargetExistsList.every(
                                                  (isExists) => isExists);

                                          if (isExistsAll) {
                                            await Future.wait([
                                              driveService.restoreFile(),
                                              driveService.restoreFiles('jpg'),
                                              driveService.restoreFiles('mp4'),
                                            ]);
                                            await driveService.restertApp(ref);

                                            if (mounted) {
                                              ref
                                                  .read(processingProvider
                                                      .notifier)
                                                  .update((state) => false);

                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const AlertDialog(
                                                        content: Text(
                                                            '全ての復元が完了しました'));
                                                  });
                                              cleanBackupCheckedList();
                                            }
                                          } else {
                                            if (mounted) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const ListTile(
                                                                  title: Text(
                                                                      'googleドライブに以下のデータが存在しません')),
                                                              ...notRestoreTargetList
                                                                  .map((notRestoreTarget) =>
                                                                      ListTile(
                                                                          title:
                                                                              Text(notRestoreTarget)))
                                                                  .toList()
                                                            ]),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                    context)
                                                                  ..pop()
                                                                  ..pop();
                                                              },
                                                              child: const Text(
                                                                  '戻る'))
                                                        ]);
                                                  });
                                            }
                                          }
                                        } else if (restoreCheckList
                                                .where((isChecked) => isChecked)
                                                .length ==
                                            2) {
                                          if (notRestoreTargetList.isEmpty) {
                                            final isNotCheckedIndex =
                                                restoreCheckSubList.indexWhere(
                                                    (isChecked) => !isChecked);

                                            switch (isNotCheckedIndex) {
                                              case 0:
                                                await Future.wait([
                                                  driveService!
                                                      .restoreFiles('mp4'),
                                                  driveService.restoreFile(),
                                                ]);
                                                await driveService
                                                    .restertApp(ref);
                                                break;
                                              case 1:
                                                await Future.wait([
                                                  driveService!.restoreFile(),
                                                  driveService
                                                      .restoreFiles('jpg'),
                                                ]);
                                                await driveService
                                                    .restertApp(ref);
                                                break;
                                              case 2:
                                                await Future.wait([
                                                  driveService!
                                                      .restoreFiles('jpg'),
                                                  driveService
                                                      .restoreFiles('mp4'),
                                                ]);
                                                break;
                                            }
                                            final chekedNames = restoreNames
                                                .mapIndexed((index, element) {
                                                  if (index !=
                                                      isNotCheckedIndex) {
                                                    return restoreNames[index];
                                                  }
                                                })
                                                .toList()
                                                .nonNulls;

                                            if (mounted) {
                                              ref
                                                  .read(processingProvider
                                                      .notifier)
                                                  .update((state) => false);

                                              ref
                                                  .read(
                                                      settingProvider.notifier)
                                                  .saveSetting(appSetting);
                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        content: Text(
                                                            '${chekedNames.first}と${chekedNames.last}の復元が完了しました'));
                                                  });

                                              cleanBackupCheckedList();
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const ListTile(
                                                                title: Text(
                                                                    'googleドライブに以下のデータが存在しません')),
                                                            ...notRestoreTargetList
                                                                .map((notRestoreTarget) =>
                                                                    ListTile(
                                                                        title: Text(
                                                                            notRestoreTarget)))
                                                                .toList()
                                                          ]),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                  context)
                                                                ..pop()
                                                                ..pop();
                                                            },
                                                            child: const Text(
                                                                '戻る'))
                                                      ]);
                                                });
                                          }
                                        } else {
                                          if (notRestoreTargetList.isEmpty) {
                                            final index =
                                                restoreCheckSubList.indexWhere(
                                                    (isChecked) => isChecked);

                                            switch (index) {
                                              case 0:
                                                await driveService!
                                                    .restoreFiles('jpg');
                                                break;
                                              case 1:
                                                await driveService!
                                                    .restoreFiles('mp4');
                                                break;
                                              case 2:
                                                await driveService!
                                                    .restoreFile();
                                                await driveService
                                                    .restertApp(ref);
                                                break;
                                            }

                                            if (mounted) {
                                              ref
                                                  .read(processingProvider
                                                      .notifier)
                                                  .update((state) => false);
                                              ref
                                                  .read(
                                                      settingProvider.notifier)
                                                  .saveSetting(appSetting);
                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        content: Text(
                                                            '${restoreNames[index]}の復元が完了しました'));
                                                  });
                                              cleanBackupCheckedList();
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const ListTile(
                                                                title: Text(
                                                                    'googleドライブに以下のデータが存在しません')),
                                                            ...notRestoreTargetList
                                                                .map((notRestoreTarget) =>
                                                                    ListTile(
                                                                        title: Text(
                                                                            notRestoreTarget)))
                                                                .toList()
                                                          ]),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                  context)
                                                                ..pop()
                                                                ..pop();
                                                            },
                                                            child: const Text(
                                                                '戻る'))
                                                      ]);
                                                });
                                          }
                                        }
                                      },
                                      child: const Text('実行')),
                                  const SizedBox(width: 50),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('キャンセル')),
                                ],
                              );
                            });
                      }
                    },
                    child: const Text('復元開始'),
                  ),
                  const SizedBox(height: 50)
                ])));
  }
}
