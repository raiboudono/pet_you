import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:futter_you/features/pet/model/pet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:isar/isar.dart';

import 'package:futter_you/infra/pet/pet_repository.dart';

import 'package:futter_you/infra/isar_provider.dart';

class IsarRobot {
  PetRepository petRepository;

  IsarRobot(this.petRepository);

  int assignId() {
    return petRepository.assignId();
  }

  save(Pet pet) {
    petRepository.insert(pet);
  }

  update(Pet pet) {
    petRepository.update(pet);
  }

  delete(int petId) {
    petRepository.delete(petId);
  }

  List<Pet?> getPetsAll() {
    return petRepository.getPetsAll();
  }

  Future<bool> close() async {
    return await petRepository.isar.close();
  }

  isOpen() {
    return petRepository.isar.isOpen;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  setUp(() async {
    final evacuation = HttpOverrides.current;
    HttpOverrides.global = null;

    await Isar.initializeIsarCore(
      download: true,
    );

    HttpOverrides.global = evacuation;
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall message) async {
      return ".";
    });

    container = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(
        Isar.openSync([
          PetSchema,
        ],
            name: 'test',
            directory: (await getApplicationDocumentsDirectory()).path),
      )
    ]);
  });

  tearDown(() async {
    await container.read(isarProvider).close(deleteFromDisk: true);
  });
  group('CRUD', () {
    test('create ⇒ read => update ⇒ delete', () async {
      final robot = IsarRobot(PetRepository(container.read(isarProvider)));
      final now = DateTime.now();

      final newPet = Pet(
          id: robot.assignId(), name: 'sample', createdAt: now, updatedAt: now);

      expect(robot.assignId(), -9223372036854775808);

      robot.save(newPet);

      var pets = robot.getPetsAll().nonNulls;
      expect(pets.length, 1);

      final savedPet = pets.first;

      expect(savedPet.id, 1);
      expect(savedPet.name, 'sample');
      expect(savedPet.createdAt, isNotNull);
      expect(savedPet.updatedAt, isNotNull);
      expect(savedPet.age, isNull);

      final nameChangedPet = savedPet.copyWith(name: 'example');
      robot.update(nameChangedPet);

      final updatedPet = robot.getPetsAll().nonNulls.first;
      expect(updatedPet.name, 'example');

      robot.delete(updatedPet.id);

      expect(robot.getPetsAll().length, 0);
    });

    test('stress save', () async {
      final robot = IsarRobot(PetRepository(container.read(isarProvider)));
      final now = DateTime.now();

      const times = 1000;

      final newPet = Pet(
          id: robot.assignId(), name: 'sample', createdAt: now, updatedAt: now);

      for (int i = 0; i < times; i++) {
        robot.save(newPet);
      }

      var pets = robot.getPetsAll();
      expect(pets.length, times);

      for (final pet in pets) {
        robot.delete(pet!.id);
      }

      pets = robot.getPetsAll();
      expect(pets.length, 0);
    });
  });
}
