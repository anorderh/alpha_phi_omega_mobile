///
/// Home tab displaying info, reqs, and events
///

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/Data/Preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Data/AppData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Settings/Settings.dart';
import '../../Internal/APOM_Constants.dart';
import '../../Internal/APOM_Objects.dart';
import '../EventView/EventView.dart';
import 'Home_HTTP.dart';
import '../../Internal/TransitionHandler.dart';
import '../../Data/UserData.dart';
import 'Home_Loading.dart';
import 'package:sizer/sizer.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import '../../Internal/ErrorHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// HOME WIDGET
class Home extends StatefulWidget {
  final Future<List<String>> content;
  final Maintenance maintenance;

  const Home({required this.content, Key? key, required this.maintenance})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<String>> activeContent;

  @override
  void initState() {
    activeContent = widget.content;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Creating new controllers per navBar transition. Indexes are incorrect if not
    widget.maintenance.setRefresh(_refreshContent);

    super.didChangeDependencies();
  }

  // Update events if User joins/leaves one
  void _refreshContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          activeContent =
              scrapeUserContent(MainUser.of(context).data, ignore: true);
        }));
  }

  // Refresh home content
  Future _refreshScrape() {
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {
        activeContent =
            scrapeUserContent(MainUser.of(context).data, ignore: false);
      });
    });
  }

  // Decide error Dialog based on String
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

  // H: Prompting Dialogs - HTTP errors invoke refresh, others logout
  void _promptDialog(String error, String? msg) {
    if (error == 'Unstable network') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              HTTPRefreshDialog(refreshScrape: _refreshScrape));
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ErrorDialog(title: error, exception: msg));
    }
  }

  // H: If ":" present, parse Exception occurred
  int checkForParseError(List<String> responses) {
    for (int i = 0; i < responses.length; i++) {
      if (responses[i].contains(':')) {
        return i;
      }
    }

    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: _refreshScrape,
            child: FutureBuilder<List<String>>(
                future: activeContent.timeout(Duration(seconds: 10),
                    onTimeout: () => ["Unstable network"]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    // Loading screen.
                    return ListView(
                      children: [
                        Container(
                          height: 260,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: LoadingHeader(),
                          ),
                        ),
                        widget.maintenance.homeIndex == 0
                            ? LoadingReqs()
                            : LoadingEvents()
                      ],
                    );
                  } else {
                    if (snapshot.hasData) {
                      // If data not null.
                      // Confirming all data pulled in activeContent is valid.
                      for (String res in snapshot.data!) {
                        if (res != "Success") {
                          decipherError(res);
                          break;
                        }
                      }

                      return ListView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          children: [
                            Container(
                              height: 260,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      // settings Icon button
                                      child: CheckSettingsButton(),
                                    ),
                                    UserHeader(),
                                  ],
                                ),
                              ),
                            ),
                            UserContent()
                          ]);
                    } else {
                      // Data is null, app reloaded incorrectly
                      decipherError("Improper reload");
                    }
                  }
                  return Container();
                })));
  }
}

class CheckSettingsButton extends StatelessWidget {
  CheckSettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 10, top: 15),
        alignment: Alignment.topLeft,
        child: IconButton(
            onPressed: () {
              pushToNew(
                  context: context,
                  withNavBar: false,
                  page: Settings(),
                  transition: "scale");
            },
            icon: Icon(FontAwesomeIcons.bars,
                color: Theme.of(context).iconTheme.color)),
      ),
    );
  }
}

class UserHeader extends StatefulWidget {
  const UserHeader({Key? key}) : super(key: key);

  @override
  _UserHeaderState createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  late UserData user;

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  user.greeting!,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      height: 0.6,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  child: Text(
                user.name!.split(" ")[0],
                style: TextStyle(
                  fontSize: 36,
                ),
              )),
              Container(
                  child: Text(
                user.position!,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.bold),
              ))
            ],
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: CachedNetworkImageProvider(user.pictureURL!),
                    fit: BoxFit.cover)),
          )
        ],
      ),
    );
  }
}

class HomeTabBar extends StatefulWidget {
  final TabController controller;
  final Function setIndex;

  const HomeTabBar(this.controller, this.setIndex, {Key? key})
      : super(key: key);

  @override
  _HomeTabBarState createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5, right: 15, left: 15),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.blue.withOpacity(0.4)),
        child: TabBar(
          padding: EdgeInsets.all(6),
          unselectedLabelColor: Colors.grey,
          labelColor: theme.colorScheme.secondary,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          indicator: BoxDecoration(
              color: theme.primaryColor == Colors.white
                  ? Colors.white
                  : Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.75),
                  spreadRadius: 0,
                  blurRadius: 5,
                )
              ]),
          controller: widget.controller,
          onTap: (newIndex) {
            setState(() {
              widget.setIndex(newIndex, "tab");
            });
          },
          tabs: [
            Text("Requirements",
                style: GoogleFonts.dmSerifDisplay(fontSize: 18)),
            Text("My Events", style: GoogleFonts.dmSerifDisplay(fontSize: 18))
          ],
        ),
      ),
    );
  }
}

