import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import '../http_Directory/http.dart';
import '../Homepage/HomePage.dart';
import '../Frontend/bottom_nav.dart';

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
            padding: EdgeInsets.all(5),
            child: CircularProgressIndicator());
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
      Map<String, dynamic> details = await profileDetails(soup);
      updatePrompt("Successful login");

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Nav(details)));
    }
    loading(false);

    userController.clear();
    pwController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("APO Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Container(
                      width: 200,
                      height: 150,
                      child: Image.asset('assets/apo_Logo.jpeg')),
                ),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: userController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password'),
                  controller: pwController),
            ),
            TextButton(
              onPressed: () {
                //TODO FORGOT PASSWORD SCREEN GOES HERE
              },
              child: const Text(
                'Forgot Password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: submit,
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(15), child: Text(prompt)),
            SizedBox(
              height: 130,
              child: Container(
                alignment: Alignment.topCenter,
                child: loadBox
              )
            ),
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}
