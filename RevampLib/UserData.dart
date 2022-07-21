import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

///////////////
// USER DATA //
///////////////

class MainUser extends InheritedWidget {
  final UserData data;

  const MainUser({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static MainUser of(BuildContext context) {
    final MainUser? result =
        context.dependOnInheritedWidgetOfExactType<MainUser>();
    assert(result != null, 'No MainUser found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MainUser oldWidget) => data != oldWidget.data;
}

// managing user HTTP information
class UserHTTP {
  late BeautifulSoup homeResponse;
  late BeautifulSoup profileResponse;
  late BeautifulSoup upcomingEventsResponse;
  late BeautifulSoup calendarResponse;

  late String chapter;
  late String baseURL;
  bool validConnection= false;

  Map<String, String> data = {
    'redirect': 'memberhome.php',
    'submit': 'Log In',
    // '__csrf_magic' : 'sid:8b9cc0dfe0aa8077cd5bdfc7a111bf19a7869aa4,1642106437'
  };
  Map<String, String> headers = {
    // 'Cookie': 'PHPSESSID=ibme3ub48cf8vvg28g9rv4khi2',
    'Accept-Encoding': 'gzip, deflate, br'
  };

  UserHTTP(String chapter) {
    setChapter(chapter);
  }

  void setChapter(String input) {
    chapter = input;
    baseURL =
        'https://www.apoonline.org/${chapter.replaceAll(" ", "").toLowerCase()}/memberhome.php';
  }

  Map<String, Map<String, String>> getHTTPTags() {
    return {'data': data, 'headers': headers};
  }

  void setCSRFToken(String token) {
    data['__csrf_magic'] = token;
  }

  void setPHPCookie(String cookie) {
    headers['Cookie'] = cookie;
  }

  void setHomeResponse(BeautifulSoup soup) {
    homeResponse = soup;
  }

  void setProfileResponse(BeautifulSoup soup) {
    profileResponse = soup;
  }

  void setUpcomingEventsResponse(BeautifulSoup soup) {
    upcomingEventsResponse = soup;
  }

  void setCalendarResponse(BeautifulSoup soup) {
    calendarResponse = soup;
  }

  void setStatus(bool status) {
    validConnection = status;
  }
}

// managing user data
class UserData {
  late UserHTTP http;

  late String? name;
  late String? email;
  late String? pictureURL;
  late String? position;
  late String? greeting;

  late Map<String, List<double>> reqs;
  late List<EventFull> upcomingEvents;

  UserData() {
    resetData();
  }

  void resetData() {
    name = email = pictureURL = position = greeting = null;
    reqs = {};
    upcomingEvents = [];
  }

  void setHTTP(UserHTTP newHttp) {
    http = newHttp;
  }

  void setInfo({
    required String newName,
    required String newEmail,
    required String newPictureURL,
    required String newPosition,
    required String newGreeting,
  }) {
    name = newName;
    email = newEmail;
    pictureURL = newPictureURL;
    position = newPosition;
    greeting = newGreeting;
  }

  void setReqs(Map<String, List<double>> newReqs) {
    reqs = newReqs;
  }

  void setUpcomingEvents(List<EventFull> newUpcoming) {
    upcomingEvents = newUpcoming;
  }
}

void Logout(BuildContext context) {
  MainUser.of(context).data.resetData();
  Navigator.of(context).popUntil((route) => route.isFirst);
}
