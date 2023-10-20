import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:intl/intl.dart";
import 'dart:io';
import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'editor.dart';
import '../model/diary.dart';
import '../application/diary_provider.dart';

import '../../folder/model/folder.dart';
import '../../folder/ui/folder_create.dart';
import '../../folder/ui/folder_edit.dart';
import '../../folder/application/pet_folder_provider.dart';
import '../../setting/application/permissionHandler.dart';

/*danger:
  カメラを起動すると lost connection になった
  quill のセレクションは関係ない
  pet や task においても同じエラーが出た
  しかし vscode の接続が途絶えた状態ならば
  pet, task, editor 共に問題ない
  というか、デバッグ実行後にしばらくたってからやると出なくなるかも
  というのも、動画、ギャラリーとかをしてみた後にカメラしたら出なくなった
  vscode の問題ということもありそう
  ネットを見ると今月でも同エラーが出てる記事あったが解決してなかったし
  いったん放置
  (flutter の upgrade もしたしね)


 */

class DiaryList extends ConsumerStatefulWidget {
  const DiaryList({super.key});

  @override
  DiaryListState createState() => DiaryListState();
}

class DiaryListState extends ConsumerState<DiaryList>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  late final List<String> tabs;
  late final List<dynamic> drawer;
  int tabIndex = 0;
  List<Diary>? searchResult;
  Timer? debounce;
  int stackIndex = 0;
  final formFieldKey = GlobalKey<FormFieldState>();

  syncTabIndex() {
    setState(() => tabIndex = controller.index);
  }

  @override
  void initState() {
    final folders = ref.read(petFolderProvider);

    tabs = ['未分類', ...folders.map((folder) => folder.name).toList()];
    drawer = ['未分類', ...folders];
    controller = TabController(vsync: this, length: tabs.length);
    controller.addListener(syncTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(syncTabIndex);
    controller.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(context) {
    final petDiaries = ref.watch(petDiaryProvider);

    final nullIdDiaries =
        petDiaries.where((diary) => diary.folderId == null).toList();

    final notNullIdDiaries =
        petDiaries.where((diary) => diary.folderId != null).toList();

    final idDiariesGroup = notNullIdDiaries
        .groupListsBy((diary) => diary.folderId)
        .values
        .toList();

    List<List<Diary?>> tabViewsList = [nullIdDiaries, ...idDiariesGroup];
    while (tabViewsList.length < tabs.length) {
      tabViewsList.add([]);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionHandler.requestCameraPermission();
      await PermissionHandler.requestStoragePermission();
    });

    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            endDrawer: Drawer(
                width: 230,
                child: Scaffold(
                    appBar: AppBar(actions: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(children: [FolderCreate()]);
                              });
                        },
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 5),
                    ]),
                    body: ListView.builder(
                        itemCount: drawer.length,
                        itemBuilder: (context, index) {
                          return switch (drawer[index]) {
                            Folder(:final name) => ListTile(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(children: [
                                          FolderEdit(drawer[index])
                                        ]);
                                      });
                                },
                                title: Text(
                                  name,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                ),
                                trailing:
                                    Text('${tabViewsList[index].length}')),
                            _ => ListTile(
                                title: Text(drawer[index]),
                                trailing: Text('${tabViewsList[index].length}'))
                          };
                        }))),
            appBar: AppBar(
              toolbarHeight: 80,
              // backgroundColor: Colors.blue.shade100,
              title: Column(children: [
                // const SizedBox(height: 10),
                SizedBox(
                    width: 240,
                    height: 50,
                    child: Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            setState(
                              () {
                                if (stackIndex == 0) {
                                  stackIndex++;
                                }
                              },
                            );
                          } else {
                            if (formFieldKey.currentState?.value.isNotEmpty) {
                              return;
                            }
                            setState(
                              () {
                                if (stackIndex == 1) {
                                  stackIndex--;
                                  searchResult = null;
                                }
                              },
                            );
                          }
                        },
                        child: TextFormField(
                          key: formFieldKey,
                          onTapOutside: (_) {
                            final FocusScopeNode currentScope =
                                FocusScope.of(context);
                            if (!currentScope.hasPrimaryFocus &&
                                currentScope.hasFocus) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            }
                          },
                          onChanged: (value) {
                            if (debounce?.isActive ?? false) debounce?.cancel();
                            debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              final splitTexts = value.split(' ');
                              if (splitTexts
                                  .where((text) => text.isNotEmpty)
                                  .isEmpty) {
                                setState(
                                  () => searchResult = null,
                                );

                                return;
                              }
                              for (final text in splitTexts) {
                                final results = ref
                                    .read(petDiaryProvider.notifier)
                                    .search(text);

                                setState(
                                  () => searchResult = results,
                                );
                              }
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: '検索',
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(.2),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 11),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ))),
              ]),
              centerTitle: true,
              actions: [
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(children: [
              const SizedBox(height: 10),
              if (stackIndex == 0)
                SizedBox(
                    child: TabBar(
                  controller: controller,
                  onTap: (int index) =>
                      setState(() => tabIndex = controller.index),
                  isScrollable: true,
                  tabs: tabs.map((tab) {
                    return SizedBox(
                        height: 50, child: Center(child: Text(tab)));
                  }).toList(),
                )),
              const SizedBox(height: 10),
              IndexedStack(index: stackIndex, children: [
                SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                        height: 565,
                        child: TabBarView(
                            controller: controller,
                            children: tabViewsList.map((diaries) {
                              return SizedBox(
                                  height: 565,
                                  child: diaries.isEmpty
                                      ? const Center(child: Text('まだ日記がありません'))
                                      : ListView.builder(
                                          itemCount: diaries.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                        return Consumer(
                                                          builder: (context,
                                                              ref, _) {
                                                            return Editor(
                                                                diaries[index],
                                                                tabIndex == 0
                                                                    ? null
                                                                    : diaries[
                                                                            index]!
                                                                        .folderId);
                                                          },
                                                        );
                                                      }),
                                                    );
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  horizontalTitleGap: 30,
                                                  contentPadding: switch (
                                                      diaries[index]
                                                          ?.headerImagePath) {
                                                    '' => const EdgeInsets.only(
                                                        left: 8,
                                                        right: 10,
                                                      ),
                                                    _ => const EdgeInsets.only(
                                                        left: 0,
                                                        right: 10,
                                                      )
                                                  },
                                                  leading: switch (
                                                      diaries[index]
                                                          ?.headerImagePath) {
                                                    '' => null,
                                                    _ => ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: switch (diaries[
                                                                index]
                                                            ?.headerImagePath) {
                                                          String path
                                                              when File(path)
                                                                  .existsSync() =>
                                                            Image.file(
                                                                width: 60,
                                                                height: 70,
                                                                File(path),
                                                                fit: BoxFit
                                                                    .cover),
                                                          _ => null
                                                        })
                                                  },
                                                  title: Text(
                                                      diaries[index]!.title ??
                                                          '',
                                                      maxLines: 1),
                                                  trailing: Text(
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(
                                                              diaries[index]!
                                                                  .updatedAt!),
                                                      style: const TextStyle(
                                                          color: Colors.grey)),
                                                ));
                                          }));
                            }).toList()))),
                SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                        height: 615,
                        child: ListView.builder(
                            itemExtent: 80,
                            itemCount: searchResult?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return Consumer(
                                            builder: (context, ref, _) {
                                              return Editor(
                                                  searchResult![index],
                                                  tabIndex == 0
                                                      ? null
                                                      : searchResult?[index]
                                                          .folderId);
                                            },
                                          );
                                        }),
                                      );
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    horizontalTitleGap: 30,
                                    contentPadding: switch (
                                        searchResult?[index].headerImagePath) {
                                      '' => const EdgeInsets.only(
                                          left: 8,
                                          right: 10,
                                        ),
                                      _ => const EdgeInsets.only(
                                          left: 0,
                                          right: 10,
                                        )
                                    },
                                    leading: switch (
                                        searchResult?[index].headerImagePath) {
                                      final String path
                                          when File(path).existsSync() =>
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.file(
                                                width: 60,
                                                height: 70,
                                                File(path),
                                                fit: BoxFit.cover)),
                                      _ => null,
                                    },
                                    title: Text(searchResult![index].title!,
                                        maxLines: 1),
                                    trailing: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            searchResult![index].updatedAt!),
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ));
                            }))),
              ])
            ]),
            floatingActionButton: FloatingActionButton.small(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return Consumer(
                        builder: (context, ref, _) {
                          final petFolderWorker =
                              ref.read(petFolderProvider.notifier);

                          return Editor(
                              null,
                              tabIndex == 0
                                  ? null
                                  : petFolderWorker
                                      .findByName(tabs[tabIndex])
                                      .id);
                        },
                      );
                    }),
                  );
                },
                child: const Icon(Icons.add))));
  }
}
