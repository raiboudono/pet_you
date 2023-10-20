import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/task/priority_task_repository.dart';
import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';
import '../model/priority_task.dart';

final priorityTaskProvider = StateNotifierProvider.autoDispose<
    PriorityTaskStateNotifier, List<PriorityTask?>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.priorityTask));
  return PriorityTaskStateNotifier(repository, ref);
});

class PriorityTaskStateNotifier extends StateNotifier<List<PriorityTask?>> {
  PriorityTaskStateNotifier(this._repository, this.ref)
      : super(_repository.findPriorityTasksAll());
  final PriorityTaskRepository _repository;
  final Ref ref;

  int assignId() => _repository.assignId();

  void updateAll(List<PriorityTask> priorityTasks) {
    state = [...priorityTasks];
  }

  void addPriorityTask(PriorityTask priorityTask) {
    state = [...state, priorityTask];
  }

  void removePriorityTask(PriorityTask priorityTask) {
    state = state.where((pt) => pt!.taskId != priorityTask.taskId).toList();
  }

  void savePriorityTask(PriorityTask priorityTask) {
    _repository.insertPriorityTask(priorityTask);
    state = _repository.findPriorityTasksAll();
  }

  void updatePriorityTask(PriorityTask priorityTask) {
    _repository.updatePriorityTask(priorityTask);
    state = _repository.findPriorityTasksAll();
  }

  void deletePriorityTask(PriorityTask priorityTask) {
    _repository.deletePriorityTask(priorityTask);
    state = _repository.findPriorityTasksAll();
  }

  List<PriorityTask> findPriorityTasksAll() {
    return _repository.findPriorityTasksAll();
  }
}
