import 'package:isar/isar.dart';

import '../../features/pet/model/pet.dart';

class PetRepository {
  PetRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  void insert(Pet pet) {
    isar.writeTxnSync(() => isar.pets.putSync(pet));
  }

  void delete(int petId) {
    isar.writeTxnSync(() => isar.pets.deleteSync(petId));
  }

  void update(Pet pet) {
    isar.writeTxnSync(() => isar.pets.putSync(pet));
  }

  List<Pet?> getPetsAll() => isar.pets.where().findAllSync();

  findPetCategoryIds() {
    return isar.pets.where().categoryIdsProperty().findAllSync();
  }

  findPetTaskIds() {
    return isar.pets.where().taskIdsProperty().findAllSync();
  }
}
