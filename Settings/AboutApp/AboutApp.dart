///
/// Defining AboutApp's internal contents from SettingsContents.dart
///

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Internal/APOM_Objects.dart';
import '../../Internal/AboutApp_Constants.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../SettingsPage.dart';
import '../../Internal/URLHandler.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          Container(
            padding: EdgeInsets.only(top: 0, bottom: 5),
            child: Text("Privacy",
                style: GoogleFonts.carroisGothic(
                    fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Container(
              margin: EdgeInsets.only(left: 10),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                  "Alpha Phi Omega Mobile operates by using users’ input "
                  "Emails and Passwords to authenticate to www.apoon.org via HTTP.\n\n"
                  "After login is validated, data involving users’ profile info, "
                  "requirements, and upcoming events is scrapped for display. \n\n"
                  "None of this data is stored externally in third party databases. "
                  "It solely exists on www.apoon.org.",
                  style: GoogleFonts.carroisGothic(fontSize: 16))),
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 5),
            margin: EdgeInsets.only(left: 5),
            child: Text("Security",
                style: GoogleFonts.carroisGothic(
                    fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Container(
              margin: EdgeInsets.only(left: 15),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                  "To remember previous logins, Alpha Phi Omega Mobile "
                  "stores users’ login info locally. It is encrypted and wiped per: \n\n"
                  "\t - every unsuccessful login \n"
                  "\t - every successful login w/ “Remember Me?” unchecked",
                  style: GoogleFonts.carroisGothic(fontSize: 16)))
        ],
      ),
    );
  }
}

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({Key? key}) : super(key: key);

  String joinBody(List<String> text) {
    String result = "";

    for (String line in text) {
      result += "\t- $line\n";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      itemCount: changelog.length,
      itemBuilder: (context, index) {
        ChangelogEntry entry = changelog[index];

        return Container(
            padding: EdgeInsets.zero,
            // color: Colors.red,
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(
                        text: "V. ${entry.version}",
                        style: GoogleFonts.carroisGothic(
                            fontSize: 24, color: Colors.black),
                        children: [
                      TextSpan(
                          text:
                              " - ${DateFormat('M/d/y').format(entry.updated).toString()}",
                          style: GoogleFonts.carroisGothic(fontSize: 14))
                    ])),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text(joinBody(entry.body),
                      style: GoogleFonts.carroisGothic(fontSize: 16)),
                )
              ],
            ));
      },
    );
  }
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({Key? key}) : super(key: key);

  List<Widget> formatPackages() {
    List<Widget> result = [];

    result.add(Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text("Thank you to the creators of these Dart.dev libraries",
          textAlign: TextAlign.center,
          style: GoogleFonts.carroisGothic(fontSize: 24)),
    ));

    for (String package in packagesUsed) {
      result.add(Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Text(package,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.carroisGothic(
                fontSize: 24, fontWeight: FontWeight.bold)),
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
            physics: ClampingScrollPhysics(), children: formatPackages()));
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            SizedBox.square(
              dimension: 150,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("assets/appIcon.png")),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Alpha Phi Omega\nMobile",
                textAlign: TextAlign.center,
                style: GoogleFonts.carroisGothic(fontSize: 24),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "V. $version\n"
                "Powered by Flutter\n"
                "Network requests from www.apoon.org\n"
                "Developed by Anthony Norderhaug\n"
                "Fall 2021 Alpha Gamma Class",
                textAlign: TextAlign.center,
                style: GoogleFonts.carroisGothic(fontSize: 16, height: 1.35),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "Alpha Phi Omega Mobile is in no way affiliated with, "
                "nor endorsed by, Alpha Phi Omega, National Service Fraternity.",
                textAlign: TextAlign.center,
                style: GoogleFonts.carroisGothic(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15),
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    "Support/feedback email",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.carroisGothic(
                        fontSize: 14, color: Colors.blue),
                  ),
                )),
            Container(
              alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15),
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    "Give the app a review!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.carroisGothic(
                        fontSize: 14, color: Colors.blue),
                  )),
                )
          ],
        ));
  }
}
