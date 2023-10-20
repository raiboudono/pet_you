import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/setting/application/tutorial_controller.dart';

import '../features/setting/application/app_setting_provider.dart';

class OverLay extends ConsumerStatefulWidget {
  const OverLay({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => OverLayState();
}

class OverLayState extends ConsumerState<OverLay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  OverlayEntry? entry;

  @override
  initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  showOverlay() {
    OverlayState overlayState = Overlay.of(context);
    entry = OverlayEntry(
      builder: (context) {
        return SafeArea(
            child: Center(
                child: Material(
                    type: MaterialType.transparency,
                    child: Stack(alignment: Alignment.center, children: [
                      AnimatedBuilder(
                          animation: controller,
                          child: Container(
                            width: 300,
                            height: 300,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.indigo.withOpacity(.7),
                          ),
                          builder: (context, child) {
                            return ScaleTransition(
                              scale: controller.drive(Tween<double>(
                                begin: 3,
                                end: 1,
                              ).chain(
                                CurveTween(
                                  curve: Curves.bounceIn,
                                ),
                              )),
                              child: child,
                            );
                          }),
                      const Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                  'おつかれさまでした!\n\nガイドはこれで終了です\n\nこのアプリがあなたの手助けとなるように願っています',
                                  style: TextStyle(color: Colors.white)))),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: TextButton(
                            onPressed: () {
                              entry?.remove();
                              entry = null;

                              final appSetting = ref.watch(settingProvider);

                              if (appSetting != null) {
                                appSetting.tutorial = false;

                                ref
                                    .read(settingProvider.notifier)
                                    .saveSetting(appSetting);
                              }

                              ref
                                  .read(tutorialControllerProvider.notifier)
                                  .updateIdentify('');
                            },
                            child: const Text('閉じる',
                                style: TextStyle(color: Colors.white)),
                          ))
                    ]))));
      },
    );
    controller.addListener(() {
      overlayState.setState(() {});
    });
    controller.forward();
    overlayState.insert(entry!);
  }

  @override
  Widget build(context) {
    return const SizedBox();
  }
}
