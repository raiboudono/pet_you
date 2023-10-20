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

// import 'email_form.dart';

final processingProvider = StateProvider.autoDispose((ref) => false);

/*firebase auth 用 */
final userProvider = StateProvider<User?>((ref) => null);

class BackUp extends ConsumerStatefulWidget {
  const BackUp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => BackUpState();
}

class BackUpState extends ConsumerState<BackUp> {
  final backupNames = ['写真', '動画', 'タスク'];
  final backupCheckList = <bool>[false, false, false, false];
  late final List<bool> backupTargetExistsList;
  late final List<Media?> images;
  late final List<Media?> videos;
  final task = io.File('/data/user/0/com.miya.pet_you/app_flutter/Pet.isar');
  late final List<double?> fileSizes;
  late final double totalSize;
  late final double backedupTotalSize;

  void cleanBackupCheckedList() {
    setState(() {
      for (final (i, _) in backupCheckList.indexed) {
        backupCheckList[i] = false;
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

    backupTargetExistsList = <bool>[
      images.isNotEmpty,
      videos.isNotEmpty,
      task.existsSync(),
    ];

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

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Container(
                // width: 50,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.circular(5)),
                child: const Center(
                    child: Text('バックアップ', style: TextStyle(fontSize: 16)))),
            actions: [
              if (account != null)
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return Material(
                          child: Column(children: [
                        const Spacer(),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('バックアップ済みの全てのデータをGoogleDriveから削除する')),
                        const Spacer(),
                        FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text('この操作は取り消すことができません'),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await driveService
                                                  ?.deleteBackupAll();

                                              ref
                                                  .read(
                                                      settingProvider.notifier)
                                                  .saveSetting(appSetting
                                                    ..backupImageDate = null
                                                    ..backupVideoDate = null
                                                    ..backupTaskDate = null);

                                              if (mounted) {
                                                Navigator.of(context)
                                                  ..pop()
                                                  ..pop();

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const AlertDialog(
                                                          content: Text(
                                                              '削除が完了しました'));
                                                    }).then((value) => setState(
                                                      () {},
                                                    ));
                                              }
                                            },
                                            child: const Text('削除',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              'キャンセル',
                                            )),
                                      ],
                                    );
                                  });
                            },
                            child: const Text(
                              '削除',
                            )),
                        const SizedBox(height: 50)
                      ]));
                    })).then((value) => setState(
                              () {},
                            ));
                  },
                  icon: const Icon(Icons.settings_outlined),
                )
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
                      child: Text('アプリ > > > > > Googleドライブ',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 10),
                  CheckboxListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) {
                        for (int i = 0; i < backupCheckList.length; i++) {
                          setState(() => backupCheckList[i] = isChecked!);
                        }
                      },
                      value: backupCheckList[0],
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
                        if (backupCheckList[0]) {
                          setState(() {
                            backupCheckList[0] = isChecked;
                            backupCheckList[1] = isChecked;
                          });
                        } else {
                          setState(() => backupCheckList[1] = isChecked);
                        }
                      } else {
                        setState(() => backupCheckList[1] = isChecked);
                        if (backupCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => backupCheckList[0] = true);
                        }
                      }
                    },
                    value: backupCheckList[1],
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
                        if (backupCheckList[0]) {
                          setState(() {
                            backupCheckList[0] = isChecked;
                            backupCheckList[2] = isChecked;
                          });
                        } else {
                          setState(() => backupCheckList[2] = isChecked);
                        }
                      } else {
                        setState(() => backupCheckList[2] = isChecked);
                        if (backupCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => backupCheckList[0] = true);
                        }
                      }
                    },
                    value: backupCheckList[2],
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
                        if (backupCheckList[0]) {
                          setState(() {
                            backupCheckList[0] = isChecked;
                            backupCheckList[3] = isChecked;
                          });
                        } else {
                          setState(() => backupCheckList[3] = isChecked);
                        }
                      } else {
                        setState(() => backupCheckList[3] = isChecked);
                        if (backupCheckList
                            .sublist(1)
                            .every((checked) => checked)) {
                          setState(() => backupCheckList[0] = true);
                        }
                      }
                    },
                    value: backupCheckList[3],
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
                          'アプリの現在の状態をGoogleドライブにバックアップします\n\n前回のバックアップ時にアプリに存在した画像や動画などのデータが削除などの理由で現在のアプリに存在しない場合、今回のバックアップによってGoogleドライブにおいても存在しない状態となります')),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (backupCheckList
                          .where((isChecked) => isChecked)
                          .isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                                content: Text('バックアップの対象が選択されていません'));
                          },
                        );
                        return;
                      }

                      final backupCheckSubList = backupCheckList.sublist(1);

                      final isNotDefferences = <bool>[];
                      for (final (
                            i,
                            v,
                          ) in backupCheckSubList.indexed) {
                        isNotDefferences.add(v == backupTargetExistsList[i]);
                      }

                      final notBackupTargetList = [];
                      for (final (i, isNotDefference)
                          in isNotDefferences.indexed) {
                        if (!isNotDefference) {
                          final isChecked = backupCheckSubList[i];
                          if (isChecked) {
                            notBackupTargetList.add(backupNames[i]);
                          }
                        }
                      }

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
                                          const Text('バックアップを開始しますか？')
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
                                      final isBackupAll = backupCheckList.first;
                                      if (isBackupAll) {
                                        final isExistsAll =
                                            backupTargetExistsList
                                                .every((isExists) => isExists);

                                        if (isExistsAll) {
                                          await Future.wait([
                                            driveService!.backupFile(task),
                                            driveService.backupFiles(
                                                images.nonNulls.toList()),
                                            driveService.backupFiles(
                                                videos.nonNulls.toList())
                                          ]);

                                          if (mounted) {
                                            ref
                                                .read(
                                                    processingProvider.notifier)
                                                .update((state) => false);

                                            final now = DateTime.now();

                                            ref
                                                .read(settingProvider.notifier)
                                                .saveSetting(appSetting
                                                  ..backupImageDate = now
                                                  ..backupVideoDate = now
                                                  ..backupTaskDate = now);

                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                      content: Text(
                                                          '全てのバックアップが完了しました'));
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
                                                                  'アプリに以下のデータが存在しません')),
                                                          ...notBackupTargetList
                                                              .map((notBackupTarget) =>
                                                                  ListTile(
                                                                      title: Text(
                                                                          notBackupTarget)))
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
                                                          child:
                                                              const Text('戻る'))
                                                    ]);
                                              });
                                        }
                                      } else if (backupCheckList
                                              .where((isChecked) => isChecked)
                                              .length ==
                                          2) {
                                        if (notBackupTargetList.isEmpty) {
                                          final isNotCheckedIndex =
                                              backupCheckSubList.indexWhere(
                                                  (isChecked) => !isChecked);

                                          final now = DateTime.now();

                                          switch (isNotCheckedIndex) {
                                            case 0:
                                              await Future.wait([
                                                driveService!.backupFiles(
                                                    videos.nonNulls.toList()),
                                                driveService.backupFile(task),
                                              ]);
                                              appSetting
                                                ..backupVideoDate = now
                                                ..backupTaskDate = now;

                                              break;
                                            case 1:
                                              await Future.wait([
                                                driveService!.backupFile(task),
                                                driveService.backupFiles(
                                                    images.nonNulls.toList()),
                                              ]);
                                              appSetting
                                                ..backupTaskDate = now
                                                ..backupImageDate = now;
                                              break;
                                            case 2:
                                              await Future.wait([
                                                driveService!.backupFiles(
                                                    images.nonNulls.toList()),
                                                driveService.backupFiles(
                                                    videos.nonNulls.toList())
                                              ]);
                                              appSetting
                                                ..backupImageDate = now
                                                ..backupVideoDate = now;
                                              break;
                                          }
                                          final chekedNames = backupNames
                                              .mapIndexed((index, element) {
                                                if (index !=
                                                    isNotCheckedIndex) {
                                                  return backupNames[index];
                                                }
                                              })
                                              .toList()
                                              .nonNulls;

                                          if (mounted) {
                                            ref
                                                .read(
                                                    processingProvider.notifier)
                                                .update((state) => false);

                                            ref
                                                .read(settingProvider.notifier)
                                                .saveSetting(appSetting);
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      content: Text(
                                                          '${chekedNames.first}と${chekedNames.last}のバックアップが完了しました'));
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
                                                                  'アプリに以下のデータが存在しません')),
                                                          ...notBackupTargetList
                                                              .map((notBackupTarget) =>
                                                                  ListTile(
                                                                      title: Text(
                                                                          notBackupTarget)))
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
                                                          child:
                                                              const Text('戻る'))
                                                    ]);
                                              });
                                        }
                                      } else {
                                        if (notBackupTargetList.isEmpty) {
                                          final index =
                                              backupCheckSubList.indexWhere(
                                                  (isChecked) => isChecked);

                                          final now = DateTime.now();

                                          switch (index) {
                                            case 0:
                                              await driveService?.backupFiles(
                                                  images.nonNulls.toList());
                                              appSetting.backupImageDate = now;
                                              break;
                                            case 1:
                                              await driveService?.backupFiles(
                                                  videos.nonNulls.toList());
                                              appSetting.backupVideoDate = now;
                                              break;
                                            case 2:
                                              await driveService
                                                  ?.backupFile(task);
                                              appSetting.backupTaskDate = now;
                                              break;
                                          }

                                          if (mounted) {
                                            ref
                                                .read(
                                                    processingProvider.notifier)
                                                .update((state) => false);
                                            ref
                                                .read(settingProvider.notifier)
                                                .saveSetting(appSetting);
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      content: Text(
                                                          '${backupNames[index]}のバックアップが完了しました'));
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
                                                                  'アプリに以下のデータが存在しません')),
                                                          ...notBackupTargetList
                                                              .map((notBackupTarget) =>
                                                                  ListTile(
                                                                      title: Text(
                                                                          notBackupTarget)))
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
                                                          child:
                                                              const Text('戻る'))
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
                    },
                    child: const Text('バックアップ開始'),
                  ),
                  const SizedBox(height: 50)
                ])));
  }
}
