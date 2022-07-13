import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import '../Homepage/HomePage.dart';
import '../Frontend/bottom_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AppData.dart';
import 'Base.dart';
import 'Login_HTTP.dart';
import 'UserData.dart';

// 'anthony@norderhaug.org'
// 'gqgRg6yuWTUmhmm'

class LoginBody extends StatefulWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final userController = TextEditingController();
  final pwController = TextEditingController();
  late UserData user;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    super.didChangeDependencies();
  }

  Future<void> submit() async {
    // attempting login
    setState(() {
      isLoading = true;
    });

    UserHTTP? result =
        await initHTTP(user.http, userController.text, pwController.text);
    if (result != null) {
      user.http = result;
      user.email = userController.text;
    }

    // resetting text fields
    userController.clear();
    pwController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(240, 252, 255, 1),
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(
                  // ENTIRE SCREEN
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    // CONTENTS
                    children: [
                      Flexible(
                        // FRAT & CHAPTER
                        flex: 3,
                        child: Stack(
                          children: [
                            Positioned(
                              // CHAPTER BUBBLE
                              right: 75,
                              bottom: 60,
                              child: Container(
                                child: const Center(
                                  child: Text(
                                    "ΑΔ",
                                    style: TextStyle(fontSize: 36),
                                  ),
                                ),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2,
                                        color: Colors.lightBlueAccent)),
                              ),
                            ),
                            Align(
                                // FRAT BUBBLE
                                alignment: Alignment.centerLeft,
                                child: ClipRect(
                                  // child #1
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    widthFactor: 0.92,
                                    child: Container(
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              25, 25, 25, 10),
                                          child: Image.asset(
                                              'assets/apoLogo2.png')),
                                      height: 280,
                                      width: 280,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 2,
                                              color: Colors.lightBlueAccent)),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Flexible(
                        // LOGIN CREDENTIALS
                        flex: 4,
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "Welcome!",
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              Text("In Leadership, Friendship, and Service",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              Padding(
                                  // EMAIL TEXT FIELD
                                  padding: EdgeInsets.fromLTRB(25, 15, 25, 20),
                                  child: CupertinoTextField(
                                    placeholderStyle:
                                        GoogleFonts.dmSerifDisplay(
                                            textStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                    190, 190, 190, 1),
                                                fontSize: 16)),
                                    padding:
                                        EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    placeholder: 'Email',
                                    controller: userController,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                    ),
                                  )),
                              Padding(
                                  // PASSWORD TEXT FIELD
                                  padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                                  child: CupertinoTextField(
                                    obscureText: true,
                                    placeholderStyle:
                                        GoogleFonts.dmSerifDisplay(
                                            textStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                    190, 190, 190, 1),
                                                fontSize: 16)),
                                    padding:
                                        EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    placeholder: 'Password',
                                    controller: pwController,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(
                                // LOGIN BUTTON
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.5),
                                    spreadRadius: -25,
                                    blurRadius: 10,
                                  )
                                ]),
                                padding: EdgeInsets.all(25),
                                child: CupertinoButton(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.lightBlue,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 25,
                                    child: Center(
                                      child: isLoading
                                          ? SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: CircularProgressIndicator
                                                  .adaptive(
                                                backgroundColor: Colors.white,
                                              ),
                                            )
                                          : Text("Login",
                                              style: GoogleFonts.dmSerifDisplay(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await submit();

                                    if (user.http.validLogin) {

                                      Navigator();
                                      // unlock the app
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MainApp(
                                                mainCalendar: CalendarData(
                                                  System.of(context).currentDate
                                                ),
                                                maintenance: Maintenance(),
                                                child: Base(),
                                              )));
                                    } else {
                                      // allow for login retry
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                backgroundColor:
                                                    Colors.lightBlue[50],
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15.0))),
                                                title: Text(
                                                  "Invalid Login",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: Text(
                                                  "Incorrect email and/or password",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ));
                                    }
                                  },
                                ),
                              ),
                              Container(
                                // LOGIN HELP
                                padding: EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                          "If you are unable to login, refer to"),
                                      Text(
                                        "www.apoonline.org",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.lightBlue),
                                      )
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    border: Border(
                                  top: BorderSide(width: 1, color: Colors.grey),
                                )),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}