class UserContent extends StatefulWidget {
  const UserContent({Key? key}) : super(key: key);

  @override
  _UserContentState createState() => _UserContentState();
}

class _UserContentState extends State<UserContent>
    with SingleTickerProviderStateMixin {
  late UserData user;
  late PageController pageC;
  late TabController tabC;
  SharedPreferences prefs = UserPreferences.prefs;

  @override
  void initState() {
    pageC = PageController(initialPage: prefs.getInt('homeIndex') ?? 0);
    tabC = TabController(
        initialIndex: prefs.getInt('homeIndex') ?? 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    super.didChangeDependencies();
  }

  void setIndex(int newIndex, String input) async {
    await prefs.setInt('homeIndex', newIndex);

    // Check if call came from "page" or "tab". To synch controllers' indices.
    if (input == "page") {
      tabC.animateTo(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    } else {
      pageC.animateToPage(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        HomeTabBar(tabC, setIndex),
        ExpandablePageView(
          onPageChanged: (pageIndex) {
            setState(() {
              setIndex(pageIndex, "page");
            });
          },
          controller: pageC,
          children: [
            UserReqs(reqs: user.reqs),
            UserEvents(events: user.upcomingEvents)
          ],
        )
      ],
    );
  }
}

class UserReqs extends StatefulWidget {
  final Map<String, List<double>> reqs;

  const UserReqs({Key? key, required this.reqs}) : super(key: key);

  @override
  _UserReqsState createState() => _UserReqsState();
}

class _UserReqsState extends State<UserReqs> {
  late double reqListHeight;
  double reqTileHeight = 50.w; //pixels
  late List<String> reqKeys;

  late bool isDark;

  @override
  void initState() {
    reqKeys = widget.reqs.keys.toList();
    calcReqListHeight();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    isDark = Theme.of(context).primaryColor != Colors.white;
    super.didChangeDependencies();
  }

  dynamic discernDouble(double input) {
    return input % 1 == 0 ? input.toInt() : input;
  }

  void calcReqListHeight() {
    double temp =
        ((reqKeys.length / 2) + (reqKeys.length % 2)) * (reqTileHeight * 0.88);

    if (temp < 50.h) {
      reqListHeight = 50.h;
    } else {
      reqListHeight = temp;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reqKeys.isEmpty) {
      return Container(
          alignment: Alignment.topCenter,
          height: reqListHeight,
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Container(
            height: 20.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text("No reqs found.",
                      style: GoogleFonts.dmSerifDisplay(fontSize: 20)),
                ),
                Container(
                  child: Text("If this is an error, swipe up to refresh",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic)),
                )
              ],
            ),
          ));
    } else {
      return Container(
        height: reqListHeight,
        child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            itemCount: reqKeys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 1.1),
            itemBuilder: (context, index) {
              CredInfo curInfo = pullCredInfo(
                  reqKeys[index], MainUser.of(context).data.http.chapter);

              double credFontSize = 60;
              List<double> credValues = widget.reqs[reqKeys[index]]!;
              if (credValues[0] % 1 != 0 || credValues[0] > 10) {
                credFontSize *= 0.5;
              }

              return Stack(
                children: [
                  Container(
                    height: reqTileHeight * 1.0,
                    decoration: BoxDecoration(
                        color: HSLColor.fromColor(curInfo.color)
                            .withLightness(isDark ? 0.4 : 0.9)
                            .toColor(),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            color: HSLColor.fromColor(curInfo.color)
                                .withLightness(0.6)
                                .toColor(),
                            width: 2)),
                  ),
                  Positioned(
                    child: ClipRect(
                      // child #1
                      child: Align(
                        alignment: Alignment.topRight,
                        // widthFactor: 0.95,
                        child: Container(
                          child: Icon(curInfo.icon,
                              size: 75,
                              color: HSLColor.fromColor(curInfo.color)
                                  .withLightness(isDark ? 0.8 : 0.6)
                                  .toColor()),
                          width: 90,
                        ),
                      ),
                    ),
                    top: 15,
                    right: 0,
                  ),
                  SizedBox.expand(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 5, bottom: 10),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                  text: discernDouble(
                                                          credValues[0])
                                                      .toString(),
                                                  style:
                                                      GoogleFonts.carroisGothic(
                                                          fontSize:
                                                              credFontSize,
                                                          color: HSLColor
                                                                  .fromColor(
                                                                      curInfo
                                                                          .color)
                                                              .withLightness(
                                                                  isDark
                                                                      ? 0.9
                                                                      : 0.3)
                                                              .toColor(),
                                                          height: 0.4),
                                                  children: [
                                                    TextSpan(
                                                        text: "/" +
                                                            discernDouble(
                                                                    credValues[
                                                                        1])
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            height: 0.4,
                                                            color: HSLColor
                                                                    .fromColor(
                                                                        curInfo
                                                                            .color)
                                                                .withLightness(
                                                                    isDark
                                                                        ? 0.9
                                                                        : 0.3)
                                                                .toColor()))
                                                  ]),
                                            ),
                                            Text("Credits",
                                                style:
                                                    GoogleFonts.carroisGothic(
                                                        color:
                                                            HSLColor.fromColor(
                                                                    curInfo
                                                                        .color)
                                                                .withLightness(
                                                                    isDark
                                                                        ? 0.9
                                                                        : 0.3)
                                                                .toColor(),
                                                        letterSpacing: -1.2,
                                                        height: 1.2))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(reqKeys[index].toString(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.carroisGothic(
                                      color: HSLColor.fromColor(curInfo.color)
                                          .withLightness(isDark ? 0.9 : 0.3)
                                          .toColor(),
                                      letterSpacing: -1.2,
                                      height: 1.2,
                                      fontSize: 24,
                                    )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
      );
    }
  }
}

