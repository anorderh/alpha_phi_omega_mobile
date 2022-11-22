///
/// Calendar tab to view events on www.apoon.org
///

import 'package:flutter/gestures.dart';

import 'Calendar_HTTP.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Data/AppData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'CalendarHelpers.dart';
import '../../Data/UserData.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:sizer/sizer.dart';
import '../../Internal/APOM_Constants.dart';
import '../../Internal/ErrorHandler.dart';
import '../EventView/EventView.dart';
import '../../Internal/TransitionHandler.dart';
import '../../Internal/APOM_Objects.dart';

class Calendar extends StatefulWidget {
  final DateTime current;

  const Calendar({Key? key, required this.current}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  late UserData user;
  late CalendarData mainCalendar;

  late double pageWidth;
  bool endingSwipe = false;

  late DateTime date;
  late List<DateTime> weeklyDates;

  late TabController _dayController;
  late PageController _pageController;
  late int dayIndex;

  late List<dynamic> weeklyScrapes;

  @override
  void initState() {
    date = widget.current;
    dayIndex = date.weekday - 1;
    newWeek(date);

    _dayController =
        TabController(initialIndex: dayIndex, length: 7, vsync: this);
    _pageController = PageController(initialPage: dayIndex);

    _pageController.addListener(_detectOverscroll);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    mainCalendar = MainApp.of(context).mainCalendar;
    mainCalendar.setNewAllDayEvents(getAllDayMap(weeklyDates));

    // Process starting date.
    weeklyScrapes[dayIndex] =
        startEventScrapping(user, mainCalendar, weeklyDates[dayIndex], false);

    super.didChangeDependencies();
  }

  // Update date & controllers and if null, load day's events.
  void setDay(DateTime newDate, String indicator, bool refresh) {
    date = newDate;
    int newIndex = newDate.weekday - 1;

    if (indicator == "page") {
      _dayController.animateTo(newIndex,
          duration: Duration(milliseconds: 200), curve: Curves.ease);
    } else if (indicator == "tab") {
      if ((dayIndex - newIndex.abs() > 1)) {
        _pageController.jumpToPage(newIndex);
      } else {
        _pageController.animateToPage(newIndex,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      }
    } else {
      setState(() {
        _dayController.animateTo(newIndex,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
        _pageController.jumpToPage(newIndex);
      });
    }
    dayIndex = newIndex;

    if (weeklyScrapes[dayIndex] == null) {
      setState(() {
        weeklyScrapes[dayIndex] = startEventScrapping(
            user, mainCalendar, weeklyDates[dayIndex], refresh);
      });
    }
  }

  // Reset week.
  void newWeek(DateTime newDate) {
    weeklyDates = getWeekDates(newDate);
    weeklyScrapes = List.generate(7, (index) {
      return null;
    });
  }

  // Change week.
  void setWeek(DateTime newDate, bool refresh) {
    setState(() {
      newWeek(newDate);
      mainCalendar.setController(EventController());
      mainCalendar.setNewAllDayEvents(getAllDayMap(weeklyDates));
    });

    setDay(newDate, "both", refresh);
  }

  void _detectOverscroll() {
    ScrollPosition pos = _pageController.position;

    if (pos.outOfRange) {
      if (pos.pixels < pos.viewportDimension * (-0.15)) {
        setWeek(date.add(Duration(days: -1)), false);
      } else if (pos.pixels > pos.viewportDimension * 6.15) {
        setWeek(date.add(Duration(days: 1)), false);
      }
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Flexible(
                fit: FlexFit.loose,
                flex: 2,
                child: CalendarOverhead(
                  date: date,
                  controller: _dayController,
                  setDay: setDay,
                  setWeek: setWeek,
                  weeklyDates: weeklyDates,
                )),
            Flexible(
              flex: 7,
              child: SafeArea(
                bottom: false,
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  onPageChanged: (newDay) {
                    if (!_dayController.indexIsChanging) {
                      setDay(date.add(Duration(days: newDay - dayIndex)),
                          "page", false);
                    }
                  },
                  controller: _pageController,
                  children: [
                    CalendarDayView(
                        date: weeklyDates[0],
                        scrape: weeklyScrapes[0] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[1],
                        scrape: weeklyScrapes[1] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[2],
                        scrape: weeklyScrapes[2] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[3],
                        scrape: weeklyScrapes[3] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[4],
                        scrape: weeklyScrapes[4] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[5],
                        scrape: weeklyScrapes[5] ?? Future.value("null"),
                        refresh: setWeek),
                    CalendarDayView(
                        date: weeklyDates[6],
                        scrape: weeklyScrapes[6] ?? Future.value("null"),
                        refresh: setWeek),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CalendarOverhead extends StatefulWidget {
  DateTime date;
  final TabController controller;
  final Function setDay;
  final Function setWeek;
  final List<DateTime> weeklyDates;

  CalendarOverhead(
      {Key? key,
      required this.date,
      required this.controller,
      required this.setDay,
      required this.setWeek,
      required this.weeklyDates})
      : super(key: key);

  @override
  _CalendarOverheadState createState() => _CalendarOverheadState();
}

class _CalendarOverheadState extends State<CalendarOverhead> {
  late int index;
  late DateTime today;
  bool updating = false;

  @override
  void initState() {
    index = widget.controller.index;
    today = DateTime.now();

    widget.controller.addListener(updateDate);
    super.initState();
  }

  // Controller Listener, updates date per index change.
  void updateDate() {
    if (widget.controller.indexIsChanging) {
      setState(() {
        widget.date =
            widget.date.add(Duration(days: widget.controller.index - index));
        index = widget.controller.index;
      });
    }
  }

  bool checkToday(DateTime date) {
    if (today.day == date.day &&
        today.month == date.month &&
        today.year == date.year) {
      return true;
    }
    return false;
  }

  void _changeWeek(String direction) {
    if (direction == "next") {
      widget.date = widget.date.add(Duration(days: 7));
    } else {
      widget.date = widget.date.add(Duration(days: -7));
    }

    widget.setWeek(widget.date, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("You are viewing",
            style: GoogleFonts.dmSerifDisplay(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(DateFormat.yMMMMd('en_US').format(widget.date),
            style: GoogleFonts.dmSerifDisplay(fontSize: 32)),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 0, right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        _changeWeek("prev");
                      },
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(FontAwesomeIcons.angleLeft, size: 20),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100.w,
                  child: TabBar(
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.only(left: 5, right: 5),
                    indicatorPadding: EdgeInsets.zero,
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.black,
                    indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                            width: 3.0, color: Colors.blue.withOpacity(0.8)),
                        insets: EdgeInsets.symmetric(
                            vertical: -4.0, horizontal: 4.0)),
                    controller: widget.controller,
                    onTap: (newDay) {
                      widget.setDay(
                          widget.date.add(Duration(days: newDay - index)),
                          "tab",
                          false);
                    },
                    splashBorderRadius: BorderRadius.circular(100),
                    tabs: [
                      DayLabel("M", checkToday(widget.weeklyDates[0])),
                      DayLabel("T", checkToday(widget.weeklyDates[1])),
                      DayLabel("W", checkToday(widget.weeklyDates[2])),
                      DayLabel("Th", checkToday(widget.weeklyDates[3])),
                      DayLabel("F", checkToday(widget.weeklyDates[4])),
                      DayLabel("Sa", checkToday(widget.weeklyDates[5])),
                      DayLabel("Su", checkToday(widget.weeklyDates[6]))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        _changeWeek("next");
                      },
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(FontAwesomeIcons.angleRight, size: 20),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class DayLabel extends StatelessWidget {
  final String day;
  final bool isToday;

  const DayLabel(this.day, this.isToday, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: isToday ? Colors.blue : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: isToday
                      ? Colors.blue.withOpacity(0.75)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 10)
            ]),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(day,
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28, color: isToday ? Colors.white : Colors.black)),
        ));
  }
}

class CalendarDayView extends StatefulWidget {
  final DateTime date;
  final Future<String> scrape;
  final Function refresh;

  const CalendarDayView(
      {required this.date,
      required this.scrape,
      Key? key,
      required this.refresh})
      : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayView> {
  double HPM = 1.2; // Height per minute.
  late ThemeData theme;

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    super.didChangeDependencies();
  }

  Future _refreshCalendar() {
    return Future.delayed(Duration(seconds: 1), () {
      widget.refresh(widget.date, true);
    });
  }

  // Decide error Dialog based on String.
  void decipherError(String error) {
    switch (error) {
      case "Unstable network":
        Future.delayed(
            Duration.zero, () => _promptDialog("Unstable network", null));
        break;
      case "Not recognized":
        Future.delayed(Duration.zero,
            () => _promptDialog("Auth. error", "Not recognized"));
        break;
      default:
        Future.delayed(
            Duration.zero, () => _promptDialog("Parse error", error));
    }
  }

  void _promptDialog(String error, String? msg) {
    if (error == 'Unstable network') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              HTTPRefreshDialog(refreshScrape: _refreshCalendar));
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ErrorDialog(
                title: error,
                exception: msg,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.scrape
          .timeout(Duration(seconds: 10), onTimeout: () => "Unstable network"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          // Loading screen.
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blue,
            ),
          );
        } else {
          if (snapshot.hasData) {
            // Data is not null
            // String "null", when Page hasn't ever been viewed
            if (snapshot.data! == "null") {
              return Container();
            } else if (snapshot.data! == "empty") {
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: _refreshCalendar,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    height: 500,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No events found.",
                            style: GoogleFonts.dmSerifDisplay(fontSize: 20)),
                        Text("If this is an error, swipe up to refresh.",
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic))
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.data! == "success") {
              bool isDark = theme.primaryColor != Colors.white;

              // Events found
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: _refreshCalendar,
                child: DayView(
                  backgroundColor: Colors.transparent,
                  controller: MainApp.of(context).mainCalendar.eventController,
                  eventTileBuilder: (date, events, bounds, start, end) {
                    Widget timeSubtitle;
                    double allowedLines;
                    int duration = end.difference(start).inMinutes;

                    EventFull curEvent = events[0].event as EventFull;
                    CredInfo credInfo = pullCredInfo(
                        curEvent.cred, MainUser.of(context).data.http.chapter);

                    // Formatting event box's content to ensure it fits
                    if (duration < 55) {
                      timeSubtitle = Container();
                      allowedLines = 1.0;
                    } else {
                      if (bounds.width < 0.25 * 100.w) {
                        timeSubtitle = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat.jm().format(start).toLowerCase() +
                                " -\n" +
                                DateFormat.jm().format(end).toLowerCase(),
                            style: TextStyle(
                                color: HSLColor.fromColor(credInfo.color)
                                    .withLightness(isDark ? 0.9 : 0.65)
                                    .toColor(),
                                fontSize: 14),
                          ),
                        );
                        allowedLines = (duration - 30) / 25;
                      } else {
                        timeSubtitle = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat.jm().format(start).toLowerCase() +
                                " - " +
                                DateFormat.jm().format(end).toLowerCase(),
                            style: TextStyle(
                                color: HSLColor.fromColor(credInfo.color)
                                    .withLightness(isDark ? 0.9 : 0.65)
                                    .toColor(),
                                fontSize: 14),
                          ),
                        );

                        allowedLines = (duration - 20) / 25;
                      }
                    }

                    return ElevatedButton(
                        onPressed: () {
                          pushToNew(
                              context: context,
                              withNavBar: true,
                              page: EventView(event: curEvent, info: credInfo),
                              transition: "scale");
                        },
                        style: ElevatedButton.styleFrom(
                          onPrimary: HSLColor.fromColor(credInfo.color)
                              .withLightness(isDark ? 0.9 : 0.65)
                              .toColor(),
                          elevation: 0.0,
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(5),
                          primary: HSLColor.fromColor(credInfo.color)
                              .withLightness(isDark ? 0.4 : 0.9)
                              .toColor(),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              side: BorderSide(
                                  color: HSLColor.fromColor(credInfo.color)
                                      .withLightness(0.65)
                                      .toColor(),
                                  width: 1)),
                        ),
                        child: Container(
                          child: (duration < 55 &&
                                  bounds.width < (0.25 * 100.w))
                              ? FittedBox(
                                  alignment: Alignment.center,
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.more_horiz,
                                        color: HSLColor.fromColor(
                                                credInfo.color)
                                            .withLightness(isDark ? 0.9 : 0.65)
                                            .toColor(),
                                        size: 36),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        events[0].title,
                                        softWrap: false,
                                        style: TextStyle(
                                            color: HSLColor.fromColor(
                                                    credInfo.color)
                                                .withLightness(
                                                    isDark ? 0.9 : 0.65)
                                                .toColor(),
                                            fontSize: 16),
                                        maxLines: allowedLines.toInt(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    timeSubtitle
                                  ],
                                ),
                        ));
                  },
                  scrollOffset: 400,
                  heightPerMinute: HPM,
                  hourIndicatorSettings: HourIndicatorSettings(
                      height: 1, color: Colors.grey.shade400),
                  minDay: widget.date,
                  maxDay: widget.date.add(Duration(seconds: 1)),
                  dayTitleBuilder: (date) {
                    // All day block.
                    return AllDayEvents(
                        eventsKey: '${date.month}.${date.day}', theme: theme);
                  },
                  timeLineBuilder: (date) {
                    String meridian = date.hour >= 12 ? " PM" : " AM";

                    return Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                          (date.hour > 12.5 ? date.hour - 12 : date.hour)
                                  .toString() +
                              meridian,
                          style: TextStyle(
                              height: 0.5, fontWeight: FontWeight.bold)),
                    );
                  },
                  liveTimeIndicatorSettings:
                      HourIndicatorSettings(color: Colors.red),
                ),
              );
            }
          }
          // Data is null
          decipherError("Improper reload");
          return Container();
        }
      },
    );
  }
}

