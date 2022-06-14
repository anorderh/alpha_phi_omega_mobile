import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import '../RevampLib/AppData.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import 'package:google_fonts/google_fonts.dart';

// HOME WIDGET
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int homeIndex = 0;
  late int reqCount;
  int reqHeight = 200;
  late PageController _pageController;
  late TabController _tabController;

  Map<String, List<double>> exampleReqs = {
    "Service": [1, 2],
    "Fellowship": [4,4],
    "Leadership": [0.5,2]
  };

  late List<String> exampleKeys;

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(initialPage: homeIndex);
    _tabController = TabController(length: 2, vsync: this);
    exampleKeys = exampleReqs.keys.toList();
    reqCount = exampleKeys.length;

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
    return ((reqCount / 2) + (reqCount % 2)) * reqHeight * 1.0;
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
                      GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          padding:
                              EdgeInsets.only(top: 20, left: 20, right: 20),
                          itemCount: reqCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 20.0,
                                  crossAxisSpacing: 20.0,
                                  childAspectRatio: 1.1),
                          itemBuilder: (context, index) {
                            ReqInfo curInfo = pullReqInfo(exampleKeys[index]);

                            return Stack(
                              children: [
                                Positioned(
                                  child: ClipRect(
                                    // child #1
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      // widthFactor: 0.95,
                                      child: Container(
                                        child: Icon(
                                            curInfo.icon,
                                            size: 75,
                                            color: curInfo.color),
                                        width: 70,
                                      ),
                                    ),
                                  ),
                                  left: 94,
                                  bottom: 65,
                                ),
                                Container(
                                  height: reqHeight * 1.0,
                                  decoration: BoxDecoration(
                                      color: curInfo.color.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      border: Border.all(
                                          color: curInfo.color,
                                          width: 3)),
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
                                                      padding: EdgeInsets.only(bottom: 10, right: 5),
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            RichText(
                                                              text: TextSpan(
                                                                  text: exampleReqs[exampleKeys[index]]![0].toInt().toString(),
                                                                  style: GoogleFonts.carroisGothic(fontSize: 60, color: Colors.black87, height: 0.4),
                                                                  children: [
                                                                    TextSpan(text: "/" + exampleReqs[exampleKeys[index]]![1].toInt().toString(), style: TextStyle(fontSize: 30, height: 0.4))
                                                                  ]
                                                              ),
                                                            ),
                                                            Text("CREDITS", style: GoogleFonts.carroisGothic(fontSize: 14, letterSpacing: -0.25, fontWeight: FontWeight.bold))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              alignment: Alignment.bottomLeft,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(exampleKeys[index].toString().toUpperCase(), style: GoogleFonts.carroisGothic(fontSize: 40, letterSpacing: -2, fontWeight: FontWeight.w500)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                      Text("events")
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
