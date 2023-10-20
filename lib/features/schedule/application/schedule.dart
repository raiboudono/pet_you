import 'package:flutter/material.dart';

class Schedule {
  countRemainingWeeks(DateTime start, DateTime end) {
    return DateTimeRange(start: start, end: end).duration.inDays ~/ 7;
  }
}
