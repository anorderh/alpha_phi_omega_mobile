import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:calendar_view/calendar_view.dart';

///////////////
// USER DATA //
///////////////

UserData mainUser = UserData();

// managing user HTTP information
class UserHTTP {
  late BeautifulSoup homeResponse;
  late BeautifulSoup profileResponse;
  late BeautifulSoup upcomingEventsResponse;
  late BeautifulSoup calendarResponse;
  late BeautifulSoup eventResponse;
  bool validLogin = false;

  Map<String, String> data = {
    'redirect': 'memberhome.php',
    'submit': 'Log In',
    // '__csrf_magic' : 'sid:8b9cc0dfe0aa8077cd5bdfc7a111bf19a7869aa4,1642106437'
  };
  Map<String, String> headers = {
    // 'Cookie': 'PHPSESSID=ibme3ub48cf8vvg28g9rv4khi2',
    'Accept-Encoding': 'gzip, deflate, br'
  };

  void setCSRFToken(String token) {
    data['__csrf_magic'] = token;
  }

  void setPHPCookie(String cookie) {
    headers['Cookie'] = cookie;
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
    http = UserHTTP();
    name = email = pictureURL = position = greeting = null;
    reqs = {};
    upcomingEvents = [];
  }
}


