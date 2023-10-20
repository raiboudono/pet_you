import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

import '../model/media.dart';

import '../application/album_provider.dart';
import '../../setting/application/app_setting_provider.dart';

final currentImageIndexController = StateProvider((ref) => 0);

final videoControllerProvider = FutureProvider.autoDispose.family((
  ref,
  videoPath,
) async {
  VideoPlayerController controller =
      VideoPlayerController.file(File(videoPath as String));

  ref.onDispose(() {
    controller.dispose();
  });

  await controller.initialize();

  return controller;
});

/*danger:
削除について
非表示または削除するにして
非表示一覧を設けて、その中も個別削除ならびに一括削除をできるようにする
というのはどうだろうか？？
アルバムを真の意味で削除するとクイルがバグる

 */

class Album extends ConsumerWidget {
  const Album({super.key});
  static const mediaTypes = ['image', 'video'];

  @override
  Widget build(context, ref) {
    final List<Media?> visibleMedias = ref
        .watch(albumProvider)
        .nonNulls
        .where((media) => media.visible)
        /*danger: コレしてるのに null な video あるの調査必要
         video については 存在しないなら例外になる(vscodeで例外外してる)
         */
        .where((media) => File(media.path).existsSync())
        .toList();

    final pictures = visibleMedias
        .where((media) => media!.type == mediaTypes.first)
        .toList();
    final videos =
        visibleMedias.where((media) => media!.type == mediaTypes.last).toList();

    final appSetting = ref.watch(settingProvider);

    return DefaultTabController(
        length: mediaTypes.length,
        child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 5),
                  icon: Icon(Icons.photo_camera_back_outlined),
                  child: Text('写真', style: TextStyle(fontSize: 12)),
                ),
                Tab(
                    icon: Icon(Icons.video_camera_back_outlined),
                    child: Text('動画', style: TextStyle(fontSize: 12))),
              ]),
            ),
            body: TabBarView(children: [
              if (pictures.isNotEmpty)
                GridView.builder(
                    itemCount: pictures.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.5,
                      mainAxisSpacing: 12,
                      childAspectRatio: .98,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            ref
                                .read(currentImageIndexController.notifier)
                                .update((state) => index);

                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                  ),
                                  body: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: PageView.builder(
                                        controller: PageController(
                                            viewportFraction: 1.05,
                                            initialPage: index),
                                        itemCount: pictures.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: PhotoView(
                                                  heroAttributes:
                                                      PhotoViewHeroAttributes(
                                                    tag: 'image_$index',
                                                  ),
                                                  wantKeepAlive: false,
                                                  imageProvider: Image.file(
                                                    File(pictures[index]!.path),
                                                    fit: BoxFit.cover,
                                                  ).image));
                                        },
                                      )),
                                  bottomNavigationBar: SizedBox(
                                      height: 80,
                                      child: BottomNavigationBar(
                                        backgroundColor: Colors.black,
                                        selectedItemColor:
                                            Colors.green.shade200,
                                        unselectedItemColor:
                                            Colors.green.shade200,
                                        onTap: (index) async {
                                          final currentImageIndex = ref.watch(
                                              currentImageIndexController);
                                          if (index == 0) {
                                            await Share.shareXFiles([
                                              XFile(File(pictures[
                                                          currentImageIndex]!
                                                      .path)
                                                  .path)
                                            ], subject: '', text: '');
                                          } else {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return SizedBox(
                                                      height: 130,
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Text(
                                                                'アルバムから削除しますか？\n\n日記の画像は削除されません'),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      ref.read(albumProvider.notifier).updateAlbum(pictures[
                                                                              currentImageIndex]!
                                                                          .copyWith(
                                                                              visible: false));

                                                                      ref
                                                                          .read(currentImageIndexController
                                                                              .notifier)
                                                                          .update((state) =>
                                                                              1);

                                                                      ref.invalidate(
                                                                          currentImageIndexController);
                                                                      Navigator.of(
                                                                          context)
                                                                        ..pop()
                                                                        ..pop();
                                                                    },
                                                                    child: const Text(
                                                                        '削除する',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red)),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator
                                                                            .pop(
                                                                      context,
                                                                    ),
                                                                    child: const Text(
                                                                        "キャンセル"),
                                                                  )
                                                                ])
                                                          ]));
                                                });
                                          }
                                        },
                                        items: const [
                                          BottomNavigationBarItem(
                                            label: '共有',
                                            icon: Icon(Icons.share),
                                          ),
                                          BottomNavigationBarItem(
                                              label: '削除',
                                              icon: Icon(Icons.delete)),
                                        ],
                                      )));
                            }));
                          },
                          child: switch (pictures[index]) {
                            Media(:final path) when File(path).existsSync() =>
                              Hero(
                                  tag: 'image_$index',
                                  child: Image.file(
                                    File(pictures[index]!.path),
                                    fit: BoxFit.cover,
                                  )),
                            _ => null
                          });
                    })
              else
                const Center(child: Text('日記に保存した画像が表示されます')),
              /*danger:否定をはずす */
              if (!appSetting!.premium && videos.isNotEmpty)
                GridView.builder(
                    itemCount: videos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.5,
                      mainAxisSpacing: 12,
                      childAspectRatio: .98,
                    ),
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: ref.watch(
                            videoControllerProvider(videos[index]!.path)
                                .future),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator.adaptive(),
                            );
                          } else {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Scaffold(
                                      appBar: AppBar(),
                                      body: GestureDetector(
                                          onTap: () =>
                                              snapshot.data!.value.isPlaying
                                                  ? snapshot.data!.pause()
                                                  : snapshot.data!.play(),
                                          // Navigator.of(context).pop()
                                          child: Stack(children: [
                                            AspectRatio(
                                              aspectRatio: snapshot
                                                  .data!.value.aspectRatio,
                                              child: Hero(
                                                  tag: 'video_$index',
                                                  child: VideoPlayer(
                                                      snapshot.data!)),
                                            ),
                                            const ClosedCaption(text: null),
                                            VideoProgressIndicator(
                                                snapshot.data!,
                                                allowScrubbing: true,
                                                padding:
                                                    const EdgeInsets.all(3),
                                                colors: VideoProgressColors(
                                                    playedColor:
                                                        Theme.of(context)
                                                            .primaryColor)),
                                          ])),
                                    );
                                  }));
                                },
                                child: AspectRatio(
                                    aspectRatio:
                                        snapshot.data!.value.aspectRatio,
                                    child: Hero(
                                        tag: 'video_$index',
                                        child: VideoPlayer(snapshot.data!))));
                          }
                        },
                      );
                    })
              /*danger:否定をはずす */
              else if (!appSetting.premium && videos.isEmpty)
                const Center(child: Text('日記に保存した動画が表示されます'))
              else
                Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'プレミアムプランで提供されています',
                              ),
                              Text(
                                '',
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        size: 20,
                                        Icons.backup_outlined,
                                        color: Colors.pink),
                                    Text(' クラウドバックアップ ・ 復元')
                                  ]),
                              SizedBox(height: 15),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        size: 20,
                                        Icons.backup_outlined,
                                        color: Colors.indigo),
                                    Text(' アルバムの動画閲覧                  ')
                                  ])
                            ]))),
            ])));
  }
}
