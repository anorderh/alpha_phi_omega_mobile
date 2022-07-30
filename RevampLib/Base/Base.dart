///
/// Base screen connecting Home.dart & Calendar.dart
///

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'Home/Home.dart';
import 'Calendar/Calendar.dart';
import 'Home/Home_HTTP.dart';
import '../Data/AppData.dart';
import '../Data/UserData.dart';
import 'package:sizer/sizer.dart';

class Base extends StatefulWidget {
  final UserData user;

  const Base({Key? key, required this.user}) : super(key: key);

  @override
  BaseState createState() => BaseState();
}

class BaseState extends State<Base> with TickerProviderStateMixin {
  PersistentTabController _controller = PersistentTabController();
  List<IconData> icons = [Icons.home_rounded, Icons.event_rounded];

  late Maintenance appMaintenance;
  late Future<List<String>> scrape;
  late List<Widget> tabs;

  @override
  void initState() {
    // Getting user's info, reqs, and events.
    scrape = scrapeUserContent(widget.user, ignore: false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    appMaintenance = MainApp.of(context).maintenance;

    // Creating Home & Calendar widgets to display
    tabs = [
      Home(content: scrape, maintenance: appMaintenance),
      Calendar(current: System.of(context).currentDate)
    ];
    super.didChangeDependencies();
  }

  // If tab switch occurs in EventView context
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
        confineInSafeArea: false,
        controller: _controller,
        itemCount: icons.length,
        screens: tabs,
        navBarHeight: 85.0,
        handleAndroidBackButtonPress: true,
        screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: false,
            curve: Curves.easeInOutExpo,
            duration: Duration(milliseconds: 350)),
        customWidget: (navBarEssentials) => Align(
          alignment: Alignment.center,
          child: CustomNavBar(
              barIcons: icons,
              selectedIndex: _controller.index,
              onItemSelected: (index) {
                setState(() {
                  _controller.index = index;
                  popEventView(appMaintenance.poppableContext);
                });
              }),
        ),
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
        icon: icon,
        selected: selectedIndex == curIndex,
        onPressed: () {
          onItemSelected(curIndex);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 25, right: 25),
      alignment: Alignment.center,
      // BOTTOM NAVIGATION BAR
      width: 100.w,
      height: 150,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.25),
              spreadRadius: -20,
              blurRadius: 75,
            )
          ]),
      child: SafeArea(
        top: false,
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
      padding: EdgeInsets.only(top: 10),
      color: Colors.transparent,
      width: 33.w,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 32, color: selected ? Colors.blue : Colors.grey),
      ),
    );
  }
}
