import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import '../RevampLib/AppData.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';
import '../RevampLib/AppData.dart';
import '../RevampLib/Settings.dart';
import 'UserData.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import '../RevampLib/Home_HTTP.dart';

// HOME WIDGET
class Home extends StatefulWidget {
  final Future<bool> info;
  final Future<bool> content;

  const Home({required this.info, required this.content, Key? key})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int homeIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: ListView(physics: ClampingScrollPhysics(), children: [
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
                  UserHeader(scrape: widget.info),
                ],
              ),
            ),
          ),
          UserContent(scrape: widget.content)
        ]));
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Settings()));
          },
          icon: const Icon(FontAwesomeIcons.bars, color: Colors.black)),
    );
  }
}

// USER HEADER
class UserHeader extends StatefulWidget {
  final Future<bool> scrape;

  const UserHeader({required this.scrape, Key? key}) : super(key: key);

  @override
  _UserHeaderState createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: widget.scrape,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.blue,
                ),
              ),
            );
          } else {
            if (snapshot.hasData) {
              if (snapshot.data!) {
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
                              mainUser.greeting!,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  height: 0.6,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              child: Text(
                            mainUser.name!.split(" ")[0],
                            style: TextStyle(
                              fontSize: 36,
                            ),
                          )),
                          Container(
                              child: Text(
                            mainUser.position!,
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
                                image: CachedNetworkImageProvider(
                                    mainUser.pictureURL!),
                                fit: BoxFit.cover)),
                      )
                    ],
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15),
                  child: Text(
                      "An error occurred. Please refresh or close the app.",
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
        });
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
              widget.setIndex(newIndex);
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
  final Future<bool> scrape;

  const UserContent({required this.scrape, Key? key}) : super(key: key);

  @override
  _UserContentState createState() => _UserContentState();
}

class _UserContentState extends State<UserContent>
    with SingleTickerProviderStateMixin {
  int homeIndex = 0;
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    _pageController = PageController(initialPage: homeIndex);
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  void setIndex(int newIndex) {
    setState(() {
      homeIndex = newIndex;
      _pageController.animateToPage(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
      _tabController.animateTo(newIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: widget.scrape,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.blue,
                ),
              ),
            );
          } else {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              print(snapshot.stackTrace.toString());

              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                child: Text(
                    "An error occurred. Please refresh or close the app.",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
              );
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HomeTabBar(_tabController, setIndex),
                  ExpandablePageView(
                    onPageChanged: (pageIndex) {
                      if (!_tabController.indexIsChanging) {
                        setState(() {
                          setIndex(pageIndex);
                        });
                      }
                    },
                    controller: _pageController,
                    children: [UserReqs(), UserEvents()],
                  )
                ],
              );
            }
          }
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            child: Text('State: ${snapshot.connectionState}'),
          );
        });
  }
}

class UserReqs extends StatefulWidget {
  const UserReqs({Key? key}) : super(key: key);

  @override
  _UserReqsState createState() => _UserReqsState();
}

class _UserReqsState extends State<UserReqs> {
  late double reqListHeight;
  int reqTileHeight = 200; //pixels
  List<String> reqKeys = mainUser.reqs.keys.toList();

  @override
  void initState() {
    calcReqListHeight();
    super.initState();
  }

  dynamic discernDouble(double input) {
    return input % 1 == 0 ? input.toInt() : input;
  }

  void calcReqListHeight() {
    reqListHeight = ((reqKeys.length / 2) + (reqKeys.length % 2)) *
        (reqTileHeight - 25) *
        1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (reqKeys.length != 0) {
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
              CredInfo curInfo = pullCredInfo(reqKeys[index]);

              double credFontSize = 60;
              List<double> credValues = mainUser.reqs[reqKeys[index]]!;
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
    } else {
      return Container(
          alignment: Alignment.center,
          child: Text("You currently do not have any requirements.",
              style: GoogleFonts.dmSerifDisplay(fontSize: 24)));
    }
  }
}

class UserEvents extends StatefulWidget {
  const UserEvents({Key? key}) : super(key: key);

  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  late double eventListHeight;
  int eventTileHeight = 75;

  @override
  void initState() {
    calcEventListHeight();
    super.initState();
  }

  void calcEventListHeight() {
    eventListHeight = (eventTileHeight + 40) * mainUser.upcomingEvents.length * 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (mainUser.upcomingEvents.isNotEmpty) {
      return Container(
          height: eventListHeight,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 5, left: 25, right: 25),
            physics: NeverScrollableScrollPhysics(),
            itemCount: mainUser.upcomingEvents.length,
            itemBuilder: (context, index) {
              CredInfo info = pullCredInfo(mainUser.upcomingEvents[index].cred);
              bool hasTimes =
                  (mainUser.upcomingEvents[index].start != null) ? true : false;
              EventFull event = mainUser.upcomingEvents[index];

              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  splashColor: HSLColor.fromColor(info.color)
                      .withLightness(0.6)
                      .toColor(),
                  // padding: EdgeInsets.all(0),
                  child: Ink(
                    width: MediaQuery.of(context).size.width,
                    height: eventTileHeight * 1.0,
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
                  onTap: () {},
                ),
              );
            },
          ));
    } else {
      return Container(
          alignment: Alignment.center,
          child: Text("You are currently not signed up for any events.",
              style: GoogleFonts.dmSerifDisplay(fontSize: 24)));
    }
  }
}
