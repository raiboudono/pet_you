import 'package:isar/isar.dart';

import '../../features/task/model/priority_task.dart';

class PriorityTaskRepository {
  PriorityTaskRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  insertPriorityTask(PriorityTask priorityTask) {
    isar.writeTxnSync(() {
      isar.priorityTasks.putSync(priorityTask);
    });
  }

  updatePriorityTask(PriorityTask priorityTask) {
    isar.writeTxnSync(() {
      isar.priorityTasks.putSync(priorityTask);
    });
  }

  deletePriorityTask(PriorityTask priorityTask) {
    isar.writeTxnSync(() {
      isar.priorityTasks.deleteSync(priorityTask.id);
    });
  }

  // bool priorityTaskExists(PriorityTask priorityTask, petId) {
  //   return isar.priorityTasks
  //       .filter()
  //       .taskIdEqualTo(priorityTask.taskId)
  //       .and()
  //       .petIdEqualTo(petId)
  //       .isNotEmptySync();
  // }

  List<PriorityTask> findPriorityTasksAll() {
    return isar.priorityTasks.where().findAllSync();
  }
}
