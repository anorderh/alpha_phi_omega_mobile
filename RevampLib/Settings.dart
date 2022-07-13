import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../RevampLib/AppData.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import '../RevampLib/Home.dart';
import '../RevampLib/Calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AboutApp.dart';
import 'UserData.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool loadStatus;
  late UserData user;

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
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
      body: Column(
        children: [
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, top: 15),
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(FontAwesomeIcons.rotateLeft,
                          color: Colors.black)),
                ),
                Expanded(
                    child: loadStatus
                        ? UserCard(user: user)
                        : Container(
                            alignment: Alignment.center,
                            child: Text("User data did not finish loading.",
                                style: TextStyle(fontSize: 24))))
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Container(
              // color: Colors.red,
              child: SettingsButtons(user: user),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("V " + System.of(context).version,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  Text(
                      "Last Updated " +
                          DateFormat.yMMMd('en_US')
                              .format(System.of(context).lastUpdated)
                              .toString(),
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserData user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: CachedNetworkImageProvider(user.pictureURL!),
                fit: BoxFit.cover)),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              user.name!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
            child: Text(
          user.email!,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        )),
      )
    ]);
  }
}

class SettingsButtons extends StatelessWidget {
  final UserData user;

  const SettingsButtons({Key? key, required this.user}) : super(key: key);

  void Logout(BuildContext context) {
    user.resetData();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Ink(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, color: Colors.black.withOpacity(0.15))
                    ]),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.personDigging,
                    color: Colors.black,
                  ),
                  title: Text(
                    "What is APO?",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  trailing: Icon(FontAwesomeIcons.angleRight),
                ),
              ),
            )),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Ink(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, color: Colors.black.withOpacity(0.15))
                    ]),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.penToSquare,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Features",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  trailing: Icon(FontAwesomeIcons.angleRight),
                ),
              ),
            )),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutApp()));
              },
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Ink(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, color: Colors.black.withOpacity(0.15))
                    ]),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.black,
                  ),
                  title: Text(
                    "About App",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  trailing: Icon(FontAwesomeIcons.angleRight),
                ),
              ),
            )),
        Spacer(),
        Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: InkWell(
              onTap: () {
                Logout(context);
              },
              splashColor: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Ink(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5, color: Colors.black.withOpacity(0.15))
                    ]),
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
            )),
      ],
    );
  }
}
