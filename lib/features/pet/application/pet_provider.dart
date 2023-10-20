import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/pet.dart';

import '../../../../constants/work/work.dart';

import '../../../infra/repository_provider.dart';
import '../../../infra/pet/pet_repository.dart';

final petProvider = StateNotifierProvider<PetStateNotifier, List<Pet?>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.pet));
  return PetStateNotifier(repository);
});

class PetStateNotifier extends StateNotifier<List<Pet?>> {
  PetStateNotifier(this._repository) : super(_repository.getPetsAll());
  final PetRepository _repository;

  int assignId() => _repository.assignId();

  bool isExists(int id) =>
      _repository.getPetsAll().where((user) => user!.id == id).isNotEmpty;

  savePet(Pet pet) {
    _repository.insert(pet);
    state = _repository.getPetsAll();
  }

  void updatePet(Pet updatePet) {
    if (!isExists(updatePet.id)) throw Exception('Petが存在しません');

    _repository.update(updatePet);
    state = _repository.getPetsAll();
  }

  void removePet(int petId) {
    if (!isExists(petId)) throw Exception('Petが存在しません');

    _repository.delete(petId);
    state = _repository.getPetsAll();
  }

  Pet? findById(int petId) {
    for (final pet in state) {
      if (pet!.id == petId) return pet;
    }
    return null;
  }

  addOrRemoveCategoryId(Pet pet, int categoryId) {
    final targets = [...pet.categoryIds];

    targets.contains(categoryId)
        ? targets.remove(categoryId)
        : targets.add(categoryId);

    updatePet(pet.copyWith(categoryIds: targets));
  }
}
