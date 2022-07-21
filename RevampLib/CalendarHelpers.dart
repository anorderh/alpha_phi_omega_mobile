import 'package:calendar_view/calendar_view.dart';
import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import '../RevampLib/AppData.dart';
import '../RevampLib/UserData.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

List<DateTime> getWeekDates(DateTime currentDate) {
  List<DateTime> dates = [];
  DateTime current =
      currentDate.subtract(Duration(days: (currentDate.weekday - 1)));

  for (int i = 0; i < 7; i++) {
    dates.add(current.add(Duration(days: i)));
  }

  return dates;
}

DateTime getTimeinDateTime(DateTime date, String time) {
  List<String> pieces = time.replaceAll(" ", "").split(':');

  int hour = int.parse(pieces[0]);
  int min = int.parse(pieces[1].substring(0, 2));
  String meridian = pieces[1].substring(pieces[1].length - 2, pieces[1].length);

  if (hour < 12 && meridian.toLowerCase() == "pm".toLowerCase()) {
    hour += 12;
  } else if (hour >= 12 && meridian.toLowerCase() == "am".toLowerCase()) {
    hour -= 12;
  }

  return DateTime(
      date.year, date.month, date.day, hour, min);
}

List<DateTime> deriveTimes(String text) {
  List<String> results = text.split(" at ");
  DateTime date = DateFormat(' MMM d, y').parse(results[0]);
  List<String> split;
  List<DateTime> eventDates = [date];

  if (results.length == 2) {
    // check that event is not all-day and doesn't span multiple days
    split = results[1].split(" to ");

    eventDates.add(getTimeinDateTime(date, split[0]));
    eventDates.add(getTimeinDateTime(date, split[1]));
  }

  return eventDates;
}

void clearController(EventController controller) {
  for (CalendarEventData event in controller.events) {
    controller.remove(event);
  }
}

String deriveGreeting(DateTime date) {
  if (date.hour >= 17 && date.hour < 5) {
    return "Good Evening,";
  } else if (date.hour >= 12 && date.hour < 17) {
    return "Good Afternoon,";
  } else {
    return "Good Morning,";
  }
}

Map<String, List<EventFull>> getAllDayMap(List<DateTime> dates) {
  Map<String, List<EventFull>> allDayEvents = {};

  for (DateTime date in dates) {
    allDayEvents['${date.month}.${date.day}'] = [];
  }
  return allDayEvents;
}

bool isEventAlreadyPresent(List<EventFull> list, String link) {
  for (EventFull entry in list) {
    if (entry.link == link) {
      return true;
    }
  }

  return false;
}
