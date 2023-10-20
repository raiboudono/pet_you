import 'package:isar/isar.dart';

import '../../features/diary/model/diary.dart';

class DiaryRepository {
  DiaryRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  List<Diary> getDiarysAll() {
    return isar.diarys.where().findAllSync();
  }

  // diariesByFolderIds(ids) {
  //   final nullsAll = isar.diarys.filter().folderIdIsNull().findAllSync();
  //   final idsAll = ids
  //       .map((id) => isar.diarys.filter().folderIdEqualTo(id).findAllSync())
  //       .toList();

  //   final List<List<Diary?>> diaries = [nullsAll, ...idsAll];

  //   return diaries;
  // }

  // List<String> split(words) {
  //   return Isar.splitWords(words);
  // }

  List<Diary> search(splitWord) {
    return isar.diarys.filter().titleContains(splitWord).findAllSync();
  }

  deleteDiary(Diary diary) {
    isar.writeTxnSync(() {
      isar.diarys.deleteSync(diary.id);
    });
  }

  insertDiary(Diary diary) {
    isar.writeTxnSync(() {
      isar.diarys.putSync(diary);
    });
  }

  updateDiary(Diary diary) {
    isar.writeTxnSync(() {
      isar.diarys.putSync(diary);
    });
  }
}
