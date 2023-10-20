import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../features/pet/model/pet.dart';
import '../features/task/model/task.dart';

import '../features/task/application/task_provider.dart';

// import '../features/task/ui/task_item.dart';

class Line extends ConsumerStatefulWidget {
  const Line(this.pet, this.task, {super.key});
  final Pet pet;
  final Task task;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => LineState();
}

class LineState extends ConsumerState<Line> {
  late final ScrollController _controller;

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
    // ref.listen(executedActivity, (previous, next) {
    //   _controller.animateTo(next!.createdAt!.day * 30.0,
    //       duration: const Duration(milliseconds: 200), curve: Curves.linear);
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now().day;
      if (7 < today) {
        _controller.animateTo(today * 18.0,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    });

    final activities = ref
        .read(taskProvider.notifier)
        .findActivitiesByTaskId(widget.task.id)
        .where((activity) {
      return activity.petId == widget.pet.id;
    }).toList();

    final now = DateTime.now();
    final beginOfThisMonth =
        now.copyWith(year: now.year, month: now.month, day: 1);
    final endOfThisMonth =
        now.copyWith(year: now.year, month: now.month + 1, day: 0);

    bool isSameDay(DateTime? a, DateTime? b) {
      if (a == null || b == null) {
        return false;
      }

      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    final flSpotList = List.generate(endOfThisMonth.day, (index) {
      if (activities.any((activity) => isSameDay(
          beginOfThisMonth.copyWith(day: index + 1), activity.createdAt))) {
        final activity = activities.firstWhere((activity) =>
            isSameDay(beginOfThisMonth.copyWith(day: index + 1),
                activity.createdAt) &&
            activity.amount != null);

        return FlSpot((index + 1).toDouble(), activity.amount.toDouble());
      }
      return FlSpot((index + 1).toDouble(), 0.toDouble());
    });

    // print(flSpotList);

    /*

    danger:
    タスク実行時はその日にスクロール
    初回スクロールと同様日付×15
    タスクアイテムを実行するとリビルドするので
    タスクアイテムにプロバイダを設置し、実行後に代入
    プロバイダをリスンし、発火したら代入された値でスクロール
    試したが上記と重複する


     */

    return SingleChildScrollView(
        controller: _controller,
        padding: const EdgeInsets.only(top: 20, right: 7),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 360),
            child: SizedBox(
                height: 180,
                width: 900,
                child: LineChart(
                  swapAnimationDuration: const Duration(milliseconds: 1000),
                  swapAnimationCurve: Curves.linear,
                  LineChartData(
                    minY: 0.0,
                    // maxY: 50.0,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                          showOnTopOfTheChartBoxArea: true,
                          tooltipMargin: 0,
                          tooltipPadding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 4)),
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent) {
                          if (response != null &&
                              response.lineBarSpots != null) {
                            // Offset(203.8, 87.4)
                            // print(event.localPosition);
                            // TouchLineBarSpot(LineChartBarData([(1.0, 10.0)
                            // print(response.lineBarSpots!.first.spotIndex);
                          }
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30.0,
                      )),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28.0,
                        interval: 1,
                      )),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                          barWidth: 1.3,
                          dotData: FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              // RenderBox box = globalKey.currentContext!
                              //     .findRenderObject() as RenderBox;
                              // print(box.size);
                              // print(box.localToGlobal((Offset.zero)));

                              // print('-----');
                              // print(barData.spots);
                              // print(spot.props.first);
                              // print(percent);
                              // print(barData);
                              // if ((index + 1) == now.day) {
                              //   print('today!!');
                              //   final todaySpot = flSpotList[index];
                              //   print(todaySpot.x);
                              //   // print(barData);
                              // }

                              return FlDotCirclePainter(
                                radius: 1.5,
                                color: Colors.blue,
                                strokeWidth: 2.0,
                                strokeColor: Colors.blue.withOpacity(.5),
                              );
                            },
                          ),
                          spots: [
                            // FlSpot.zero,
                            // FlSpot.nullSpot,
                            ...flSpotList
                          ])
                    ],
                  ),
                ))));
  }
}
