///
/// Settings to view app info and logout
///

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../Data/AppData.dart';
import '../Internal/AppThemes.dart';
import 'SettingsContents.dart';
import 'SettingsPage.dart';
import '../Internal/TransitionHandler.dart';
import '../Data/UserData.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool loadStatus;
  late UserData user;
  late ThemeProvider theme;

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    theme = Provider.of<ThemeProvider>(context);

    loadStatus = checkLoad();
    super.didChangeDependencies();
  }

  bool checkLoad() {
    if (user.name == null || user.email == null || user.position == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 10, top: 15),
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(FontAwesomeIcons.rotateLeft))),
                    Container(
                        padding: EdgeInsets.only(right: 10, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(theme.isDarkMode ? FontAwesomeIcons.moon : Icons.sunny, size: 25,),
                            Switch.adaptive(
                            activeColor: Colors.blue,
                            value: theme.isDarkMode,
                            onChanged: (value) {
                              theme.toggleDark(value);

                              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                  statusBarBrightness: value ? Brightness.light : Brightness.dark
                              ));
                            },
                          )],
                        ))
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 5.h),
                    alignment: Alignment.center,
                    child: loadStatus
                        ? UserCard(user: user)
                        : Text("User data did not finish loading.",
                            style: TextStyle(fontSize: 24))),
                Container(
                  alignment: Alignment.topCenter,
                  // color: Colors.red,
                  child: SettingsButtons(user: user),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 80,
                  child: Text("Alpha Phi Omega Mobile",
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                )
              ],
            )));
  }
}

class UserCard extends StatelessWidget {
  final UserData user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: CachedNetworkImageProvider(user.pictureURL!),
                    fit: BoxFit.cover)),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    user.name!,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                  child: Text(
                user.email!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              )),
            ),
          )
        ]);
  }
}

class SettingsButtons extends StatelessWidget {
  final UserData user;

  const SettingsButtons({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: InkWell(
                onTap: () {
                  pushToNew(
                      context: context,
                      page: WhatIsAPO(),
                      withNavBar: false,
                      transition: "fade");
                },
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Ink(
                  height: 65,
                  width: 100.w,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(1, 1),
                            color: Colors.grey.shade900.withOpacity(0.3),
                            blurRadius: 5)
                      ]),
                  child: Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.personDigging,
                          color: theme.colorScheme.secondary),
                      title: Text(
                        "What is APO?",
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(FontAwesomeIcons.angleRight),
                    ),
                  ),
                ),
              )),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: InkWell(
                onTap: () {
                  pushToNew(
                      context: context,
                      page: Features(),
                      withNavBar: false,
                      transition: "fade");
                },
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Ink(
                  height: 65,
                  width: 100.w,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            color: Colors.grey.shade900.withOpacity(0.3),
                            blurRadius: 5)
                      ]),
                  child: Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.penToSquare,
                          color: theme.colorScheme.secondary),
                      title: Text(
                        "Features",
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(FontAwesomeIcons.angleRight),
                    ),
                  ),
                ),
              )),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: InkWell(
                onTap: () {
                  pushToNew(
                      context: context,
                      page: AboutApp(),
                      withNavBar: false,
                      transition: "fade");
                },
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Ink(
                  height: 65,
                  width: 100.w,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            color: Colors.grey.shade900.withOpacity(0.3),
                            blurRadius: 5)
                      ]),
                  child: Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.circleInfo,
                          color: theme.colorScheme.secondary),
                      title: Text(
                        "About App",
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(FontAwesomeIcons.angleRight),
                    ),
                  ),
                ),
              )),
          SizedBox(
            height: 65,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: InkWell(
                onTap: () {
                  Logout(context);
                },
                splashColor: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Container(
                  height: 65,
                  width: 100.w,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            color: Colors.grey.shade900.withOpacity(0.3),
                            blurRadius: 5)
                      ]),
                  child: Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.arrowRightFromBracket,
                        color: Colors.red,
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
