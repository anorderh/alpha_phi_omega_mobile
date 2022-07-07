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
import 'package:async/async.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late DateTime date;
  late List<DateTime> weeklyDates;

  late TabController _dayController;
  late PageController _pageController;
  late int dayIndex;

  List<dynamic> weeklyScrapes = List.generate(7, (index) {
    return null;
  });

  @override
  void initState() {
    // TODO: implement initState
    // initializing calendar data
    mainCalendar.resetData();
    date = mainCalendar.currentDate;
    weeklyDates = getWeekDates(date);

    // finding Date index and scrapping accordingly
    dayIndex = date.weekday - 1;
    weeklyScrapes[dayIndex] = startEventScrapping(weeklyDates[dayIndex], false);

    // setting controllers
    _dayController = TabController(length: 7, vsync: this);
    _pageController = PageController(initialPage: dayIndex);
    _dayController.index = dayIndex;

    super.initState();
  }

  void setDay(int newDay) {
    setState(() {
      date = date.add(Duration(days: newDay - dayIndex));
      if (weeklyScrapes[newDay] == null) {
        weeklyScrapes[newDay] = startEventScrapping(weeklyDates[newDay], false);
      }
      ;

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15),
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
                          controller: _dayController,
                          setIndex: setDay,
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
                        scrape: weeklyScrapes[0] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[1],
                        scrape: weeklyScrapes[1] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[2],
                        scrape: weeklyScrapes[2] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[3],
                        scrape: weeklyScrapes[3] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[4],
                        scrape: weeklyScrapes[4] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[5],
                        scrape: weeklyScrapes[5] ?? Future.value(false)),
                    CalendarDayView(
                        date: weeklyDates[6],
                        scrape: weeklyScrapes[6] ?? Future.value(false))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class CalendarTabBar extends StatefulWidget {
  final TabController controller;
  final Function setIndex;
  final List<DateTime> dates;

  const CalendarTabBar(
      {required this.controller,
      required this.setIndex,
      required this.dates,
      Key? key})
      : super(key: key);

  @override
  _CalendarTabBarState createState() => _CalendarTabBarState();
}

class _CalendarTabBarState extends State<CalendarTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 0, left: 35, right: 35),
      // height: 45,
      child: TabBar(
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.only(left: 5, right: 5),
        indicatorPadding: EdgeInsets.zero,
        // isScrollable: true,
        unselectedLabelColor: Colors.black,
        labelColor: Colors.black,
        indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(width: 3.0, color: Colors.blue.withOpacity(0.8)),
            insets: EdgeInsets.symmetric(vertical: -4.0, horizontal: 4.0)),
        controller: widget.controller,
        onTap: (newIndex) {
          setState(() {
            widget.setIndex(newIndex);
          });
        },
        tabs: [
          DayLabel("M", widget.dates[0]),
          DayLabel("T", widget.dates[1]),
          DayLabel("W", widget.dates[2]),
          DayLabel("Th", widget.dates[3]),
          DayLabel("F", widget.dates[4]),
          DayLabel("Sa", widget.dates[5]),
          DayLabel("Su", widget.dates[6])
        ],
      ),
    );
  }
}

class DayLabel extends StatelessWidget {
  final String day;
  final DateTime date;

  const DayLabel(this.day, this.date, {Key? key}) : super(key: key);

  bool compareDateDay() {
    DateTime current = mainCalendar.currentDate;

    if (current.day == date.day &&
        current.month == date.month &&
        current.year == date.year) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = compareDateDay();

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
  final Future<bool> scrape;

  const CalendarDayView({required this.date, required this.scrape, Key? key})
      : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayView> {
  double HPM = 1.2;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
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
          if (snapshot.hasError) {
            // print(snapshot.stackTrace);
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              child: Text("An error occurred. Please refresh or close the app.",
                  style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!) {
              return DayView(
                controller: mainCalendar.eventController,
                eventTileBuilder: (date, events, bounds, start, end) {
                  Widget timeSubtitle;
                  double allowedLines;
                  double maxWidth = (MediaQuery.of(context).size.width * 0.87);
                  int duration = end.difference(start).inMinutes;
                  EventFull curEvent = events[0].event as EventFull;
                  CredInfo credInfo = pullCredInfo(curEvent.cred);

                  if (duration < 50) {
                    // check if time will fit in box
                    timeSubtitle = Container();
                    allowedLines = 1.0;
                  } else {
                    if (bounds.width < 0.25 * maxWidth) {
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
                        print("button pressed");
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            side: BorderSide(
                                color: HSLColor.fromColor(credInfo.color)
                                    .withLightness(0.65)
                                    .toColor(),
                                width: 1)),
                      ),
                      child: Container(
                        child: (duration <= 50 &&
                            bounds.width <
                                0.25 *
                                    (MediaQuery.of(context).size.width *
                                        0.87))
                            ? FittedBox(
                          alignment: Alignment.center,
                          fit: BoxFit.scaleDown,
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.more_horiz,
                                color: HSLColor.fromColor(credInfo.color)
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
                                    color:
                                    HSLColor.fromColor(credInfo.color)
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
                hourIndicatorSettings:
                HourIndicatorSettings(height: 1, color: Colors.grey.shade400),
                minDay: widget.date,
                maxDay: widget.date.add(Duration(seconds: 1)),
                dayTitleBuilder: (date) {
                  return AllDayEvents(weeklyIndex: date.weekday-1);
                },
                timeLineBuilder: (date) {
                  String meridian = date.hour >= 12 ? " PM" : " AM";

                  return Container(
                    alignment: Alignment.topCenter,
                    child: Text(
                        (date.hour > 12.5 ? date.hour - 12 : date.hour)
                            .toString() +
                            meridian,
                        style:
                        TextStyle(height: 0.5, fontWeight: FontWeight.bold)),
                  );
                },
                onEventTap: (events, date) {
                  print("tapped on " + events[0].title);
                },
                liveTimeIndicatorSettings:
                HourIndicatorSettings(color: Colors.red),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text("No events found.",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
              );
            }
          }
        }

        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(5),
          child: Text('State: ${snapshot.connectionState}'),
        );
      },
    );
  }
}

class AllDayEvents extends StatefulWidget {
  final weeklyIndex;

  const AllDayEvents({required this.weeklyIndex, Key? key}) : super(key: key);

  @override
  _AllDayEventsState createState() => _AllDayEventsState();
}

class _AllDayEventsState extends State<AllDayEvents> {
  List<Widget> allDayBlocks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (EventFull event in mainCalendar.allDayEvents[widget.weeklyIndex]) {
      allDayBlocks.add(getChild(event));
    }
  }

  Widget getChild(EventFull event) {
    CredInfo info = pullCredInfo(event.cred);

    return Expanded(
      child: ElevatedButton(
          onPressed: () {
            print("button pressed");
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
          width: MediaQuery.of(context).size.width,
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
