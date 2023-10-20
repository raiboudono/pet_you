import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futter_you/features/task/ui/task_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:futter_you/features/pet/model/pet.dart';
import 'package:futter_you/features/task/model/task.dart';
import 'package:futter_you/features/task/model/task_activity.dart';

import 'package:mocktail/mocktail.dart';

class MockPet extends Mock implements Pet {}

class MockTask extends Mock implements Task {}

class MockPetTaskActivity extends Mock implements TaskActivity {}

void main() {
  /*
  前提： task_item.dart についての設定
  easy_stepper パッケージ内で InkWell を Material でラップしていないエラーが出るので
  パッケージのコメントアウトおよび、その影響としての高さ変更による 76行目の Column 配下に対して
  SizedBox 等を利用した375の height の設定が必要
   */
  setUp(() async {});
  testWidgets('execute task', (tester) async {
    final pet = MockPet();
    final task = MockTask();
    // final categoryNofiier = MockCategoryTaskStateNotifier();
    /* nullable なプロパティが使用されている場合は null 以外の値を指定しておく必要がある */
    when(() => pet.id).thenReturn(1);
    when(() => task.id).thenReturn(1);
    when(() => task.name).thenReturn('サンプル');
    when(() => task.unit).thenReturn('g');
    when(() => task.categoryId).thenReturn(1);

    await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: TaskItem(pet, task))));

    final direct =
        find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

    expect(direct, findsOneWidget);

    await tester.enterText(direct, '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('20'), findsOneWidget);

    final nextButton = find.widgetWithText(FilledButton, '次へ');
    await tester.tap(nextButton);
    await tester.pump();

    final memo =
        find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

    expect(memo, findsOneWidget);

    await tester.enterText(memo, 'hello');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(find.text('hello'), findsOneWidget);

    expect(memo, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pump();

    final cost =
        find.ancestor(of: find.text(''), matching: find.byType(TextFormField));

    expect(cost, findsOneWidget);

    await tester.enterText(cost, '100');

    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.tap(nextButton);
    await tester.pump();

    expect(find.text('20'), findsOneWidget);

    // expect(find.text('テキストあり'), findsOneWidget);
    // expect(find.text('100'), findsOneWidget);

    expect(find.text('次へ'), findsNothing);
    final submitButton = find.widgetWithText(FilledButton, '登録');
    await tester.tap(submitButton);
    await tester.pump();
  });
}
