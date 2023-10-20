import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';

import '../../pet/model/pet.dart';
import '../../category/model/category.dart';
import '../model/task.dart';
import '../model/task_activity.dart';
import '../../../infra/task/task_repository.dart';

import '../../pet/application/pet_provider.dart';

import '../../category/application/category_provider.dart';

final taskProvider =
    StateNotifierProvider<TaskStateNotifier, List<Task?>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.task));
  return TaskStateNotifier(repository, ref);
});

class TaskStateNotifier extends StateNotifier<List<Task?>> {
  TaskStateNotifier(this._repository, this.ref)
      : super(_repository.getTasksAll());
  final TaskRepository _repository;
  final Ref ref;

  int assignId() => _repository.assignId();

  void saveTask(Category category, Task task) {
    final tasks = _repository.getTasksAll();

    final target = <int>[...category.taskIds];

    if (tasks.isNotEmpty) {
      final tk = tasks.firstWhereOrNull((tk) => tk!.name == task.name);
      if (tk != null) {
        _repository.updateTask(tk.copyWith(visible: true));
        target.add(tk.id);
      } else {
        _repository.insertTask(task);
        final savedTask = _repository
            .getTasksAll()
            .firstWhereOrNull((tk) => tk!.name == task.name);
        target.add(savedTask!.id);

        ref
            .read(categoryProvider.notifier)
            .updateCategory(category.copyWith(taskIds: target));
      }
    } else {
      _repository.insertTask(task);
      final savedTask = _repository
          .getTasksAll()
          .firstWhereOrNull((tk) => tk!.name == task.name);
      target.add(savedTask!.id);
      ref
          .read(categoryProvider.notifier)
          .updateCategory(category.copyWith(taskIds: target));
    }

    state = _repository.getTasksAll();
  }

  void updateTask(Task task) {
    _repository.updateTask(task);
    state = _repository.getTasksAll();
  }

  void removeTask(Task task) {
    _repository.deleteTask(task);
    state = _repository.getTasksAll();
  }

  void saveActivity(TaskActivity activity) {
    _repository.insertActivity(activity);
    state = _repository.getTasksAll();
  }

  void updateActivity(TaskActivity activity) {
    _repository.updateActivity(activity);
    state = _repository.getTasksAll();
  }

  void deleteActivity(TaskActivity activity) {
    _repository.deleteActivity(activity);
    state = _repository.getTasksAll();
  }

  findActivitiesByTaskId(taskId) {
    return _repository.findActivitiesByTaskId(taskId);
  }

  Task? findTaskById(taskId) {
    return _repository.findTaskById(taskId);
  }

  List<TaskActivity?> findActivityAllByPetId(petId) {
    return _repository.findActivityAllByPetId(petId);
  }

  findActivityByPetId(id) {
    return _repository.findActivityByPetId(id);
  }

  List<TaskActivity> findActivityAll() {
    return _repository.findActivityAll();
  }

  addOrRemoveTaskId(Pet pet, int taskId) {
    final target = <int>[...pet.taskIds];

    target.contains(taskId) ? target.remove(taskId) : target.add(taskId);

    ref
        .read(petProvider.notifier)
        .updatePet(pet.copyWith(taskIds: [...target]));
  }
}
