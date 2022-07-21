import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/////////////
// SYSTEM //
/////////////

class System extends InheritedWidget {
  final String version;
  final DateTime lastUpdated;
  final DateTime currentDate;

  const System({
    Key? key,
    required this.version,
    required this.lastUpdated,
    required this.currentDate,
    required Widget child,
  }) : super(key: key, child: child);

  static System of(BuildContext context) {
    final System? result = context.dependOnInheritedWidgetOfExactType<System>();
    assert(result != null, 'No System found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(System oldWidget) {
    return version != oldWidget.version &&
        lastUpdated != oldWidget.lastUpdated &&
        currentDate != oldWidget.currentDate;
  }
}

class MainApp extends InheritedWidget {
  final CalendarData mainCalendar;
  final Maintenance maintenance;

  const MainApp({
    required this.mainCalendar,
    required this.maintenance,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static of(BuildContext context) {
    final MainApp? result =
        context.dependOnInheritedWidgetOfExactType<MainApp>();
    assert(result != null, 'No  found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MainApp oldWidget) {
    return (maintenance != oldWidget.maintenance &&
        mainCalendar != oldWidget.mainCalendar);
  }
}

// object for focusing system calendar

class CalendarData {
  late DateTime activeDate;
  late DateTime focusedDate;

  late EventController eventController;
  int? monthProcessed;
  late Map<String, List<EventFull>> allDayEvents;

  CalendarData(DateTime current) {
    activeDate = current;
    resetData();
  }

  void resetData() {
    eventController = EventController();
    focusedDate = activeDate;
    allDayEvents = {};
    monthProcessed = null;
  }

  void setFocusedDate(DateTime newFocus) {
    focusedDate = newFocus;
  }

  void setController(EventController newController) {
    eventController = newController;
  }

  void setMonthProcessed(int newMonth) {
    monthProcessed = newMonth;
  }

  void setNewAllDayEvents(Map<String, List<EventFull>> newAllDayEvents) {
    allDayEvents = newAllDayEvents;
  }
}

// values & functions to clean system periodically

class Maintenance {
  late int homeIndex;
  Function? refreshHome;
  BuildContext? poppableContext;

  Maintenance() {
    resetData();
  }

  void resetData() {
    homeIndex = 0;
    refreshHome = null;
    poppableContext = null;
  }

  void setIndex(int newIndex) {
    homeIndex = newIndex;
  }

  void setRefresh(Function? newRefresh) {
    refreshHome = newRefresh;
  }

  void setBuildContext(BuildContext? newContext) {
    poppableContext = newContext;
  }
}

/////////////
// VALUES //
/////////////

String profile_action = "action=profile";
String upcomingEvents_action = "action=profile&panel=events";
int refreshDefault = 3;

Map<int, String> weekdayLibrary = {
  1: 'M',
  2: 'T',
  3: 'W',
  4: 'Th',
  5: 'F',
  6: 'Sa',
  7: 'Su'
};

Map<String, Map<String, CredInfo>> chapterLibrary = {
  "Alpha Delta": {
    'Service': CredInfo(Colors.red, FontAwesomeIcons.handshakeAngle),
    'Special': CredInfo(Colors.blue, FontAwesomeIcons.star),
    'Fellowship': CredInfo(Colors.green, FontAwesomeIcons.peopleGroup),
    'Leadership': CredInfo(Colors.purple, FontAwesomeIcons.flag),
    'Fundraising': CredInfo(Colors.pink, FontAwesomeIcons.moneyBillWave),
    'Interchapter': CredInfo(Colors.brown, FontAwesomeIcons.car),
    'Philanthropy':
        CredInfo(Colors.cyanAccent.shade700, FontAwesomeIcons.children),
    'External Relations':
        CredInfo(Colors.deepPurple, FontAwesomeIcons.addressCard),
    'Required': CredInfo(Colors.lime[900]!, FontAwesomeIcons.calendarCheck),
    'Open Forum': CredInfo(Colors.red.shade900, FontAwesomeIcons.comments),
    'Chair': CredInfo(Colors.lightBlueAccent, FontAwesomeIcons.chair),
    'Academic': CredInfo(Colors.pinkAccent, FontAwesomeIcons.graduationCap),
    'Meeting': CredInfo(Colors.orange, FontAwesomeIcons.chalkboardUser),
    'Study': CredInfo(Colors.orangeAccent, FontAwesomeIcons.school)
  },
  "Alpha Beta": {},
};

Map<String, String> greekAlphabet = {
  "Alpha": 'Α',
  "Beta": 'Β',
  "Gamma": 'Γ',
  "Delta": 'Δ',
  'Epsilon': 'Ε',
  'Zeta': 'Ζ',
  'Eta': 'Η',
  'Theta': 'Θ',
  'Iota': 'Ι',
  'Kappa': 'Κ',
  'Lambda': 'Λ',
  'Mu': 'Μ',
  'Nu': 'Ν',
  'Xi': 'Ξ',
  'Omicron': 'Ο',
  'Pi': 'Π',
  'Rho': 'Ρ',
  'Sigma': 'Σ',
  'Tau': 'Τ',
  'Upsilon': 'Υ',
  'Phi': 'Φ',
  'Chi': 'Χ',
  'Psi': 'Ψ',
  'Omega': 'Ω'
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
  String title, link, id, cred, loc, desc, creator;
  DateTime date;
  DateTime? start, end;
  DateTime? lock, close;

  EventFull(
      {required this.title,
      required this.link,
      required this.id,
      required this.date,
      this.start,
      this.end,
      this.lock,
      this.close,
      this.cred = 'n/a',
      this.loc = 'n/a',
      this.desc = 'n/a',
      this.creator = 'n/a'});

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
  String? comment;
  String? number;
  int? canDrive;

  Participant(this.name, [this.comment, this.number, this.canDrive]);
}

/////////////
// METHODS //
/////////////

CredInfo pullCredInfo(String name, String chapter) {
  for (MapEntry entry in chapterLibrary[chapter]!.entries) {
    if (name.toUpperCase().contains(entry.key.toUpperCase())) {
      return entry.value;
    }
  }

  return CredInfo(Colors.grey.shade500, FontAwesomeIcons.folder);
}

void pushToNew(
    {required BuildContext context,
    required bool withNavBar,
    required Widget page}) {
  Navigator.of(context, rootNavigator: !withNavBar)
      .push(MaterialPageRoute(builder: (context) => page));
}
