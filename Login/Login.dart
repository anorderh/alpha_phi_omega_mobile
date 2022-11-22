///
/// Login page and user credential handling
///

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:example/Data/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Internal/APOM_Constants.dart';
import '../Data/AppData.dart';
import '../Base/Base.dart';
import 'Login_HTTP.dart';
import '../Settings/SettingsContents.dart';
import '../Internal/TransitionHandler.dart';
import '../Internal/URLHandler.dart';
import '../Data/UserData.dart';
import 'package:sizer/sizer.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final userController = TextEditingController();
  final pwController = TextEditingController();
  late UserData user;
  late ThemeData theme;
  SharedPreferences prefs = UserPreferences.prefs;

  bool isLoading = false;
  bool timeout = false;
  bool rememberUser = false;
  late Future<bool> setFields;

  String chapter = chapterLibrary.keys.toList()[0];
  late double OSpadding;

  @override
  void initState() {
    setFields = setUserFields();
    super.initState();
  }

  // Pulling from local, encrypted storage.
  Future<bool> setUserFields() async {
    rememberUser = await InternalStorage.isUserRemembered();
    userController.text = await InternalStorage.getUsername() ?? '';
    pwController.text = await InternalStorage.getPassword() ?? '';

    return true;
  }

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: theme.brightness
    ));

    OSpadding = MediaQuery.of(context).viewPadding.vertical;

    user = MainUser.of(context).data;
    super.didChangeDependencies();
  }

  // Attempt login.
  Future<void> submit() async {
    timeout = false;
    setState(() {
      isLoading = true;
    });

    user.http =
        UserHTTP(chapter); // New HTTP object with Chapter apoon.org URL.
    String httpMsg =
        await initHTTP(user.http, userController.text, pwController.text)
            .timeout(const Duration(seconds: 10),
                onTimeout: () => "Unstable network");
    if (httpMsg == "Unstable network") {
      timeout = true;
    }

    user.email = userController.text;

    // Saving fields ONLY if 1) valid login and 2) rememberUser is true.
    if (user.http.validConnection && rememberUser) {
      InternalStorage.setUsername(userController.text);
      InternalStorage.setPassword(pwController.text);
    } else {
      InternalStorage.clear();
      rememberUser = false;

      userController.clear();
      pwController.clear();
    }

    InternalStorage.setRememberUser(rememberUser);
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = false;
    });
  }

  // Translating dropdown to Greek letters.
  List<DropdownMenuItem<String>> setDropdown(List<String> chapters) {
    List<DropdownMenuItem<String>> items = [];

    for (String chapter in chapters) {
      items.add(DropdownMenuItem<String>(
        value: chapter,
        child: Text(
          getGreekLetters(chapter),
          style: const TextStyle(fontSize: 24),
        ),
      ));
    }

    return items;
  }

  String getGreekLetters(String chapter) {
    List<String> greeklish = chapter.split(" ");

    return Iterable.generate(greeklish.length, (i) {
      return greekAlphabet[greeklish[i]]!;
    }).toList().join();
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = theme.primaryColor == Colors.white;

    return Scaffold(
      backgroundColor: isLight ? Color.fromRGBO(239, 252, 255, 1) : theme.primaryColor,
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: FutureBuilder<bool>(
                future: setFields,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.blueAccent),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: SafeArea(
                          child: Container(
                            alignment: Alignment.center,
                            // ENTIRE SCREEN
                            height: 100.h - OSpadding,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // CONTENTS
                              children: [
                                Container(
                                    // color: Colors.green,
                                    width: 100.w,
                                    height: 40.h,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          // CHAPTER BUBBLE
                                          left: 58.w,
                                          bottom: 5.h,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 5, right: 0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: DropdownButton2(
                                                buttonDecoration: BoxDecoration(
                                                    color: Colors.transparent),
                                                buttonWidth: 65,
                                                iconSize: 20,
                                                dropdownOverButton: true,
                                                // offset: Offset(-10, 7),
                                                scrollbarAlwaysShow: true,
                                                dropdownWidth: 85,
                                                alignment: Alignment.center,
                                                value: chapter,
                                                dropdownMaxHeight: 150,
                                                onChanged:
                                                    (String? newChapter) {
                                                  setState(() {
                                                    chapter = newChapter!;
                                                  });
                                                },
                                                items: setDropdown(
                                                    chapterLibrary.keys
                                                        .toList()),
                                              ),
                                            ),
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.15),
                                                      blurRadius: 3)
                                                ],
                                                color: theme.primaryColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.blue)),
                                          ),
                                        ),
                                        Positioned(
                                          // INFO BUBBLE
                                          right: 10,
                                          top: 10,
                                          child: InkWell(
                                            customBorder: CircleBorder(),
                                            onTap: () {
                                              pushToNew(
                                                  context: context,
                                                  withNavBar: false,
                                                  page: WhatIsAPO(),
                                                  transition: "fade");
                                            },
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 3)
                                                  ],
                                                  color: theme.primaryColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: Colors.blue)),
                                              child: Container(
                                                child: Icon(
                                                    FontAwesomeIcons
                                                        .fileCircleQuestion,
                                                    size: 7.w, color: Colors.grey),
                                                width: 16.w,
                                                height: 16.w,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                            // FRAT BUBBLE
                                            alignment: Alignment.centerLeft,
                                            child: ClipRect(
                                              // child #1
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                widthFactor: 0.92,
                                                child: Container(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              25, 25, 25, 10),
                                                      child: Image.asset(isLight
                                                          ? 'assets/APOLogoFinal.png'
                                                          : 'assets/APOLogoWhite.png')),
                                                  height: 70.w,
                                                  width: 70.w,
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.15),
                                                            blurRadius: 3)
                                                      ],
                                                      color: theme.primaryColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: Colors.blue)),
                                                ),
                                              ),
                                            )),
                                      ],
                                    )),
                                Container(
                                  alignment: Alignment.topCenter,
                                  // color: Colors.red,
                                  height: 40.h,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Welcome!",
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            'In Leadership, Friendship, and Service',
                                            style: TextStyle(fontSize: 18)),
                                        Container(
                                            width: 100.w,
                                            padding: EdgeInsets.only(
                                                top: 15, bottom: 20),
                                            child: CupertinoTextField(
                                              style: TextStyle(
                                                  fontSize: 18, height: 1.5),
                                              placeholderStyle:
                                                  GoogleFonts.dmSerifDisplay(
                                                      textStyle: TextStyle(
                                                          color: Color.fromRGBO(
                                                              190, 190, 190, 1),
                                                          fontSize: 18)),
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 15, 10, 15),
                                              placeholder: 'Email',
                                              controller: userController,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                color: Colors.white,
                                              ),
                                            )),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 0, bottom: 5),
                                          width: 100.w,
                                          child: CupertinoTextField(
                                            style: TextStyle(
                                                fontSize: 18, height: 1.5),
                                            obscureText: true,
                                            placeholderStyle:
                                                GoogleFonts.dmSerifDisplay(
                                                    textStyle: TextStyle(
                                                        color: Color.fromRGBO(
                                                            190, 190, 190, 1),
                                                        fontSize: 18)),
                                            padding: EdgeInsets.fromLTRB(
                                                10, 15, 10, 15),
                                            placeholder: 'Password',
                                            controller: pwController,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 100.w,
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Remember me?",
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              Checkbox(
                                                  checkColor: Colors.white,
                                                  fillColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blue),
                                                  value: rememberUser,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      rememberUser = newValue!;
                                                    });
                                                  })
                                            ],
                                          ),
                                        ),
                                        Container(
                                          // LOGIN BUTTON
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                              color: isLoading
                                                  ? Colors.grey.shade300
                                                      .withOpacity(0.5)
                                                  : Colors.blue
                                                      .withOpacity(0.5),
                                              spreadRadius: -25,
                                              blurRadius: 10,
                                            )
                                          ]),
                                          padding:
                                              EdgeInsets.fromLTRB(15, 0, 15, 0),
                                          child: CupertinoButton(
                                            disabledColor: Colors.grey.shade300,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            color: isLoading
                                                ? Colors.grey.shade400
                                                : Colors.blue,
                                            child: Container(
                                              width: 70.w,
                                              height: 3.h,
                                              child: Center(
                                                  child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: isLoading
                                                    ? SizedBox(
                                                        height: 7.w,
                                                        width: 7.w,
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive(
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                      )
                                                    : Text("Login",
                                                        style: GoogleFonts
                                                            .dmSerifDisplay(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 36, color: Colors.white)),
                                              )),
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    await submit();

                                                    // Checking valid login...
                                                    if (user
                                                        .http.validConnection) {
                                                      // Unlocked! Reset home index.
                                                      await prefs.setInt(("homeIndex"), 0);

                                                      pushToNew(
                                                          context: context,
                                                          withNavBar: true,
                                                          page: MainApp(
                                                            mainCalendar: CalendarData(
                                                                System.of(
                                                                        context)
                                                                    .currentDate),
                                                            maintenance:
                                                                Maintenance(),
                                                            child: Base(
                                                                user: user),
                                                          ),
                                                          transition: "scale");
                                                    } else {
                                                      // Locked! Prompt explaining reason
                                                      showDialog(
                                                          barrierDismissible:
                                                              true,
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(15.0))),
                                                                    title: Text(
                                                                      "Invalid Login",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    content:
                                                                        Text(
                                                                      timeout
                                                                          ? "Unstable network connection"
                                                                          : "Incorrect email and/or password",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ));
                                                    }
                                                  },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 10.h,
                                  width: 100.w,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  // LOGIN HELP
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            "If you are unable to login, refer to"),
                                        LinkableText(
                                          text: "https://www.apoonline.org/",
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.blue),
                                          align: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    top: BorderSide(
                                        width: 1, color: Colors.grey),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ));
                  }
                })));
  }
}
