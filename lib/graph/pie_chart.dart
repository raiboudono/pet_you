import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart' as fl;

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import '../features/task/application/task_provider.dart';
import '../features/pet/application/pet_provider.dart';
import '../../../layout/home.dart';

import 'table.dart';
import '../layout/summary.dart';

import '../app.dart';

final indexProvider = StateProvider((ref) => -1);

class PieChart extends ConsumerWidget {
  const PieChart({super.key});

  @override
  Widget build(context, ref) {
    // final isTouched = ref.watch(indexProvider);

    final petIndex = ref.watch(petIndexProvider);
    final pets = ref.watch(petProvider).nonNulls.toList();
    final pet = pets[petIndex];

    final petTaskActivities =
        ref.watch(taskProvider.notifier).findActivityAllByPetId(pet.id);

    final now = ref.watch(dateTimeController);

    final categoryId = ref.watch(categoryIdController);

    final acitivities = petTaskActivities
        .where((activity) => now.year == activity!.createdAt!.year)
        .where((activity) => now.month == activity!.createdAt!.month)
        .where((element) => element!.categoryId == categoryId)
        .toList();

    final nameGroup = acitivities
        .groupListsBy((element) => element!.taskName)
        .values
        .toList();

    final uniqueNames = nameGroup
        .map((elements) => elements.map((e) => e!.taskName).toSet().toList())
        .expand((element) => element)
        .toList();

    final colors = [
      Colors.lightBlueAccent,
      Colors.indigo,
      Colors.yellow,
      Colors.pink,
      Colors.green,
      Colors.purple,
      Colors.amber,
      Colors.brown,
      Colors.white24,
      Colors.red,
      Colors.lightGreen,
    ];

    final isCostDisplay = ref.watch(isCostDisplayProvider);

    final totalAmountsOrCostsPerName = uniqueNames.map(
      (name) {
        final sameNameActivities = acitivities.where((acitvity) {
          return acitvity?.taskName == name;
        });

        final sameNameAmounts = sameNameActivities
            .map((sameNameActivity) => sameNameActivity?.amount ?? 0);
        final totalAmount = sameNameAmounts.fold(0, (v1, v2) => v1 + v2);

        final sameNameCosts = sameNameActivities
            .map((sameNameActivity) => sameNameActivity?.cost ?? 0);
        final totalCost = sameNameCosts.fold(0, (v1, v2) => v1 + v2);

        return isCostDisplay ? {name: totalCost} : {name: totalAmount};
      },
    );

    final total = totalAmountsOrCostsPerName.map((entry) {
      return entry.values.first;
    }).fold(0, (v1, v2) => v1 + v2);

    return Column(children: [
      ...totalAmountsOrCostsPerName.mapIndexed(
        (index, entry) {
          // print(entry);
          return SizedBox(
              height: 30,
              child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 150, 5),
                  leading: ColoredBox(
                      color: colors[index % colors.length].withOpacity(.6),
                      child: const SizedBox(height: 30, width: 30)),
                  title: Text(entry.keys.first),
                  trailing: Text('${entry[entry.keys.first]}')));
        },
      ).toList(),
      SizedBox(
        height: 380,
        child: fl.PieChart(
          swapAnimationDuration: const Duration(milliseconds: 500),
          swapAnimationCurve: Curves.ease,
          fl.PieChartData(
            // pieTouchData: PieTouchData(
            //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
            //     // print(event);
            //     print(pieTouchResponse
            //         ?.touchedSection?.touchedSection?.value);
            //     ref.read(indexProvider.notifier).update((state) => -1);
            //   },
            // ),
            // startDegreeOffset: 180,
            borderData: fl.FlBorderData(
              show: false,
            ),
            sectionsSpace: 1,
            centerSpaceRadius: 0,
            sections: [
              ...totalAmountsOrCostsPerName.mapIndexed(
                (index, item) {
                  return fl.PieChartSectionData(
                      title: item.keys.first,
                      titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            if (!ref.watch(themeModeProvider))
                              const Shadow(color: Colors.black, blurRadius: 2)
                          ]),
                      color: colors[index % colors.length].withOpacity(.6),
                      value: item[item.keys.first]?.toDouble(),
                      radius: 125,
                      titlePositionPercentageOffset: 1.05,
                      borderSide: BorderSide(
                        color: ref.watch(themeModeProvider)
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      badgeWidget: Text(total != 0
                          ? '${((item[item.keys.first]! / total) * 100).round()}%'
                          : ''),
                      badgePositionPercentageOffset: .6);
                },
              ).toList()
            ],
          ),
        ),
      ),
    ]);
  }
}
