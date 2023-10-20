import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/work/work.dart';
import 'isar_provider.dart';

// import 'package:isar/isar.dart';

import 'pet/pet_repository.dart';
import 'task/task_repository.dart';
import 'task/priority_task_repository.dart';
import 'category/category_repository.dart';
import 'schedule/schedule_repository.dart';
import 'diary/diary_repository.dart';
import 'folder/folder_repository.dart';
import 'album/album_repository.dart';
import 'setting/setting_repository.dart';

final repositoryProvider = Provider.family<dynamic, Work>((ref, work) {
  final isar = ref.watch(isarProvider);

  return switch (work) {
    Work.pet => PetRepository(isar),
    Work.task => TaskRepository(isar),
    Work.priorityTask => PriorityTaskRepository(isar),
    Work.category => CategoryRepository(isar),
    Work.schedule => ScheduleRepository(isar),
    Work.diary => DiaryRepository(isar),
    Work.folder => FolderRepository(isar),
    Work.album => AlbumRepository(isar),
    Work.setting => SettingRepository(isar),
  };
});
