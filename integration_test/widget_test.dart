// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
// import 'dart:io';
// import 'package:isar/isar.dart';

// import 'package:futter_you/features/task/ui/task_item.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:futter_you/features/pet/model/pet.dart';
// import 'package:futter_you/features/task/model/task.dart';
// import 'package:futter_you/features/task/model/task_activity.dart';

// import 'package:mocktail/mocktail.dart';

// import 'package:futter_you/infra/isar_provider.dart';
// import 'package:futter_you/infra/pet/pet_repository.dart';
// import 'package:futter_you/infra/task/task_repository.dart';

// class MockPet extends Mock implements Pet {}

// class MockTask extends Mock implements Task {}

// class MockPetTaskActivity extends Mock implements TaskActivity {}

// class IsarRobot {
//   PetRepository petRepository;
//   TaskRepository taskRepository;

//   IsarRobot(this.petRepository, this.taskRepository);

//   int assignId() {
//     return petRepository.assignId();
//   }

//   savePet(Pet pet) {
//     petRepository.insert(pet);
//   }

//   saveTask(Task task) {
//     taskRepository.insertTask(task);
//   }

//   List<Pet?> getPetsAll() {
//     return petRepository.getPetsAll();
//   }

//   List<Task?> getTasksAll() {
//     return taskRepository.getTasksAll();
//   }
// }

// void main() {
//   /*
//   前提： task_item.dart についての設定
//   easy_stepper パッケージ内で InkWell を Material でラップしていないエラーが出るので
//   パッケージのコメントアウトおよび、その影響としての高さ変更による 76行目の Column 配下に対して
//   SizedBox 等を利用した375の height の設定が必要
//    */

//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//   late ProviderContainer container;
//   setUp(() async {
//     final evacuation = HttpOverrides.current;
//     HttpOverrides.global = null;

//     await Isar.initializeIsarCore(
//       download: true,
//     );

//     HttpOverrides.global = evacuation;
//     const MethodChannel channel =
//         MethodChannel('plugins.flutter.io/path_provider');

//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//         .setMockMethodCallHandler(channel, (MethodCall message) async {
//       return ".";
//     });

//     container = ProviderContainer(overrides: [
//       isarProvider.overrideWithValue(
//         Isar.openSync([PetSchema, TaskSchema],
//             name: 'integrationtest',
//             directory: (await getApplicationDocumentsDirectory()).path),
//       )
//     ]);
//   });
//   testWidgets('execute task', (tester) async {
//     final robot = IsarRobot(PetRepository(container.read(isarProvider)),
//         TaskRepository(container.read(isarProvider)));
//     final now = DateTime.now();

//     // final pet = MockPet();
//     // final task = MockTask();

//     final newPet =
//         Pet(id: robot.assignId(), name: 'pet', createdAt: now, updatedAt: now);
//     robot.savePet(newPet);

//     final newTask =
//         Task(id: robot.assignId(), name: 'task', unit: 'g', categoryId: 1);

//     robot.saveTask(newTask);

//     final pet = robot.getPetsAll().first!;
//     final task = robot.getTasksAll().first!;

//     // final categoryNofiier = MockCategoryTaskStateNotifier();
//     /* nullable なプロパティが使用されている場合は null 以外の値を指定しておく必要がある */
//     // when(() => pet.id).thenReturn(1);
//     // when(() => task.id).thenReturn(1);
//     // when(() => task.name).thenReturn('サンプル');
//     // when(() => task.unit).thenReturn('g');
//     // when(() => task.categoryId).thenReturn(1);

//     await tester.pumpWidget(
//         ProviderScope(child: MaterialApp(home: TaskItem(pet, task))));
//     // await tester
//     //     .pumpWidget(ProviderScope(child: MaterialApp(home: Container())));

//     // final direct =
//     //     find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

//     // expect(direct, findsOneWidget);

//     // await tester.enterText(direct, '20');
//     // await tester.testTextInput.receiveAction(TextInputAction.done);
//     // await tester.pump();

//     // expect(find.text('20'), findsOneWidget);

//     // final nextButton = find.widgetWithText(FilledButton, '次へ');
//     // await tester.tap(nextButton);
//     // await tester.pump();

//     // final memo =
//     //     find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

//     // expect(memo, findsOneWidget);

//     // await tester.enterText(memo, 'hello');
//     // await tester.testTextInput.receiveAction(TextInputAction.done);
//     // expect(find.text('hello'), findsOneWidget);

//     // expect(memo, findsOneWidget);

//     // await tester.tap(nextButton);
//     // await tester.pump();

//     // final cost =
//     //     find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

//     // expect(cost, findsOneWidget);

//     // await tester.enterText(cost, '100');

//     // await tester.testTextInput.receiveAction(TextInputAction.done);

//     // await tester.tap(nextButton);
//     // await tester.pump();

//     // expect(find.text('20'), findsOneWidget);

//     // // expect(find.text('テキストあり'), findsOneWidget);
//     // // expect(find.text('100'), findsOneWidget);

//     // expect(find.text('次へ'), findsNothing);
//     // final submitButton = find.widgetWithText(FilledButton, '登録');
//     // await tester.tap(submitButton);
//     // await tester.pump();
//   });
// }
