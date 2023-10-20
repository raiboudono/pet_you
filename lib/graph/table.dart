import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'package:data_table_2/data_table_2.dart';

import '../features/task/application/task_provider.dart';
import '../features/pet/application/pet_provider.dart';

import '../../../layout/home.dart';

import '../layout/summary.dart';
import 'activity_list.dart';

/*danger:

そーいや
月を変えていった時に1年で一周してしまう
これは全てのグラフに当てはまる
よってカレンダみたいに範囲を用いるような手が必要になる
他に何か手はないか…



 */

final dateTimeController = StateProvider.autoDispose((ref) => DateTime.now());

class Table extends ConsumerWidget {
  const Table({super.key});

  @override
  Widget build(context, ref) {
    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[petIndex];

    final petTaskWorker = ref.watch(taskProvider.notifier);
    final petTaskActivities = petTaskWorker.findActivityAllByPetId(pet.id);

    final categoryId = ref.watch(categoryIdController);

    final now = ref.watch(dateTimeController);

    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final acitivities = petTaskActivities
        .where((activity) => now.year == activity!.createdAt!.year)
        .where((activity) => now.month == activity!.createdAt!.month)
        .where((activity) => activity!.categoryId == categoryId)
        .toList();

    final nameGroup = acitivities
        .groupListsBy((element) => element!.taskName)
        .values
        .toList();

    final uniqueNames = nameGroup
        .map((elements) => elements.map((e) => e!.taskName).toSet().toList())
        .expand((element) => element)
        .toList();

    final isCostDisplay = ref.watch(isCostDisplayProvider);

    final rows = List.generate(uniqueNames.length, (rowIndex) {
      return List.generate(endOfMonth.day + 1, (dayIndex) {
        if (dayIndex == 0) {
          return uniqueNames[rowIndex];
        } else {
          final sameDayGroup = nameGroup[rowIndex]
              .where((activity) => activity?.createdAt?.day == dayIndex)
              .toList();

          int totalAmountPerSameDay = sameDayGroup
              .map((activity) => activity?.amount ?? 0)
              .fold(0, (v1, v2) => v1 + v2);

          int totalCostPerSameDay = sameDayGroup
              .map((activity) => activity?.cost ?? 0)
              .fold(0, (v1, v2) => v1 + v2);

          return isCostDisplay ? totalCostPerSameDay : totalAmountPerSameDay;
        }
      });
    });

    return SizedBox(
      // height: 500,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () {},
          child: ExpansionTile(
            shape: const Border(),
            trailing: const SizedBox(),
            title: Row(children: [
              Container(
                  height: 30,
                  width: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary)),
                  child: Center(
                      child: Text('${now.year}年',
                          style:
                              const TextStyle(fontSize: 14, letterSpacing: 1))))
            ]),
            children: [
              SizedBox(
                  height: 200,
                  child: Builder(
                    builder: (context) {
                      return YearPicker(
                        onChanged: (value) {
                          ref
                              .read(dateTimeController.notifier)
                              .update((state) => value);

                          ExpansionTileController.of(context).collapse();
                        },
                        initialDate: now,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(now.year + 20),
                        selectedDate: now,
                      );
                    },
                  )),
            ],
          ),
        ),
        Container(
          height: rows.isNotEmpty
              ? 100 + (uniqueNames.length * 50)
              : 150 + (uniqueNames.length * 50),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: DataTable2(
              // border: TableBorder(),
              dividerThickness: .1,
              dataRowHeight: 50,
              // dataRowColor: MaterialStateProperty.all(Colors.pink.shade100),
              headingRowColor:
                  MaterialStateProperty.all(Theme.of(context).highlightColor),
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              headingRowHeight: 50,
              fixedCornerColor: Colors.transparent,
              fixedColumnsColor: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(.2),
              showCheckboxColumn: false,
              isHorizontalScrollBarVisible: true,
              isVerticalScrollBarVisible: true,
              // dividerThickness: 1,
              decoration: const BoxDecoration(),
              columnSpacing: 10,
              horizontalMargin: 5,
              minWidth: 2300,
              lmRatio: .5,
              columns: List.generate(endOfMonth.day + 1, (dayIndex) {
                return switch (dayIndex) {
                  0 => DataColumn2(
                        label: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                          if (now.year == 2023 && now.month == 1) return;
                          ref.read(dateTimeController.notifier).update(
                              (state) => DateTime(state.year, state.month - 1));
                        },
                      ),
                      Text('${now.month} 月'),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () {
                          ref.read(dateTimeController.notifier).update(
                              (state) => DateTime(state.year, state.month + 1));
                        },
                      ),
                    ])),
                  _ => DataColumn2(
                      onSort: (a, b) {},
                      label: SizedBox(
                          // color: Colors.yellow,
                          width: 200,
                          child: Text('$dayIndex')),
                      size: ColumnSize.L,
                    )
                };
              }),
              empty: Center(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      // color: Theme.of(context).highlightColor,
                      child: const Text('データがありません'))),
              rows: List<DataRow>.generate(rows.length, (rowIndex) {
                return DataRow(
                    cells: List<DataCell>.generate(rows[rowIndex].length,
                        (celIndex) {
                  return DataCell(
                      onTap: celIndex != 0
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ActivityList(
                                      rows[rowIndex][celIndex] as String?, pet);
                                }),
                              );
                            },
                      Text(rows[rowIndex][celIndex].toString(),
                          maxLines: 1, overflow: TextOverflow.ellipsis));
                }));
              })),
        )
      ]),
    );
  }
}
