import 'package:isar/isar.dart';

import '../../../features/album/model/media.dart';

class AlbumRepository {
  AlbumRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  List<Media> getMediasAll() {
    return isar.medias.where().findAllSync();
  }

  List<Media> getVisibleMediasAll() {
    return isar.medias.filter().visibleEqualTo(true).findAllSync();
  }

  Media? findMediaByPath(path) {
    return isar.medias.filter().pathEqualTo(path).findFirstSync();
  }

  deleteMedia(Media media) {
    isar.writeTxnSync(() {
      isar.medias.deleteSync(media.id);
    });
  }

  insertMedia(Media media) {
    isar.writeTxnSync(() {
      isar.medias.putSync(media);
    });
  }

  updateMedia(Media media) {
    isar.writeTxnSync(() {
      isar.medias.putSync(media);
    });
  }
}
