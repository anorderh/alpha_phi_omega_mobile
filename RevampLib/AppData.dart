import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/////////////
// SYSTEM //
/////////////

// system information
String versionNumber = "1.0";
DateTime lastUpdated = DateTime(2022, 6, 29);

CalendarData mainCalendar = CalendarData();

// objects for focusing system calendar
class CalendarData {
  late EventController eventController;
  DateTime currentDate = DateTime(2022, 4, 7, 11, 30);
  late int? monthProcessed;
  late DateTime focusedDate;
  late List<List<EventFull>> allDayEvents;

  CalendarData() {
    resetData();
  }

  void resetData() {
    eventController = EventController();
    focusedDate = currentDate;
    allDayEvents = List.generate(7, (index) {return [];});
    monthProcessed = null;
  }
}

/////////////
// VALUES //
/////////////

String base_url = 'https://www.apoonline.org/alphadelta/memberhome.php';
String profile_action = "action=profile";
String upcomingEvents_action = "action=profile&panel=events";

Map<int, String> weekdayLibrary = {
  1: 'M',
  2: 'T',
  3: 'W',
  4: 'Th',
  5: 'F',
  6: 'Sa',
  7: 'Su'
};

Map<String, CredInfo> reqLibrary = {
  'Service': CredInfo(Colors.red, FontAwesomeIcons.handshakeAngle),
  'Special': CredInfo(Colors.blue, FontAwesomeIcons.star),
  'Fellowship': CredInfo(Colors.green, FontAwesomeIcons.peopleGroup),
  'Leadership': CredInfo(Colors.purple, FontAwesomeIcons.flag),
  'Fundraising': CredInfo(Colors.pink, FontAwesomeIcons.moneyBillWave),
  'Interchapter': CredInfo(Colors.brown, FontAwesomeIcons.car),
  'Philanthropy': CredInfo(Colors.cyan[900]!, FontAwesomeIcons.children),
  'External Relations':
      CredInfo(Colors.deepPurple, FontAwesomeIcons.addressCard),
  'Required': CredInfo(Colors.lime[900]!, FontAwesomeIcons.calendarCheck),
  'Open Forum': CredInfo(Colors.red.shade900, FontAwesomeIcons.comments),
  'Chair': CredInfo(Colors.lightBlueAccent, FontAwesomeIcons.chair),
  'Academic': CredInfo(Colors.pinkAccent, FontAwesomeIcons.graduationCap),
  'Meeting': CredInfo(Colors.orange, FontAwesomeIcons.chalkboardUser)
};

/////////////
// OBJECTS //
/////////////

class CredInfo {
  Color color;
  IconData icon;

  CredInfo(this.color, this.icon);
}

class EventFull extends Comparable<EventFull> {
  String title, link, cred, loc, desc, creator;
  DateTime date;
  DateTime? start, end;
  List<Participant> participants;

  EventFull(
      {required this.title,
      required this.link,
      required this.date,
      this.start,
      this.end,
      this.cred = 'n/a',
      this.loc = 'n/a',
      this.desc = 'n/a',
      this.creator = 'n/a',
      required this.participants});

  @override
  int compareTo(EventFull other) {
    if (date.isAtSameMomentAs(other.date)) {
      // check if both events aren't all-day
      if (start != null && other.start != null) {
        return 0;
      }

      // discern if event times are before & after
      if (start!.isBefore(other.start!)) {
        return -1;
      } else if (start!.isAfter(other.start!)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      // discern if event dates are before or after
      if (date.isBefore(other.date)) {
        return -1;
      } else {
        return 1;
      }
    }
  }
}

class Participant {
  final String name;
  String comment;

  Participant(this.name, [this.comment = 'n/a']);
}

/////////////
// METHODS //
/////////////

CredInfo pullCredInfo(String name) {
  for (MapEntry entry in reqLibrary.entries) {
    if (name.toUpperCase().contains(entry.key.toUpperCase())) {
      return entry.value;
    }
  }

  return CredInfo(Colors.grey.shade500, FontAwesomeIcons.folder);
}

