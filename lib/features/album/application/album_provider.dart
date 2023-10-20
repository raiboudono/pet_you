import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';
import '../../../infra/album/album_repository.dart';
import '../model/media.dart';

final albumProvider =
    StateNotifierProvider.autoDispose<AlbumStateNotifier, List<Media>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.album));
  return AlbumStateNotifier(repository);
});

class AlbumStateNotifier extends StateNotifier<List<Media>> {
  AlbumStateNotifier(this._repository) : super(_repository.getMediasAll());
  final AlbumRepository _repository;

/*danger:
メモに画像があるならばアルバム=media が存在する
アルバム画像は消しても visible なので実在する
メモの画像とアルバムは同じパスを共有する
よってアルバムを visible = false にしてもメモ画像は残る
一方
メモ画像を消して更新した場合、
表示の時点で pickedProvider にパスが渡され、更新時にエディタ内の画像と突合し
エディタになければディレクトリからも消すという流れ
前提より、メモとアルバムはパスを共有する
よって、メモを消すならばアルバムの画像が消える
たぶん大丈夫だが、アルバムは visible = true && パスが存在するならば表示
したがって、メモ画像を消しても例のばってんマークは回避

復元について
アルバムだけを消すなら
・visibe =true で事足りるが方法が不明
 ⇒ ログイン機能で特定の id を抽出しその id のみ専用の UI(ボタン等)表示して true へ
・メモに残っているという前提になるので、現在のメモ更新時にそのパスのメディアが存在するなら画像を新規登録しない
とう判定を一次的にしないという手もあるかもネ

メモの画像を消すなら(前提よりメモを消すならアルバムも消える)
・ドライブから復元
メディアが消えるワケではなくメディアの path はそのままである
そのためバックアップする時にメディアのパスをメタデータ的なところに保存するなら
(というかそのパスをそのままドライブファイル名にしてしまえ)
メモの復元はできないがアルバムの復元はできる
またアルバムは共有機能があるため、復元後にメールなどに共有すればよい
そうすれば仮にネイティブギャラリーからも存在しなかった場合にも対応できる


そういえば共有機能って
isar も画像もローカルに保存されているので
それぞれローカルに保存というよりも、クラウドに保存して共有しておかなければ？？
しかもバックアップとなると、ドライブ共有？？
firebase にリスエストして firebase 経由で ドライブにリスエストして
ドライブデータを firebase に落としてリアルタイムで反映することはできるのかな？
ヤバイ
Cloud Functions に自作関数(サーバ関数)をデプロイして
APIとして利用すれば、共有ボタン実行時や何か操作実行などのタイミングで
httpにより関数が実行される
その関数をドライブから取得、DBに反映、リアルタイム処理をすればできるかも？？

ドライブを共有権限？？できたとして、それを使用するどちらのユーザーのドライブなのかという問題

 */

  int assignId() => _repository.assignId();

  List<Media?> getMediasAll() {
    return _repository.getMediasAll();
  }

  List<Media?> getVisibleMediasAll() {
    return _repository.getVisibleMediasAll();
  }

  Media? findMediaByPath(path) {
    return _repository.findMediaByPath(path);
  }

  void removeAlbum(Media media) {
    _repository.deleteMedia(media);
    state = _repository.getMediasAll();
  }

  void saveAlbum(Media media) {
    _repository.insertMedia(media);
    state = _repository.getMediasAll();
  }

  void updateAlbum(Media media) {
    _repository.updateMedia(media);
    state = _repository.getMediasAll();
  }
}
