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

// HOME WIDGET
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int homeIndex = 0;
  late PageController _pageController;
  late TabController _tabController;

  Map<String, List<double>> exampleReqs = {
    "Service": [1, 2],
    "Fellowship": [4, 4],
    "Leadership": [0.5, 2]
  };
  int exReqTileHeight = 200; //pixels
  int exEventTileHeight = 65;

  @override
  void initState() {
    // TODO: implement initState
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

  double calcReqListHeight() {
    return ((exampleReqs.length / 2) + (exampleReqs.length % 2)) *
        exReqTileHeight *
        1.0;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        UserHeader(),
                        HomeTabBar(_tabController, setIndex)
                      ],
                    ),
                  ),
                ),
                Container(
                  height: calcReqListHeight(),
                  child: PageView(
                    onPageChanged: (pageIndex) {
                      setState(() {
                        setIndex(pageIndex);
                      });
                    },
                    controller: _pageController,
                    children: [
                      UserReqs(
                          reqs: exampleReqs, reqTileHeight: exReqTileHeight),
                      ListView.builder(
                        padding: EdgeInsets.only(top: 5, left: 25, right: 25),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          List<EventMini> miniEvents = [
                            EventMini(
                                title:
                                    "Convoy with Rudolph and i wont ever ever ever ever ever",
                                link: "fakelink",
                                date: DateTime.now(),
                                cred: "fellowship",
                                start: "12:00PM",
                                end: "2:00PM"),
                            EventMini(
                                title: "Saving Trees",
                                link: "fakelink",
                                date: DateTime.now(),
                                cred: "service",
                                start: "12:00PM",
                                end: "2:00PM"),
                            EventMini(
                                title: "Surefire Marathon",
                                link: "fakelink",
                                date: DateTime.now(),
                                cred: "service",
                                start: "12:00PM",
                                end: "2:00PM"),
                            EventMini(
                                title: "Linkedin Workshop",
                                link: "fakelink",
                                date: DateTime.now(),
                                cred: "leadership",
                                start: "12:00PM",
                                end: "2:00PM"),
                          ];
                          CredInfo info = pullCredInfo(miniEvents[index].cred);

                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              splashColor: HSLColor.fromColor(info.color)
                                  .withLightness(0.6)
                                  .toColor(),
                              // padding: EdgeInsets.all(0),
                              child: Ink(
                                width: MediaQuery.of(context).size.width,
                                height: exEventTileHeight *1.0,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 3)
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: HSLColor.fromColor(info.color)
                                        .withLightness(0.85)
                                        .toColor()),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        padding: EdgeInsets.all(0),
                                        // height: 55,
                                        // color: Colors.white,
                                        // alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                                child: Container(
                                              // color: Colors.black,
                                              // padding: EdgeInsets.only(left: 15),
                                              child: Icon(info.icon,
                                                  size: 30,
                                                  color: HSLColor.fromColor(
                                                          info.color)
                                                      .withLightness(0.6)
                                                      .toColor()),
                                            )),
                                            Flexible(
                                                flex: 2,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  // color: Colors.white,
                                                  child: Text(
                                                      miniEvents[index].title,
                                                      style: GoogleFonts
                                                          .carroisGothic(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Container(
                                          // color: Colors.black,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          miniEvents[index]
                                                                  .start +
                                                              " to",
                                                          style: GoogleFonts
                                                              .carroisGothic(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                      Text(
                                                          miniEvents[index].end,
                                                          style: GoogleFonts
                                                              .carroisGothic(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                    ],
                                                  )),
                                              Flexible(
                                                  flex: 1,
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            weekdayLibrary[
                                                                miniEvents[
                                                                        index]
                                                                    .date
                                                                    .weekday]!,
                                                            style: GoogleFonts
                                                                .carroisGothic(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        24)),
                                                        FittedBox(
                                                          fit: BoxFit.fitWidth,
                                                          child: Text(
                                                              DateFormat.yMd()
                                                                  .format(miniEvents[
                                                                          index]
                                                                      .date),
                                                              style: GoogleFonts
                                                                  .carroisGothic(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                        )
                                                      ]))
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              onTap: () {},
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}

// USER HEADER
class UserHeader extends StatefulWidget {
  const UserHeader({Key? key}) : super(key: key);

  @override
  _UserHeaderState createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
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
                  "Good Morning,",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      height: 0.6,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  child: Text(
                "Donatello",
                style: TextStyle(
                  fontSize: 36,
                ),
              )),
              Container(
                  child: Text(
                "Active",
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
                    image: Image.asset('assets/donatello.jpeg').image,
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

class UserReqs extends StatefulWidget {
  final Map<String, List<double>> reqs;
  final int reqTileHeight;

  const UserReqs({required this.reqs, required this.reqTileHeight, Key? key})
      : super(key: key);

  @override
  _UserReqsState createState() => _UserReqsState();
}

class _UserReqsState extends State<UserReqs> {
  late List<String> reqKeys;

  @override
  void initState() {
    reqKeys = widget.reqs.keys.toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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

          return Stack(
            children: [
              Container(
                height: widget.reqTileHeight * 1.0,
                decoration: BoxDecoration(
                    color: HSLColor.fromColor(curInfo.color)
                        .withLightness(0.9)
                        .toColor(),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    border: Border.all(
                        color: HSLColor.fromColor(curInfo.color)
                            .withLightness(0.65)
                            .toColor(),
                        width: 2)),
                child: SizedBox.expand(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 10, right: 5),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                text: widget
                                                    .reqs[reqKeys[index]]![0]
                                                    .toInt()
                                                    .toString(),
                                                style:
                                                    GoogleFonts.carroisGothic(
                                                        fontSize: 60,
                                                        color: Colors.black87,
                                                        height: 0.4),
                                                children: [
                                                  TextSpan(
                                                      text: "/" +
                                                          widget.reqs[reqKeys[
                                                                  index]]![1]
                                                              .toInt()
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          height: 0.4))
                                                ]),
                                          ),
                                          Text("CREDITS",
                                              style: GoogleFonts.carroisGothic(
                                                  fontSize: 14,
                                                  letterSpacing: -0.25,
                                                  fontWeight: FontWeight.bold))
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
                            alignment: Alignment.bottomLeft,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                  reqKeys[index].toString().toUpperCase(),
                                  style: GoogleFonts.carroisGothic(
                                      fontSize: 32,
                                      letterSpacing: -2,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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
              )
            ],
          );
        });
  }
}