class AllDayEvents extends StatefulWidget {
  final String eventsKey;
  final ThemeData theme;

  const AllDayEvents({required this.eventsKey, Key? key, required this.theme})
      : super(key: key);

  @override
  _AllDayEventsState createState() => _AllDayEventsState();
}

class _AllDayEventsState extends State<AllDayEvents> {
  List<Widget> allDayBlocks = [];

  @override
  void didChangeDependencies() {
    for (EventFull event
        in MainApp.of(context).mainCalendar.allDayEvents[widget.eventsKey]) {
      allDayBlocks.add(getChild(event));
    }
    super.didChangeDependencies();
  }

  Widget getChild(EventFull event) {
    CredInfo info =
        pullCredInfo(event.cred, MainUser.of(context).data.http.chapter);
    bool isDark = widget.theme.primaryColor != Colors.white;

    return Expanded(
      child: ElevatedButton(
          onPressed: () {
            pushToNew(
                context: context,
                withNavBar: true,
                page: EventView(event: event, info: info),
                transition: "scale");
          },
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPrimary: HSLColor.fromColor(info.color)
                .withLightness(isDark ? 0.9 : 0.65)
                .toColor(),
            elevation: 0.0,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 5, right: 5),
            primary: HSLColor.fromColor(info.color)
                .withLightness(isDark ? 0.4 : 0.9)
                .toColor(),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(
                    color: HSLColor.fromColor(info.color)
                        .withLightness(0.65)
                        .toColor(),
                    width: 1)),
          ),
          child: Container(
            child: Text(
              event.title,
              softWrap: false,
              style: TextStyle(
                  color: HSLColor.fromColor(info.color)
                      .withLightness(isDark ? 0.9 : 0.65)
                      .toColor(),
                  fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allDayBlocks.isEmpty) {
      return Container();
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
              top: BorderSide(width: 1, color: Colors.grey)),
        ),
        child: Container(
          width: 100.w,
          child: Row(
            children: [
              Flexible(
                  fit: FlexFit.tight,
                  flex: 13,
                  child: Container(
                    // color: Colors.blue,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    alignment: Alignment.bottomCenter,
                    child: Text("All Day",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              Flexible(
                  flex: 73,
                  child: Container(
                    padding: EdgeInsets.only(top: 1, bottom: 1),
                    child: Row(
                      children: allDayBlocks,
                    ),
                  ))
            ],
          ),
        ),
      );
    }
  }
}
