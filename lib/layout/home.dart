import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/task/ui/reorderable_category_checkbox_list.dart';
import '../features/task/ui/category_task_edit_list.dart';
import '../features/setting/application/tutorial_controller.dart';

import '../pet_card.dart';
import 'grid_category.dart';
import '../features/setting/ui/setting.dart';

import '../features/pet/application/pet_provider.dart';

import 'timeline.dart';

import '../features/task/ui/task_manager.dart';

final petIndexProvider = StateProvider((ref) => 0);
final editableSwitchProvider = StateProvider.autoDispose((ref) => true);
final timelineSwitchProvider = StateProvider.autoDispose((ref) => 2);

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(context, ref) {
    GlobalKey settingTutorial = GlobalKey();
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final tutorialControllerNotifier =
        ref.watch(tutorialControllerProvider.notifier);
    tutorialControllerNotifier.tutorial(settingTutorial, 'settingTutorial',
        'createTutorial', context, scaffoldKey);

    return Scaffold(
        key: scaffoldKey,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     final notification = LocalNotification();
        //     // notification.showNotificationWithActions();
        //     // notification.repeatNotification();
        //     // notification.schedule();

        //     notification
        //         .getPendingNotificationRequests()
        //         .then((value) => print(value.length));

        //     // notification.cancelAllNotifications();
        //   },
        // ),
        drawer: const Drawer(child: Setting()),
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            leading: Consumer(
              builder: (context, ref, _) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Ink(
                    padding: const EdgeInsets.all(5),
                    decoration: const ShapeDecoration(
                      color: Color.fromARGB(50, 158, 158, 158),
                      shape: CircleBorder(),
                    ),
                    child: Icon(
                      key: settingTutorial,
                      size: 20,
                      Icons.settings_outlined,
                    ),
                  ),
                );
              },
            ),
            actions: [
              Consumer(builder: (context, ref, _) {
                final pets = ref.watch(petProvider);

                return switch (2 <= pets.length) {
                  true => IconButton(
                      onPressed: () {
                        final petIndex = ref.read(petIndexProvider);
                        if (petIndex < pets.length - 1) {
                          ref
                              .read(petIndexProvider.notifier)
                              .update((state) => state + 1);
                        } else {
                          ref
                              .read(petIndexProvider.notifier)
                              .update((state) => 0);
                        }
                      },
                      icon: const Icon(
                        size: 20,
                        Icons.arrow_circle_right,
                      )),
                  false => const SizedBox.shrink()
                };
              }),
            ],
            pinned: false,
            snap: false,
            floating: false,
            stretch: true,
            expandedHeight: 340,
            flexibleSpace: const FlexibleSpaceBar(
              background: SizedBox(child: PetCard()),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          SliverToBoxAdapter(
              child: Container(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(children: [
                    const Text("Task",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Transform.scale(
                        scale: .8,
                        origin: const Offset(40, 0),
                        child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(.12),
                              foregroundColor: Colors.black,
                            ),
                            label: Text('管理',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                            onPressed: () {
                              if (ref.watch(petProvider).isNotEmpty) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const TaskManager()));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                          content: Text('ペット(家族)の登録が必要です'),
                                        ));
                              }
                            },
                            icon: Icon(Icons.add_task,
                                color:
                                    Theme.of(context).colorScheme.onPrimary))),
                    const SizedBox(width: 12),
                    Consumer(builder: (context, ref, _) {
                      return IconButton(
                          icon: const Icon(size: 21, Icons.more_horiz),
                          onPressed: () {
                            final pets = ref.watch(petProvider);
                            if (pets.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Consumer(builder: (context, ref, _) {
                                    return ref.watch(editableSwitchProvider)
                                        ? const ReorderableCategoryCheckboxList()
                                        : CategoryTaskEditList(
                                            pets.nonNulls.toList()[
                                                ref.read(petIndexProvider)]);
                                  });
                                },
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                        content: Text('ペット(家族)の登録が必要です'),
                                      ));
                            }
                          });
                    })
                  ]))),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 5,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              child: Center(
                child: Divider(indent: 55, endIndent: 60, thickness: 0.1),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 16,
            ),
          ),
          const GridCategory(),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 8,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              child: Center(
                child: Divider(indent: 55, endIndent: 60, thickness: 0.1),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 5),
          ),
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(top: 10, left: 34, right: 10),
                child: const Text('Complete',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 15),
          ),
          SliverToBoxAdapter(child: Consumer(
            builder: (context, ref, _) {
              final timelineSwitch = ref.watch(timelineSwitchProvider);

              return Row(children: [
                const SizedBox(width: 80),
                IconButton(
                  onPressed: () {
                    if (0 < timelineSwitch) {
                      ref
                          .read(timelineSwitchProvider.notifier)
                          .update((state) => state - 1);
                    } else {
                      ref
                          .read(timelineSwitchProvider.notifier)
                          .update((state) => 2);
                    }
                  },
                  icon: const Icon(
                    size: 21,
                    Icons.navigate_before,
                  ),
                ),
                const SizedBox(width: 50),
                switch (timelineSwitch) {
                  2 => const Text('今日', style: TextStyle()),
                  1 => const Text('1日前', style: TextStyle()),
                  0 => const Text('2日前', style: TextStyle()),
                  _ => const SizedBox()
                }
              ]);
            },
          )),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          const TimeLine()
        ]));
  }
}
