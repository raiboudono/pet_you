import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../features/task/model/task_activity.dart';
import '../features/task/model/task.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import '../features/pet/model/pet.dart';

import '../features/task/application/task_provider.dart';

class StackedBar extends ConsumerStatefulWidget {
  const StackedBar(this.pet, this.task, {super.key});
  final Pet pet;
  final Task task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => StackedBarState();
}

class StackedBarState extends ConsumerState<StackedBar> {
  late final ScrollController _controller;
  bool animation = true;

  @override
  void initState() {
    _controller = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now().day;
      _controller.animateTo(today * 25.0,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    });

    bool isSameDay(DateTime? a, DateTime? b) {
      if (a == null || b == null) {
        return false;
      }

      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    final now = DateTime.now();
    final beginOfThisMonth =
        now.copyWith(year: now.year, month: now.month, day: 1);
    final endOfThisMonth =
        now.copyWith(year: now.year, month: now.month + 1, day: 0);

    final List<TaskActivity> activities = ref
        .read(taskProvider.notifier)
        .findActivitiesByTaskId(widget.task.id)
        .where((activity) {
      return activity.petId == widget.pet.id;
    }).toList();

    final sameDayActivitiesList = List.generate(
        endOfThisMonth.day,
        (int index) => activities
            .where((activity) => isSameDay(
                beginOfThisMonth.copyWith(day: index + 1), activity.createdAt))
            .toList());

    final colors = [
      Colors.lightBlueAccent,
      Colors.indigo,
      Colors.yellow,
      Colors.pink,
      Colors.green,
      Colors.purple,
      Colors.lightBlueAccent,
      Colors.indigo,
      Colors.yellow,
      Colors.pink,
      Colors.green,
      Colors.purple,
    ];

    final sameTotals = sameDayActivitiesList.map((sameDayActivity) {
      return sameDayActivity.fold(
          0, (v1, activity) => v1 + (activity.amount ?? 0));
    }).toList();

    final barGroupsList =
        sameDayActivitiesList.mapIndexed((outerIndex, sameDayActivities) {
      var toalAmount = 0;

      return BarChartGroupData(x: outerIndex + 1, barRods: [
        BarChartRodData(
          color: Colors.transparent,
          toY: sameTotals[outerIndex].toDouble(),
          rodStackItems: sameDayActivities.mapIndexed((innerIndex, activity) {
            toalAmount += activity.amount!;

            return animation
                ? BarChartRodStackItem(
                    innerIndex == 0
                        ? 0.toDouble()
                        : toalAmount.toDouble() - activity.amount!.toDouble(),
                    toalAmount.toDouble(),
                    colors[innerIndex % colors.length],
                    // BorderSide(width: 2.1, color: Colors.black)
                  )
                : BarChartRodStackItem(
                    0,
                    0,
                    Colors.transparent,
                  );
          }).toList(),
          borderRadius: BorderRadius.zero,
          width: 20,
        ),
      ]);
    }).toList();

    return SingleChildScrollView(
        controller: _controller,
        padding: const EdgeInsets.only(top: 20, right: 7),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 360),
            child: SizedBox(
                // color: Colors.blue.withOpacity(.05),
                height: 200,
                width: 1160,
                child: AspectRatio(
                    aspectRatio: 1.66,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return BarChart(
                              swapAnimationDuration:
                                  const Duration(milliseconds: 1000),
                              swapAnimationCurve: Curves.linear,
                              BarChartData(
                                  alignment: BarChartAlignment.start,
                                  titlesData: FlTitlesData(
                                      show: true,
                                      topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                        showTitles: false,
                                      )),
                                      rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                        showTitles: false,
                                      )),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget:
                                              (double value, TitleMeta meta) {
                                            final dates = List.generate(
                                                endOfThisMonth.day + 1,
                                                (index) => (index));

                                            final Widget text = Text(
                                              dates[value.toInt()].toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            );

                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: text,
                                            );
                                          },
                                        ),
                                      )),
                                  barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                          tooltipBgColor: Colors.blue,
                                          tooltipPadding:
                                              const EdgeInsets.fromLTRB(
                                                  3, 2, 3, 2),
                                          tooltipMargin: 0,
                                          getTooltipItem: (
                                            BarChartGroupData group,
                                            int groupIndex,
                                            BarChartRodData rod,
                                            int rodIndex,
                                          ) {
                                            return BarTooltipItem(
                                              // '合計'
                                              rod.rodStackItems.isNotEmpty
                                                  ? '合計: ${rod.rodStackItems.last.toY.round()}'
                                                  : '',
                                              // 回毎の数値
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          })),
                                  gridData: FlGridData(
                                    show: true,
                                    checkToShowHorizontalLine: (value) =>
                                        value % 10 == 0,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.blue.withOpacity(0.2),
                                      // strokeWidth: value,
                                      strokeWidth: 1,
                                    ),
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                  ),
                                  borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(width: .1)),
                                  groupsSpace: null,
                                  barGroups: barGroupsList),
                            );
                          },
                        ))))));
  }
}
