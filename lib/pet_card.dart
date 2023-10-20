import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import "package:intl/intl.dart";

import 'layout/home.dart';

import 'layout/diary_entry.dart';
import 'layout/summary_entry.dart';

import 'features/pet/application/pet_provider.dart';

import 'features/setting/application/confetti.dart';
import 'features/setting/application/tutorial_controller.dart';

import './layout/overlay.dart';

class PetCard extends ConsumerWidget {
  const PetCard({super.key});

  @override
  Widget build(context, ref) {
    final overlayKey = GlobalObjectKey<OverLayState>(context);
    final tutorialControllerNotifier =
        ref.watch(tutorialControllerProvider.notifier);
    if (tutorialControllerNotifier.identify == 'gridTutorial' ||
        tutorialControllerNotifier.identify == 'completeTutorial') {
      ref.watch(confettiPlayProvider).play();

      if (tutorialControllerNotifier.identify == 'completeTutorial') {
        Future.delayed(const Duration(seconds: 2),
            () => overlayKey.currentState?.showOverlay());
      }
    }

    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();

    if (pets.isEmpty) {
      return const SizedBox();
    }

    final pet = pets[petIndex];

    return Scaffold(
        appBar: AppBar(),
        body: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(children: [
              Card(
                  elevation: 1.2,
                  surfaceTintColor: Colors.lightBlue,
                  child: Column(children: [
                    SizedBox(
                        height: 200,
                        width: 400,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              // bottomLeft: Radius.circular(10.0),
                              // bottomRight: Radius.circular(10.0)
                            ),
                            child: switch (pet.headerImagePath) {
                              String path when File(path).existsSync() =>
                                Stack(alignment: Alignment.center, children: [
                                  Image.file(
                                      height: double.infinity,
                                      width: double.infinity,
                                      File(pet.headerImagePath!),
                                      fit: BoxFit.cover),
                                  const Confetti(),
                                  OverLay(key: overlayKey),
                                ]),
                              _ =>
                                Stack(alignment: Alignment.center, children: [
                                  const Text('\n\n\n写真が未登録です'),
                                  const Confetti(),
                                  OverLay(key: overlayKey),
                                ]),
                            })),
                    Container(
                        padding: const EdgeInsets.only(right: 8, left: 10),
                        child: Row(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 190,
                                    child: Text(pet.name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                  color: Colors.blue
                                                      .withOpacity(.6),
                                                  offset:
                                                      Offset.fromDirection(.3),
                                                  blurRadius: 2)
                                            ]),
                                        overflow: TextOverflow.ellipsis)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: switch (pet.dateOfBirth) {
                                    DateTime() => Text(
                                        DateFormat.yMMMd('ja')
                                            .format(pet.dateOfBirth!),
                                        style: TextStyle(
                                            color: Colors.grey.withOpacity(1),
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  color: Colors.blue
                                                      .withOpacity(.4),
                                                  offset:
                                                      Offset.fromDirection(.3),
                                                  blurRadius: 2)
                                            ])),
                                    _ => null
                                  },
                                ),
                              ]),
                          const Spacer(),
                          const SummaryEntry(),
                          const SizedBox(width: 15),
                          const DiaryEntry(),
                        ]))
                  ]))
            ])));
  }
}
