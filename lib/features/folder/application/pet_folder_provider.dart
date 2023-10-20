import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';
import '../../../infra/folder/folder_repository.dart';
import '../model/folder.dart';

final petFolderProvider =
    StateNotifierProvider.autoDispose<PetFolderStateNotifier, List<Folder>>(
        (ref) {
  final repository = ref.watch(repositoryProvider(Work.folder));
  return PetFolderStateNotifier(repository);
});

class PetFolderStateNotifier extends StateNotifier<List<Folder>> {
  PetFolderStateNotifier(this._repository) : super(_repository.getFoldersAll());
  final FolderRepository _repository;

  sort() {}

  void removeFolder(Folder folder) {
    _repository.deleteFolder(folder);
    state = _repository.getFoldersAll();
  }

  Folder findByName(name) {
    return _repository.findByName(name);
  }

  saveFolder(Folder folder) {
    _repository.insertFolder(folder);
    state = [...state, folder];
  }

  updateFolder(Folder folder) {
    _repository.updateFolder(folder);
    state = _repository.getFoldersAll();
  }
}
