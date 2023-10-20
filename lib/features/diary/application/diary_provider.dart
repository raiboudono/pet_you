import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';
import '../../../infra/diary/diary_repository.dart';
import '../model/diary.dart';

final petDiaryProvider =
    StateNotifierProvider.autoDispose<DiaryStateNotifier, List<Diary>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.diary));
  return DiaryStateNotifier(repository);
});

class DiaryStateNotifier extends StateNotifier<List<Diary>> {
  DiaryStateNotifier(this._repository) : super(_repository.getDiarysAll());
  final DiaryRepository _repository;

  int assignId() => _repository.assignId();

  sort() {}

  // List<List<Diary?>> diariesByFolderIds(ids) {
  //   return _repository.diariesByFolderIds(ids);
  // }

  // List<String> splitWords(words) {
  //   return _repository.split(words);
  // }

  List<Diary> search(splitWord) {
    return _repository.search(splitWord);
  }

  void removeDiary(Diary diary) {
    _repository.deleteDiary(diary);
    state = _repository.getDiarysAll();
  }

  saveDiary(Diary diary) {
    _repository.insertDiary(diary);
    state = _repository.getDiarysAll();
  }

  updateDiary(Diary diary) {
    _repository.updateDiary(diary);
    state = _repository.getDiarysAll();
  }
}
