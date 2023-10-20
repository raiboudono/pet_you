import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home.dart';
import '../features/schedule/ui/calender.dart';
import '../features/album/ui/album.dart';

final uiIndexProvider = StateProvider<int>((ref) => 0);

class Layout extends ConsumerWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageViewController = PageController();

    return Scaffold(
      // body: _uiList[ref.watch(uiIndexProvider)],
      body: PageView(
        controller: pageViewController,
        children: const [
          Home(),
          Calendar(),
          Album(),
        ],
        onPageChanged: (index) {
          ref.read(uiIndexProvider.notifier).update((state) => index);
        },
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: ref.watch(uiIndexProvider),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) =>
              pageViewController.jumpToPage(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.house),
              label: 'home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: 'schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library),
              label: 'album',
            )
          ]),
    );
  }
}
