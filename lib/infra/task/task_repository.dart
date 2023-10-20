import 'package:isar/isar.dart';

import '../../features/task/model/task_activity.dart';
import '../../features/task/model/task.dart';

class TaskRepository {
  TaskRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  List<Task?> getTasksAll() {
    return isar.tasks.where().findAllSync();
  }

  Task? findTaskById(taskId) {
    return isar.tasks.filter().idEqualTo(taskId).findFirstSync();
  }

  void insertTask(Task task) {
    isar.writeTxnSync(() {
      isar.tasks.putSync(task);
    });
  }

  void updateTask(Task task) {
    isar.writeTxnSync(() {
      isar.tasks.putSync(task);
    });
  }

  void deleteTask(Task task) => updateTask(task.copyWith(visible: false));

  List<Task?> findTasksByCategoryId(categoryId) {
    return isar.tasks.filter().categoryIdEqualTo(categoryId).findAllSync();
  }

  insertActivity(TaskActivity activity) {
    return isar.writeTxnSync(() {
      isar.taskActivitys.putSync(activity);
    });
  }

  updateActivity(TaskActivity activity) {
    isar.writeTxnSync(() {
      isar.taskActivitys.putSync(activity);
    });
  }

  deleteActivity(TaskActivity activity) {
    isar.writeTxnSync(() {
      isar.taskActivitys.deleteSync(activity.id);
    });
  }

  findActivitiesByTaskId(taskId) {
    return isar.taskActivitys.filter().taskIdEqualTo(taskId).findAllSync();
  }

  List<TaskActivity?> findActivityAllByPetId(petId) {
    return isar.taskActivitys.filter().petIdEqualTo(petId).findAllSync();
  }

  findActivityByPetId(petId) {
    return isar.taskActivitys.filter().petIdEqualTo(petId).findFirstSync();
  }

  List<TaskActivity> findActivityAll() {
    return isar.taskActivitys.where().findAllSync();
  }
}