class UserEvents extends StatefulWidget {
  final List<EventFull> events;

  const UserEvents({Key? key, required this.events}) : super(key: key);

  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  int? splitIndex;
  int eventTileHeight = 75;

  late ThemeData theme;

  @override
  void initState() {
    calcEventListHeight();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    DateTime start =
        getNextWeekStart(MainApp.of(context).mainCalendar.activeDate);

    // Find index where remaining Events occur next week
    for (int i = 0; i < widget.events.length; i++) {
      if (widget.events[i].date.compareTo(start) >= 0) {
        splitIndex = i;
        break;
      }
    }
    super.didChangeDependencies();
  }

  double calcEventListHeight() {
    double temp = 50 + (eventTileHeight + 12) * widget.events.length * 1.0;

    if (temp < 50.h) {
      return 50.h;
    } else {
      return temp;
    }
  }

  DateTime getNextWeekStart(DateTime input) {
    return input.add(Duration(days: 7 - (input.weekday - 1)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return Container(
          alignment: Alignment.topCenter,
          height: calcEventListHeight(),
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Container(
              height: 20.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("No events found.",
                        style: GoogleFonts.dmSerifDisplay(fontSize: 20)),
                  ),
                  Container(
                    child: Text("If this is an error, swipe up to refresh",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifDisplay(
                            color: Colors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic)),
                  )
                ],
              )));
      ;
    } else {
      return Container(
        height: calcEventListHeight(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            splitIndex == 0 // If 0, all events next week
                ? Container()
                : UserEventList(
                    label: "This week",
                    events: widget.events.sublist(0, splitIndex),
                    theme: theme),
            splitIndex == null // If null, no events next week
                ? Container()
                : UserEventList(
                    label: "Later",
                    events: widget.events
                        .sublist(splitIndex!, widget.events.length),
                    theme: theme,
                  )
          ],
        ),
      );
    }
  }
}

class UserEventList extends StatelessWidget {
  final String label;
  final List<EventFull> events;
  final ThemeData theme;
  double eventTileHeight = 75;

  UserEventList(
      {required this.label,
      required this.events,
      Key? key,
      required this.theme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLight = theme.primaryColor == Colors.white;

    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            child: Text(label,
                style: GoogleFonts.dmSerifDisplay(
                  color: theme.colorScheme.secondary,
                  fontSize: 16,
                )),
            padding: EdgeInsets.only(left: 15, right: 15)),
        Container(
          height: (eventTileHeight + 8) * events.length,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 25, right: 25),
            physics: NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              EventFull event = events[index];
              CredInfo info = pullCredInfo(
                  event.cred, MainUser.of(context).data.http.chapter);
              bool hasTimes = (event.start != null) ? true : false;

              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  splashColor: HSLColor.fromColor(info.color)
                      .withLightness(isLight ? 0.6 : 0.3)
                      .toColor(),
                  child: Ink(
                    width: 100.w,
                    height: eventTileHeight,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(1, 1),
                              color: Colors.grey.shade900.withOpacity(0.3),
                              blurRadius: 5)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: HSLColor.fromColor(info.color)
                            .withLightness(isLight ? 0.9 : 0.4)
                            .toColor()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                            flex: 2,
                            child: Container(
                              // color: Colors.black,
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(info.icon,
                                  size: 30,
                                  color: HSLColor.fromColor(info.color)
                                      .withLightness(isLight ? 0.6 : 0.8)
                                      .toColor()),
                            )),
                        Flexible(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              // color: Colors.white,
                              child: Text(event.title,
                                  style: GoogleFonts.carroisGothic(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center),
                            )),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: hasTimes
                              ? Text(
                                  DateFormat.jm().format(event.start!) +
                                      " to\n" +
                                      DateFormat.jm().format(event.end!),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.carroisGothic(
                                      fontWeight: FontWeight.bold))
                              : Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "N/A",
                                    style: GoogleFonts.carroisGothic(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(weekdayLibrary[event.date.weekday]!,
                                    style: GoogleFonts.carroisGothic(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24)),
                                FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                      DateFormat.yMd().format(event.date),
                                      style: GoogleFonts.carroisGothic(
                                          fontWeight: FontWeight.bold)),
                                )
                              ]),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    pushToNew(
                        context: context,
                        withNavBar: true,
                        page: EventView(event: event, info: info),
                        transition: "scale");
                  },
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}
