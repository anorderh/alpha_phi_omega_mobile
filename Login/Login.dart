import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import '../http_Directory/http.dart';
import '../Homepage/HomePage.dart';
import '../Frontend/bottom_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../RevampLib/Base.dart';

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
  Future<Bs4Element?> nameTag = Future.value(null);
  late Widget loadBox = const SizedBox.shrink();
  String prompt = "";

  @override
  void initState() {
    super.initState();
  }

  void updatePrompt(String msg) {
    setState(() {
      prompt = msg;
    });
  }

  void loading(bool input) {
    setState(() {
      if (input) {
        loadBox = const Padding(
            padding: EdgeInsets.all(5), child: CircularProgressIndicator());
      } else {
        loadBox = const SizedBox.shrink();
      }
    });
  }

  void submit() async {
    loading(true);
    BeautifulSoup soup = await initHTTP(userController.text, pwController.text);

    if (soup.find('div', attrs: {'id': 'topheader-name'}) == null) {
      updatePrompt("Invalid login");
    } else {
      Map<String, dynamic> details =
          await profileDetails(soup, userController.text);
      updatePrompt("Successful login");

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Nav(details)));
    }
    loading(false);

    userController.clear();
    pwController.clear();
    FocusScope.of(context).unfocus();
  }

  void openBase() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Base()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(240, 252, 255, 1),
        body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(  // ENTIRE SCREEN
                  height: MediaQuery.of(context).size.height,
                  child: Column(  // CONTENTS
                    children: [
                      Flexible(  // FRAT & CHAPTER
                        flex: 3,
                        child: Stack(
                          children: [
                            Positioned( // CHAPTER BUBBLE
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
                                        width: 2, color: Colors.lightBlueAccent)),
                              ),
                            ),
                            Align(  // FRAT BUBBLE
                                alignment: Alignment.centerLeft,
                                child: ClipRect(
                                  // child #1
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    widthFactor: 0.92,
                                    child: Container(
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
                                          child: Image.asset('assets/apoLogo2.png')),
                                      height: 280,
                                      width: 280,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 2, color: Colors.lightBlueAccent)),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Flexible(  // LOGIN CREDENTIALS
                        flex: 4,
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "Welcome!",
                                style:
                                TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              Text("In Leadership, Friendship, and Service",
                                  style: TextStyle(fontSize: 16, color: Colors.grey)),
                              Padding(   // EMAIL TEXT FIELD
                                  padding: EdgeInsets.fromLTRB(25, 15, 25, 20),
                                  child: CupertinoTextField(
                                    placeholderStyle: GoogleFonts.dmSerifDisplay(
                                        textStyle: TextStyle(
                                            color: Color.fromRGBO(190, 190, 190, 1),
                                            fontSize: 16)),
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    placeholder: 'Email',
                                    controller: userController,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                    ),
                                  )),
                              Padding(   // PASSWORD TEXT FIELD
                                  padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                                  child: CupertinoTextField(
                                    placeholderStyle: GoogleFonts.dmSerifDisplay(
                                        textStyle: TextStyle(
                                            color: Color.fromRGBO(190, 190, 190, 1),
                                            fontSize: 16)),
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    placeholder: 'Password',
                                    controller: pwController,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                    ),
                                  )),
                              Container(  // LOGIN BUTTON
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.5),
                                    spreadRadius: -25,
                                    blurRadius: 10,
                                  )]
                                ),
                                padding: EdgeInsets.all(25),
                                child: CupertinoButton(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  color: Colors.lightBlue,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Text("Login",
                                          style: GoogleFonts.dmSerifDisplay(
                                              fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                  ),
                                  onPressed: openBase,
                                ),
                              ),
                              Container(  // LOGIN HELP
                                padding: EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text("If you are unable to login, refer to"),
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
                )
            )
        ));
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     appBar: AppBar(
//       title: Text("APO Login"),
//     ),
//     body: SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(top: 60.0),
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                 child: Container(
//                     width: 200,
//                     height: 150,
//                     child: Image.asset('assets/apo_Logo.jpeg')),
//               ),
//             ),
//           ),
//           Padding(
//             //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: TextField(
//               controller: userController,
//               decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Email',
//                   hintText: 'Enter valid email'),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 15.0, right: 15.0, top: 15, bottom: 0),
//             //padding: EdgeInsets.symmetric(horizontal: 15),
//             child: TextField(
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Password',
//                     hintText: 'Enter secure password'),
//                 controller: pwController),
//           ),
//           TextButton(
//             onPressed: () {
//               //TODO FORGOT PASSWORD SCREEN GOES HERE
//             },
//             child: const Text(
//               'Forgot Password',
//               style: TextStyle(color: Colors.blue, fontSize: 15),
//             ),
//           ),
//           Container(
//             height: 50,
//             width: 250,
//             decoration: BoxDecoration(
//                 color: Colors.blue, borderRadius: BorderRadius.circular(20)),
//             child: TextButton(
//               onPressed: submit,
//               child: const Text(
//                 'Login',
//                 style: TextStyle(color: Colors.white, fontSize: 25),
//               ),
//             ),
//           ),
//           Padding(padding: EdgeInsets.all(15), child: Text(prompt)),
//           SizedBox(
//             height: 130,
//             child: Container(
//               alignment: Alignment.topCenter,
//               child: loadBox
//             )
//           ),
//           const Text('New User? Create Account')
//         ],
//       ),
//     ),
//   );
// }
}
