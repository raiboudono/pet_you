import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// import '../constants/work/work.dart';
import '../main.dart';

import '../features/pet/model/pet.dart';
import '../features/task/model/task_activity.dart';
import '../features/task/model/task.dart';
import '../features/task/model/priority_task.dart';
import '../features/category/model/category.dart';
import '../features/schedule/model/event.dart';
import '../features/diary/model/diary.dart';
import '../features/folder/model/folder.dart';
import '../features/album/model/media.dart';
import '../features/setting/model/app_setting.dart';

final isarProvider = Provider((ref) {
  final path = ref.watch(pathProvider);
  return Isar.openSync([
    PetSchema,
    CategorySchema,
    TaskSchema,
    PriorityTaskSchema,
    TaskActivitySchema,
    EventSchema,
    DiarySchema,
    FolderSchema,
    MediaSchema,
    AppSettingSchema
  ], name: PetSchema.name, directory: path);
});
