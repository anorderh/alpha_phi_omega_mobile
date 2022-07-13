import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import '../RevampLib/Home.dart';
import '../RevampLib/Calendar.dart';
import 'Home_HTTP.dart';
import 'AppData.dart';
import 'UserData.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  BaseState createState() => BaseState();
}

class BaseState extends State<Base> with SingleTickerProviderStateMixin {
  PersistentTabController _controller = PersistentTabController();
  late Maintenance appMaintenance;
  late List<IconData> icons;
  late List<Widget> tabs;

  @override
  void initState() {
    icons = [Icons.home_rounded, Icons.event_rounded];

    super.initState();
  }

  @override
  void didChangeDependencies() {
    appMaintenance = MainApp.of(context).maintenance;

    tabs = [
      Home(
          info: scrapeUserInfo(MainUser.of(context).data, MainApp.of(context).mainCalendar.activeDate),
          content: scrapeUserContent(MainUser.of(context).data)
      ),
      Calendar(current: MainApp.of(context).mainCalendar.activeDate)
    ];
    super.didChangeDependencies();
  }

  void popEventView(BuildContext? viewContext) {
    if (viewContext != null) {
      Navigator.of(viewContext).pop();
      appMaintenance.setBuildContext(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PersistentTabView.custom(
        context,
        backgroundColor: Colors.transparent,
        controller: _controller,
        itemCount: icons.length,
        screens: tabs,
        navBarHeight: 70.0,
        handleAndroidBackButtonPress: true,
        screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.easeInOutExpo,
            duration: Duration(milliseconds: 350)),
        customWidget: (navBarEssentials) => CustomNavBar(
            barIcons: icons,
            selectedIndex: _controller.index,
            onItemSelected: (index) {
              setState(() {
                _controller.index = index;
                popEventView(appMaintenance.poppableContext);
              });
            }),
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<IconData> barIcons;
  final ValueChanged<int> onItemSelected;

  const CustomNavBar(
      {Key? key,
      required this.barIcons,
      required this.onItemSelected,
      required this.selectedIndex})
      : super(key: key);

  IconBottomBar _buildNavButton(IconData icon, int curIndex) {
    return IconBottomBar(
        // HOME BUTTON
        icon: icon,
        selected: selectedIndex == curIndex,
        onPressed: () {
          onItemSelected(curIndex);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // BOTTOM NAVIGATION BAR
      width: MediaQuery.of(context).size.width,
      height: 80,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.5),
              spreadRadius: -20,
              blurRadius: 150,
            )
          ]),
      child: Padding(
        padding: EdgeInsets.only(left: 25, right: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: barIcons.map((icon) {
            int index = barIcons.indexOf(icon);

            return _buildNavButton(barIcons[index], index);
          }).toList(),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  const IconBottomBar(
      {required this.icon,
      required this.selected,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width / 3,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 32, color: selected ? Colors.blue : Colors.grey),
      ),
    );
  }
}
