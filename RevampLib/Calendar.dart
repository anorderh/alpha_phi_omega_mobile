import 'package:example/EventPage/EventPage.dart';
import 'package:example/RevampLib/Calendar_HTTP.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import '../RevampLib/AppData.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../RevampLib/CalendarHelpers.dart';
import '../RevampLib/UserData.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:sizer/sizer.dart';
import 'ErrorHandler.dart';
import 'package:async/async.dart';

import 'EventView.dart';

class Calendar extends StatefulWidget {
  final DateTime current;

  const Calendar({Key? key, required this.current}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late UserData user;
  late CalendarData mainCalendar;

  late DateTime date;
  late List<DateTime> weeklyDates;

  late TabController _dayController;
  late PageController _pageController;
  late int dayIndex;

  late List<dynamic> weeklyScrapes;

  @override
  void initState() {
    // initializing dates & indexes
    newWeek(widget.current);

    // initializing controllers
    _pageController = PageController(initialPage: dayIndex);
    _dayController =
        TabController(initialIndex: dayIndex, length: 7, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // inherited widgets
    user = MainUser.of(context).data;

    mainCalendar = MainApp.of(context).mainCalendar;
    mainCalendar.setNewAllDayEvents(getAllDayMap(weeklyDates));

    // processing respective weekday
    weeklyScrapes[dayIndex] =
        startEventScrapping(user, mainCalendar, weeklyDates[dayIndex], false);

    super.didChangeDependencies();
  }

  void newWeek(DateTime initialDate) {
    date = initialDate;
    weeklyDates = getWeekDates(date);
    dayIndex = date.weekday - 1;
    weeklyScrapes = List.generate(7, (index) {
      return null;
    });
  }

  void setDay(int newDay) {
    setState(() {
      date = date.add(Duration(days: newDay - dayIndex));
      if (weeklyScrapes[newDay] == null) {
        weeklyScrapes[newDay] =
            startEventScrapping(user, mainCalendar, weeklyDates[newDay], false);
      }

      if ((dayIndex - newDay).abs() > 1) {
        _pageController.jumpToPage(newDay);
      } else {
        _pageController.animateToPage(newDay,
            duration: Duration(milliseconds: 250), curve: Curves.ease);
      }
      _dayController.animateTo(newDay,
          duration: Duration(milliseconds: 250), curve: Curves.ease);

      dayIndex = newDay;
    });
  }

  // callback passed to TabBar to change weeks
  void setWeek(String direction) {
    int offset = 0;
    if (direction == "next") {
      offset += 7;
    } else if (direction == "prev") {
      offset -= 7;
    }

    setState(() {
      newWeek(date.add(Duration(days: offset)));
      mainCalendar.setController(EventController());
      mainCalendar.setNewAllDayEvents(getAllDayMap(weeklyDates));

      weeklyScrapes[dayIndex] =
          startEventScrapping(user, mainCalendar, weeklyDates[dayIndex], false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(Duration(seconds: 1), () {
              setWeek("curr");
            });
          },
          child: Container(
            height: 100.h,
            child: Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("You are viewing",
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        Text(DateFormat.yMMMMd('en_US').format(date),
                            style: GoogleFonts.dmSerifDisplay(fontSize: 32)),
                        CalendarTabBar(
                            current: widget.current,
                            controller: _dayController,
                            setIndex: setDay,
                            setWeek: setWeek,
                            dates: weeklyDates)
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: PageView(
                    onPageChanged: (newDay) {
                      if (!_dayController.indexIsChanging) {
                        setState(() {
                          setDay(newDay);
                        });
                      }
                    },
                    controller: _pageController,
                    children: [
                      CalendarDayView(
                          date: weeklyDates[0],
                          scrape: weeklyScrapes[0] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[1],
                          scrape: weeklyScrapes[1] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[2],
                          scrape: weeklyScrapes[2] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[3],
                          scrape: weeklyScrapes[3] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[4],
                          scrape: weeklyScrapes[4] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[5],
                          scrape: weeklyScrapes[5] ?? Future.value("empty"),
                          refresh: setWeek),
                      CalendarDayView(
                          date: weeklyDates[6],
                          scrape: weeklyScrapes[6] ?? Future.value("empty"),
                          refresh: setWeek)
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class CalendarTabBar extends StatefulWidget {
  final DateTime current;
  final TabController controller;
  final Function setIndex;
  final List<DateTime> dates;
  final Function setWeek;

  const CalendarTabBar(
      {required this.controller,
      required this.setIndex,
      required this.dates,
      Key? key,
      required this.current,
      required this.setWeek})
      : super(key: key);

  @override
  _CalendarTabBarState createState() => _CalendarTabBarState();
}

class _CalendarTabBarState extends State<CalendarTabBar> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool checkToday(DateTime date) {
    if (widget.current.day == date.day &&
        widget.current.month == date.month &&
        widget.current.year == date.year) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 0, right: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: InkWell(
                onTap: () {
                  widget.setWeek("prev"); // go back 1 week
                },
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(FontAwesomeIcons.angleLeft,
                      size: 20, color: Colors.black),
                ),
              ),
            ),
            Container(
              width: 100.w,
              // height: 45,
              child: TabBar(
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.only(left: 5, right: 5),
                indicatorPadding: EdgeInsets.zero,
                // isScrollable: true,
                unselectedLabelColor: Colors.black,
                labelColor: Colors.black,
                indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                        width: 3.0, color: Colors.blue.withOpacity(0.8)),
                    insets:
                        EdgeInsets.symmetric(vertical: -4.0, horizontal: 4.0)),
                controller: widget.controller,
                onTap: (newIndex) {
                  setState(() {
                    widget.setIndex(newIndex);
                  });
                },
                splashBorderRadius: BorderRadius.circular(100),
                tabs: [
                  DayLabel("M", checkToday(widget.dates[0])),
                  DayLabel("T", checkToday(widget.dates[1])),
                  DayLabel("W", checkToday(widget.dates[2])),
                  DayLabel("Th", checkToday(widget.dates[3])),
                  DayLabel("F", checkToday(widget.dates[4])),
                  DayLabel("Sa", checkToday(widget.dates[5])),
                  DayLabel("Su", checkToday(widget.dates[6]))
                ],
              ),
            ),
            Material(
              // borderRadius: BorderRadius.all(Radius.circular(15)),
              child: InkWell(
                onTap: () {
                  widget.setWeek("next"); // go forward 1 week
                },
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(FontAwesomeIcons.angleRight,
                      size: 20, color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DayLabel extends StatelessWidget {
  final String day;
  final bool isToday;

  const DayLabel(this.day, this.isToday, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 24, color: isToday ? Colors.white : Colors.black)),
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
  double HPM = 1.2;

  void _refreshCalendar() {
    widget.refresh("curr");
  }

  void _promptDialog(String error) {
    if (error == 'http error') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              HTTPRefreshDialog(refreshScrape: _refreshCalendar));
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ErrorDialog(title: error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.scrape,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blue,
            ),
          );
        } else {
          if (snapshot.hasData) {
            if (snapshot.data! == "http error") {
              Future.delayed(Duration.zero, () => _promptDialog("http error"));

            } else if (snapshot.data! == "parse error") {
              Future.delayed(Duration.zero, () => _promptDialog("Parse error"));

            } else if (snapshot.data! == "empty") {
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 1), () {
                    widget.refresh("curr");
                  });
                },
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    height: 500,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(15),
                    child: Text(
                        "No events found.\nIf this is an error, swipe up to refresh.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
                  ),
                ),
              );
            } else {
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 1), () {
                    widget.refresh("curr");
                  });
                },
                child: DayView(
                  controller: MainApp.of(context).mainCalendar.eventController,
                  eventTileBuilder: (date, events, bounds, start, end) {
                    Widget timeSubtitle;
                    double allowedLines;
                    int duration = end.difference(start).inMinutes;

                    EventFull curEvent = events[0].event as EventFull;
                    CredInfo credInfo = pullCredInfo(
                        curEvent.cred, MainUser.of(context).data.http.chapter);

                    if (duration < 50) {
                      // check if time will fit in box
                      timeSubtitle = Container();
                      allowedLines = 1.0;
                    } else {
                      if (bounds.width <
                          0.25 * 100.w) {
                        timeSubtitle = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat.jm().format(start).toLowerCase() +
                                " -\n" +
                                DateFormat.jm().format(end).toLowerCase(),
                            style: TextStyle(
                                color: HSLColor.fromColor(credInfo.color)
                                    .withLightness(0.65)
                                    .toColor(),
                                fontSize: 14),
                          ),
                        );
                        allowedLines = (duration - 25) / 25;
                      } else {
                        timeSubtitle = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat.jm().format(start).toLowerCase() +
                                " - " +
                                DateFormat.jm().format(end).toLowerCase(),
                            style: TextStyle(
                                color: HSLColor.fromColor(credInfo.color)
                                    .withLightness(0.65)
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
                              page: EventView(event: curEvent, info: credInfo));
                        },
                        style: ElevatedButton.styleFrom(
                          onPrimary: HSLColor.fromColor(credInfo.color)
                              .withLightness(0.65)
                              .toColor(),
                          elevation: 0.0,
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(5),
                          primary: HSLColor.fromColor(credInfo.color)
                              .withLightness(0.9)
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
                                        color:
                                            HSLColor.fromColor(credInfo.color)
                                                .withLightness(0.65)
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
                                                .withLightness(0.65)
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
                    return AllDayEvents(eventsKey: '${date.month}.${date.day}');
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
                  onEventTap: (events, date) {
                    print("tapped on " + events[0].title);
                  },
                  liveTimeIndicatorSettings:
                      HourIndicatorSettings(color: Colors.red),
                ),
              );
            }
          }
        }
        return Container();
      },
    );
  }
}

class AllDayEvents extends StatefulWidget {
  final String eventsKey;

  const AllDayEvents({required this.eventsKey, Key? key}) : super(key: key);

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

    return Expanded(
      child: ElevatedButton(
          onPressed: () {
            pushToNew(
                context: context,
                withNavBar: true,
                page: EventView(event: event, info: info));
          },
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPrimary:
                HSLColor.fromColor(info.color).withLightness(0.65).toColor(),
            elevation: 0.0,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 5, right: 5),
            primary:
                HSLColor.fromColor(info.color).withLightness(0.9).toColor(),
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
                      .withLightness(0.65)
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
