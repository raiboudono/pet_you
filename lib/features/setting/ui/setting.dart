import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:io';

import '../application/tutorial_controller.dart';

import '../../pet/ui/pet_create.dart';
import '../../pet/ui/pet_edit.dart';

import '../../pet/application/pet_provider.dart';

import '../../../../app.dart';
import '../application/app_setting_provider.dart';
import 'email_contact_form.dart';

import 'terms_of_service.dart';
import 'privacy_policy.dart';

import 'backup.dart';
import 'restore.dart';

class Setting extends ConsumerWidget {
  const Setting({super.key});

  static final settings = [
    "テーマ",
    // "フォント",
    "データ",
    "お問い合わせ",
    "アプリを友達に教える",
    "アプリのレビュー",
    "利用規約",
    "プライバシーポリシー",
    "ライセンス"
  ];

  @override
  Widget build(context, ref) {
    GlobalKey createTutorial = GlobalKey();

    final tutorialControllerNotifier =
        ref.watch(tutorialControllerProvider.notifier);
    Future.delayed(
        const Duration(milliseconds: 1200),
        () => tutorialControllerNotifier.tutorial(
            createTutorial, 'createTutorial', 'petTutorial', context, null));

    final appSetting = ref.watch(settingProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();

    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return const PetCreate();
                  }),
                );
              },
              icon: Icon(key: createTutorial, Icons.add)),
        ]),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      // color: Colors.yellow,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              // itemExtent: 130,
                              itemCount: pets.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                        // width: 225,
                                        height: 90,
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 3, 3, 3),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(.5)),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: SizedBox(
                                                    width: 135,
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                              return PetEdit(
                                                                  pets[index]);
                                                            }),
                                                          );
                                                        },
                                                        child: switch (pets[
                                                                index]
                                                            .headerImagePath) {
                                                          String path
                                                              when File(path)
                                                                  .existsSync() =>
                                                            Hero(
                                                                tag:
                                                                    'image_${pets[index].name}',
                                                                child: Image.file(
                                                                    File(pets[
                                                                            index]
                                                                        .headerImagePath!),
                                                                    fit: BoxFit
                                                                        .cover)),
                                                          _ => Container(
                                                              color: Colors
                                                                  .black12
                                                                  .withOpacity(
                                                                      0.03),
                                                              child: const Center(
                                                                  child: Text(
                                                                      '画像が未登録です')))
                                                        }))),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                                height: 100,
                                                width: 115,
                                                child: Column(children: [
                                                  Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      padding: const EdgeInsets.all(
                                                          3),
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  5, 3, 5, 3),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          .3))),
                                                          child: SizedBox(
                                                              child: Text(
                                                            pets[index].name,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
                                                            maxLines: 1,
                                                          )))),
                                                  Align(
                                                      alignment: Alignment
                                                          .centerLeft,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  6, 3, 6, 3),
                                                          child: Text(
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              pets[index]
                                                                      .message ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12))))
                                                ])),
                                          ],
                                        )));
                              },
                            ),
                            const SizedBox(height: 30),
                            Container(
                                height: 60,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ListTile(
                                    onTap: () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                insetPadding: EdgeInsets.zero,
                                                content: DefaultTextStyle(
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary),
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'プレミアムプランでは以下の機能が使用できます',
                                                          ),
                                                          const Text(
                                                            '',
                                                          ),
                                                          const ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              horizontalTitleGap:
                                                                  0,
                                                              dense: true,
                                                              leading: Icon(
                                                                  size: 20,
                                                                  Icons
                                                                      .backup_outlined,
                                                                  color: Colors
                                                                      .pink),
                                                              title: Text(
                                                                  ' クラウドバックアップ ・ 復元')),
                                                          const ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              horizontalTitleGap:
                                                                  0,
                                                              dense: true,
                                                              leading: Icon(
                                                                  size: 20,
                                                                  Icons
                                                                      .backup_outlined,
                                                                  color: Colors
                                                                      .indigo),
                                                              title: Text(
                                                                  ' アルバムの動画閲覧')),
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child:
                                                                  FilledButton(
                                                                      style: FilledButton.styleFrom(
                                                                          backgroundColor: Colors
                                                                              .black),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context).push(MaterialPageRoute(builder:
                                                                            (context) {
                                                                          return Container();
                                                                        }));
                                                                      },
                                                                      child: const Text(
                                                                          '申し込む',
                                                                          style:
                                                                              TextStyle(color: Colors.white))))
                                                        ])));
                                          });
                                    },
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(15, 0, 18, 0),
                                    leading: const Icon(Icons.star),
                                    title: const Text("Premium",
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold)),
                                    trailing: const Text('Upgrade',
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
                                    tileColor: Colors.indigo)),
                            // SignInButton(
                            //   Buttons.google,
                            //   onPressed: () {
                            //     const List<String> scopes = <String>[];

                            //     GoogleSignIn _googleSignIn = GoogleSignIn(
                            //       scopes: scopes,
                            //     );

                            //     // try {
                            //     //   await _googleSignIn.signIn();
                            //     // } catch (error) {
                            //     //   print(error);
                            //     // }
                            //   },
                            // ),
                            const SizedBox(height: 20),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                      height: 0.1, color: Colors.black12),
                              itemCount: settings.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    child: switch (settings[index]) {
                                  "テーマ" => ListTile(
                                      title: Text(settings[index]),
                                      trailing: SizedBox(
                                          child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: Switch(
                                                activeTrackColor: Colors
                                                    .yellowAccent
                                                    .withOpacity(.6),
                                                activeColor: Colors.white,
                                                inactiveThumbColor: Colors
                                                    .yellowAccent
                                                    .withOpacity(.7),
                                                thumbIcon: MaterialStateProperty
                                                    .resolveWith((states) {
                                                  if (states.contains(
                                                      MaterialState.selected)) {
                                                    return const Icon(
                                                        Icons.sunny);
                                                  }
                                                  return const Icon(
                                                      Icons.nightlight);
                                                }),
                                                value: ref
                                                    .watch(themeModeProvider),
                                                onChanged: (bool value) {
                                                  ref
                                                      .read(themeModeProvider
                                                          .notifier)
                                                      .update((state) => value);

                                                  if (appSetting != null) {
                                                    appSetting
                                                      ..theme = value
                                                      ..createdAt =
                                                          DateTime.now();

                                                    ref
                                                        .read(settingProvider
                                                            .notifier)
                                                        .saveSetting(
                                                            appSetting);
                                                  }
                                                },
                                              )))),
                                  // "フォント" =>
                                  //   ListTile(title: Text(settings[index])),
                                  "データ" => Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Row(children: [
                                        TextButton(
                                          onPressed: () {
                                            if (appSetting!.premium) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return const BackUp();
                                              }));
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        content:
                                                            DefaultTextStyle(
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary),
                                                                child: const Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'プレミアムプランで提供されています',
                                                                      ),
                                                                      Text(
                                                                        '',
                                                                      ),
                                                                      ListTile(
                                                                          contentPadding: EdgeInsets
                                                                              .zero,
                                                                          horizontalTitleGap:
                                                                              0,
                                                                          dense:
                                                                              true,
                                                                          leading: Icon(
                                                                              size: 20,
                                                                              Icons.backup_outlined,
                                                                              color: Colors.pink),
                                                                          title: Text(' クラウドバックアップ ・ 復元')),
                                                                      ListTile(
                                                                          contentPadding: EdgeInsets
                                                                              .zero,
                                                                          horizontalTitleGap:
                                                                              0,
                                                                          dense:
                                                                              true,
                                                                          leading: Icon(
                                                                              size: 20,
                                                                              Icons.backup_outlined,
                                                                              color: Colors.indigo),
                                                                          title: Text(' アルバムの動画閲覧')),
                                                                    ])));
                                                  });
                                            }
                                          },
                                          child: Text('バックアップ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary)),
                                        ),
                                        const SizedBox(width: 80),
                                        TextButton(
                                          onPressed: () {
                                            if (appSetting!.premium) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return const Restore();
                                              }));
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        content:
                                                            DefaultTextStyle(
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary),
                                                                child: const Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'プレミアムプランで提供されています',
                                                                      ),
                                                                      Text(
                                                                        '',
                                                                      ),
                                                                      ListTile(
                                                                          contentPadding: EdgeInsets
                                                                              .zero,
                                                                          horizontalTitleGap:
                                                                              0,
                                                                          dense:
                                                                              true,
                                                                          leading: Icon(
                                                                              size: 20,
                                                                              Icons.backup_outlined,
                                                                              color: Colors.pink),
                                                                          title: Text(' クラウドバックアップ ・ 復元')),
                                                                      ListTile(
                                                                          contentPadding: EdgeInsets
                                                                              .zero,
                                                                          horizontalTitleGap:
                                                                              0,
                                                                          dense:
                                                                              true,
                                                                          leading: Icon(
                                                                              size: 20,
                                                                              Icons.backup_outlined,
                                                                              color: Colors.indigo),
                                                                          title: Text(' アルバムの動画閲覧')),
                                                                    ])));
                                                  });
                                            }
                                          },
                                          child: Text('復元',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary)),
                                        )
                                      ])),
                                  "お問い合わせ" => ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return const EmailContactForm();
                                          }),
                                        );
                                      },
                                      title: Text(settings[index])),
                                  "アプリを友達に教える" => ListTile(
                                      onTap: () {
                                        // ストアのアプリのURLを共有
                                      },
                                      title: Text(settings[index])),
                                  "アプリのレビュー" => ListTile(
                                      onTap: () async {
                                        final InAppReview inAppReview =
                                            InAppReview.instance;

                                        if (await inAppReview.isAvailable()) {
                                          inAppReview.requestReview();
                                        }
                                      },
                                      title: Text(settings[index])),
                                  "利用規約" => ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return const TeamsOfService();
                                          }),
                                        );
                                      },
                                      title: Text(settings[index])),
                                  "プライバシーポリシー" => ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return const PrivacyPolicy();
                                          }),
                                        );
                                      },
                                      title: Text(settings[index])),
                                  "ライセンス" => ListTile(
                                      onTap: () {
                                        showLicensePage(
                                          context: context,
                                          applicationName: 'PetYou',
                                          applicationVersion: '1.0.0',
                                          applicationIcon:
                                              const Icon(Icons.face),
                                          applicationLegalese: '2023 MIYA',
                                        );
                                      },
                                      title: Text(settings[index])),
                                  _ => const SizedBox.shrink()
                                });
                              },
                            )
                          ]))));
        }));
  }
}
