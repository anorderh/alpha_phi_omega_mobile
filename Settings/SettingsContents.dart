///
/// Defining Settings.dart's internal contents
///

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'AboutApp/AboutApp.dart';
import 'SettingsPage.dart';
import '../Internal/URLHandler.dart';

class AboutApp extends StatefulWidget {
  AboutApp({Key? key}) : super(key: key);

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> with SingleTickerProviderStateMixin{
  late TabController controller;
  late ThemeData theme;

  List<Widget> tabs = [
    Tab(text: "PRIVACY"),
    Tab(text: "INFO"),
    Tab(text: "CHANGELOG"),
    Tab(text: "CREDITS"),
  ];
  int index = 1;

  @override
  void initState() {
    controller = TabController(initialIndex: index, length: 4, vsync: this);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: "About App",
      content: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: TabBar(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                isScrollable: true,
                labelColor: theme.colorScheme.secondary,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.carroisGothic(fontSize: 24),
                unselectedLabelStyle: GoogleFonts.carroisGothic(fontSize: 12),
                labelPadding: EdgeInsets.symmetric(horizontal: 5),
                indicatorColor: Colors.transparent,
                controller: controller,
                tabs: tabs,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  PrivacyPage(),
                  InfoPage(),
                  ChangelogPage(),
                  CreditsPage()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class WhatIsAPO extends StatefulWidget {
  const WhatIsAPO({Key? key}) : super(key: key);

  @override
  _WhatIsAPOState createState() => _WhatIsAPOState();
}

class _WhatIsAPOState extends State<WhatIsAPO> {
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
        title: "What is APO?",
        content: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: Column(
              children: [
                Flexible(
                  child: PageView(
                    controller: controller,
                    children: [
                      APOPage(
                          image: AssetImage("assets/whatisAPO1.jpeg"),
                          textWidget: RichText(
                              textAlign: TextAlign.center,
                              maxLines: 6,
                              text: TextSpan(
                                  style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
                                  children: [
                                    TextSpan(
                                        text: "Alpha Phi Omega",
                                        style: TextStyle(fontSize: 32)),
                                    TextSpan(
                                        text:
                                            ' is the largest gender-inclusive, intercollegiate community service organization in the United States.')
                                  ]))),
                      APOPage(
                          image: AssetImage("assets/whatisAPO2.jpeg"),
                          textWidget: Text(
                            'For the past 14 years (since its 2008 rechartering), the Alpha Delta chapter  @ SDSU has been committed to developing students into stronger Leaders, Friends, and Servants for those in need.',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                            textAlign: TextAlign.center,
                          )),
                      APOPage(
                          image: AssetImage("assets/whatisAPO3.jpeg"),
                          textWidget: Text(
                            'Coordinating with San Diego-based orgs, we offer members the opportunity to hone their professional skills, develop stronger bonds with each other, and truly realize the merit of service.',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                            textAlign: TextAlign.center,
                          )),
                      APOPage(
                          image: AssetImage("assets/whatisAPO4.jpeg"),
                          textWidget: LinkableText(
                            text:
                                'With 470,000 members across 375 different campuses, it is our vision to be the premier leadership development organization for all University students. If you are interested in joining, please contact our Recruitment Chair at external@aposdsu.org.',
                            style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                            align: TextAlign.center,
                          )),
                    ],
                  ),
                ),
                SmoothPageIndicator(
                  controller: controller,
                  count: 4,
                  axisDirection: Axis.horizontal,
                  effect: ScaleEffect(
                      activeDotColor: Colors.blueAccent,
                      dotHeight: 6,
                      dotWidth: 6,
                      spacing: 6),
                )
              ],
            )));
  }
}

class APOPage extends StatelessWidget {
  final AssetImage image;
  final Widget textWidget;

  const APOPage({Key? key, required this.image, required this.textWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: 100.w,
          child: ClipRRect(
              clipBehavior: Clip.hardEdge, child: Image(image: image)),
        ),
        Container(
          margin: EdgeInsets.only(top: 15),
          alignment: Alignment.center,
          padding: EdgeInsets.all(15),
          child: textWidget,
        )
      ],
    );
  }
}

class Features extends StatefulWidget {
  const Features({Key? key}) : super(key: key);

  @override
  _FeaturesState createState() => _FeaturesState();
}

class _FeaturesState extends State<Features> {
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
        title: "Features",
        content: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: Column(
              children: [
                Flexible(
                  child: PageView(
                    controller: controller,
                    children: [
                      FeaturesPage(
                          image: [
                            Image.asset('assets/featuresReqs.png'),
                            Image.asset('assets/featuresEvents.png')
                          ],
                          textWidget: Text(
                            '1. Track requirements and events you’re signed up for.',
                            maxLines: 3,
                            style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                            textAlign: TextAlign.center,
                          )),
                      FeaturesPage(
                        image: [Image.asset('assets/featuresCalendar.png')],
                        textWidget: Text(
                          '2. Utilize a day-view calendar to learn about events Alpha Delta is currently organizing.',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FeaturesPage(
                        image: [Image.asset('assets/featuresEV.png')],
                        textWidget: Text(
                          '3. Event details on the go, including a description, location, date, credit, host, and participants.',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FeaturesPage(
                        image: [Image.asset('assets/featuresJoin.png')],
                        textWidget: Text(
                          '4. Join and leave events with immediate updates on www.apoonline.org',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                SmoothPageIndicator(
                  controller: controller,
                  count: 4,
                  axisDirection: Axis.horizontal,
                  effect: ScaleEffect(
                      activeDotColor: Colors.blueAccent,
                      dotHeight: 6,
                      dotWidth: 6,
                      spacing: 6),
                )
              ],
            )));
  }
}

class FeaturesPage extends StatelessWidget {
  final List<Image> image;
  final Widget textWidget;

  const FeaturesPage({Key? key, required this.image, required this.textWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              margin: EdgeInsets.only(bottom: 25),
              alignment: Alignment.center,
              child: textWidget,
            ),
            image.length == 1
                ? Expanded(
                    child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ]),
                        child: image[0]),
                  )
                : Container(
                    width: 100.w,
                    height: 40.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10)
                            ]),
                            child: image[0]),
                        Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10)
                            ]),
                            child: image[1])
                      ],
                    ),
                  ),
          ],
        ));
  }
}
