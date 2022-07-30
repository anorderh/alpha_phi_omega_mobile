///
/// Inherited widgets & objects for recording App data
///

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Internal/APOM_Objects.dart';

class System extends InheritedWidget {
  final String version;
  final DateTime lastUpdated;
  final DateTime currentDate;
  final ExceptionTracker tracker;

  const System({
    Key? key,
    required this.version,
    required this.lastUpdated,
    required this.currentDate,
    required this.tracker,
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

// Object for storing Calendar values!
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

// Object to store certain system values!
class Maintenance {
  late int homeIndex;
  Function? refreshHome;
  BuildContext? poppableContext;
  String? exceptionMsg;

  Maintenance() {
    resetData();
  }

  void resetData() {
    homeIndex = 0;
    refreshHome = null;
    poppableContext = null;
    exceptionMsg = null;
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

class ExceptionTracker {
  int exceptionStack = 0;
}

// Object to locally store Users' email & password!
class InternalStorage {
  static final storage = FlutterSecureStorage();

  static Future setUsername(String username) async {
    await storage.write(key: 'username', value: username);
  }

  static Future setPassword(String username) async {
    await storage.write(key: 'password', value: username);
  }

  static Future<String?> getUsername() async {
    return await storage.read(key: 'username');
  }

  static Future<String?> getPassword() async {
    return await storage.read(key: 'password');
  }

  static Future<bool> isUserRemembered() async {
    return (await storage.read(key: 'remember user')) == 'yes';
  }

  static Future setRememberUser(bool input) async {
    await storage.write(key: 'remember user', value: input ? 'yes' : 'no');
  }

  static Future clear() async {
    await storage.deleteAll();
  }
}
