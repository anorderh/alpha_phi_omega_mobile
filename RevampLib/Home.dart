import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../RevampLib/AppData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../RevampLib/Settings.dart';
import 'EventView.dart';
import 'Home_HTTP.dart';
import 'UserData.dart';
import 'Login_HTTP.dart';
import 'Home_Loading.dart';
import 'package:sizer/sizer.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'ErrorHandler.dart';

// HOME WIDGET
class Home extends StatefulWidget {
  final Future<List<String>> content;
  final Maintenance maintenance;

  const Home({required this.content, Key? key, required this.maintenance})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late Future<List<String>> activeContent;
  late PageController pageController;
  late TabController tabController;

  @override
  void initState() {
    activeContent = widget.content;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    pageController = PageController(initialPage: widget.maintenance.homeIndex);
    tabController = TabController(
        initialIndex: widget.maintenance.homeIndex, length: 2, vsync: this);
    widget.maintenance.setRefresh(_refreshContent);

    super.didChangeDependencies();
  }

  void _refreshContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          activeContent =
              scrapeUserContent(MainUser.of(context).data, ignore: true);
          pageController =
              PageController(initialPage: widget.maintenance.homeIndex);
        }));
  }

  Future _refreshScrape() {
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {
        activeContent =
            scrapeUserContent(MainUser.of(context).data, ignore: false);
        pageController =
            PageController(initialPage: widget.maintenance.homeIndex);
      });
    });
  }

  void _promptDialog(String error) {
    if (error == 'http error') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              HTTPRefreshDialog(refreshScrape: _refreshScrape));
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ErrorDialog(title: error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: _refreshScrape,
            child: FutureBuilder<List<String>>(
                future: activeContent,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
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
                      if (snapshot.data!.contains("http error")) {
                        Future.delayed(Duration.zero, () => _promptDialog("http error"));

                      } else if (snapshot.data!.contains("parse error")) {
                        Future.delayed(Duration.zero, () => _promptDialog("Parse error"));

                      } else {
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
                              UserContent(
                                pageC: pageController,
                                tabC: tabController,
                              )
                            ]);
                      }
                    } else {
                      Future.delayed(Duration.zero, () => _promptDialog("Reload error"));
                    }

                    return Container();
                  }
                })));
  }
}

class CheckSettingsButton extends StatelessWidget {
  const CheckSettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 15),
      alignment: Alignment.topLeft,
      child: IconButton(
          onPressed: () {
            pushToNew(context: context, withNavBar: false, page: Settings());
          },
          icon: const Icon(FontAwesomeIcons.bars, color: Colors.black)),
    );
  }
}

// USER HEADER
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

// HOME TAB BAR
class HomeTabBar extends StatefulWidget {
  final TabController controller;
  final Function setIndex;

  const HomeTabBar(this.controller, this.setIndex, {Key? key})
      : super(key: key);

  @override
  _HomeTabBarState createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  @override
  void initState() {
    super.initState();
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
          labelColor: Colors.black,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          indicator: BoxDecoration(
              color: Colors.white,
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
  final PageController pageC;
  final TabController tabC;

  const UserContent({Key? key, required this.pageC, required this.tabC})
      : super(key: key);

  @override
  _UserContentState createState() => _UserContentState();
}

class _UserContentState extends State<UserContent> {
  late UserData user;
  late Maintenance maintenance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    maintenance = MainApp.of(context).maintenance;
    super.didChangeDependencies();
  }

  void setIndex(int newIndex, String input) {
    if (input == "page") {
      widget.tabC.animateTo(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    } else {
      widget.pageC.animateToPage(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    }

    setState(() {
      maintenance.setIndex(newIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("home content built " + DateTime.now().toString());

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        HomeTabBar(widget.tabC, setIndex),
        ExpandablePageView(
          onPageChanged: (pageIndex) {
            if (!widget.tabC.indexIsChanging) {
              setState(() {
                setIndex(pageIndex, "page");
              });
            }
          },
          controller: widget.pageC,
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
  int reqTileHeight = 200; //pixels
  late List<String> reqKeys;

  @override
  void initState() {
    reqKeys = widget.reqs.keys.toList();
    calcReqListHeight();
    super.initState();
  }

  dynamic discernDouble(double input) {
    return input % 1 == 0 ? input.toInt() : input;
  }

  void calcReqListHeight() {
    double temp = ((reqKeys.length / 2) + (reqKeys.length % 2)) *
        (reqTileHeight - 25) *
        1.0;

    if (temp < 350) {
      reqListHeight = 350;
    } else {
      reqListHeight = temp;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reqKeys.length == 0) {
      return Container(
          height: reqListHeight,
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.topCenter,
          child: Text("You currently do not have any requirements.",
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20, fontStyle: FontStyle.italic)));
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
                            .withLightness(0.9)
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
                        alignment: Alignment.centerRight,
                        // widthFactor: 0.95,
                        child: Container(
                          child: Icon(curInfo.icon,
                              size: 75,
                              color: HSLColor.fromColor(curInfo.color)
                                  .withLightness(0.6)
                                  .toColor()),
                          width: 90,
                        ),
                      ),
                    ),
                    left: 78,
                    bottom: 60,
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
                                                          color: Colors.black87,
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
                                                            height: 0.4))
                                                  ]),
                                            ),
                                            Text("CREDITS",
                                                style:
                                                    GoogleFonts.carroisGothic(
                                                        fontSize: 14,
                                                        letterSpacing: -0.25,
                                                        fontWeight:
                                                            FontWeight.bold))
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
                                child: Text(
                                    reqKeys[index].toString().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.carroisGothic(
                                      fontSize: 24,
                                      letterSpacing: -1,
                                      fontWeight: FontWeight.w500,
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

  @override
  void initState() {
    calcEventListHeight();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    DateTime start =
        getNextWeekStart(MainApp.of(context).mainCalendar.activeDate);

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

    if (temp < 350) {
      return 350;
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
          height: calcEventListHeight(),
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.topCenter,
          child: Text("You are currently not signed up for any events.",
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20, fontStyle: FontStyle.italic)));
    } else {
      return Container(
        height: calcEventListHeight(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            splitIndex == 0
                ? Container()
                : UserEventList(
                    label: "This week",
                    events: widget.events.sublist(0, splitIndex)),
            splitIndex == null
                ? Container()
                : UserEventList(
                    label: "Later",
                    events: widget.events
                        .sublist(splitIndex!, widget.events.length))
          ],
        ),
      );
    }
  }
}

class UserEventList extends StatelessWidget {
  final String label;
  final List<EventFull> events;
  double eventTileHeight = 75;

  UserEventList({required this.label, required this.events, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            child: Text(label,
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.black,
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
                      .withLightness(0.6)
                      .toColor(),
                  child: Ink(
                    width: 100.w,
                    height: eventTileHeight,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 3)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: HSLColor.fromColor(info.color)
                            .withLightness(0.9)
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
                                      .withLightness(0.6)
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
                                      color: Colors.black,
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
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        DateFormat.jm().format(event.start!) +
                                            " to",
                                        style: GoogleFonts.carroisGothic(
                                            fontWeight: FontWeight.bold)),
                                    Text(DateFormat.jm().format(event.end!),
                                        style: GoogleFonts.carroisGothic(
                                            fontWeight: FontWeight.bold))
                                  ],
                                )
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
                        page: EventView(event: event, info: info));
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
