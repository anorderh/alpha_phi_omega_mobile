import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// void main() async {
//   print(pullDates('Apr 5, 2022 at 3:00pm to 3:50pm'));
// }

List<DateTime> pullDates(String input) {
  List<String> baseDate = input.split('at');
  List<String> dates = baseDate[1].split('to');

  for (int i = 0; i < dates.length; i++) {
    String temp = dates[i].replaceAll(' ', '');

    dates[i] = baseDate[0] + ' ' + temp.toUpperCase();
  }

  return [
    DateFormat('MMM dd, yyyy hh:mmaaa').parse(dates[0]),
    DateFormat('MMM dd, yyyy hh:mmaaa').parse(dates[1])
  ];
}
