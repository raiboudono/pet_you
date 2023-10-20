import 'package:isar/isar.dart';

import '../../features/folder/model/folder.dart';

class FolderRepository {
  FolderRepository(this.isar);
  Isar isar;

  List<Folder> getFoldersAll() {
    return isar.folders.where().findAllSync();
  }

  findByName(name) {
    return isar.folders.filter().nameEqualTo(name).findFirstSync();
  }

  deleteFolder(Folder folder) {
    isar.writeTxnSync(() {
      isar.folders.deleteSync(folder.id);
    });
  }

  insertFolder(Folder folder) {
    isar.writeTxnSync(() {
      isar.folders.putSync(folder);
    });
  }

  updateFolder(Folder folder) {
    isar.writeTxnSync(() {
      isar.folders.putSync(folder);
    });
  }
}
