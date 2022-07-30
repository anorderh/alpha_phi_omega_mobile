///
/// Methods involving HTTP requests for Base.dart/Home.dart
///

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/Data/UserData.dart';
import '../../Internal/APOM_Constants.dart';
import '../Calendar/CalendarHelpers.dart';
import '../Calendar/Calendar_HTTP.dart';
import '../../Login/Login_HTTP.dart';

// Scrape info related to user.
Future<String> scrapeUserInfo(UserData user) async {
  http.Response raw;

  // Try block to catch exception.
  // Either... 1) Website is un-parseable or 2) Network is shaky.
  try {
    String userInfoURL = user.http.baseURL + '?' + profile_action;

    raw = await http.post(
      Uri.parse(userInfoURL),
      body: user.http.data,
      headers: user.http.headers,
    );
    user.http.profileResponse = BeautifulSoup(raw.body);

    // Check if login credentials have expired.
    if (!verifyHTTP(user.http.profileResponse)) {
      return "Not recognized";
    }

    user.name = user.http.profileResponse
        .find('div', attrs: {'class': 'content-header'})!
        .children[0]
        .text;

    user.position = user.http.profileResponse
        .find('div', attrs: {'class': 'content-subheader'})!
        .text
        .split(" of ")[0]
        .substring(1);

    user.pictureURL = "http://www.apoonline.org/alphadelta/" +
        user.http.profileResponse.find('img')!['src']!;

    user.greeting = deriveGreeting(DateTime.now());
  } on SocketException {
    return "Unstable network";
  } catch (e) {
    return e.toString().substring(0, 45);
  }

  print("USER INFO:\n${user.name}\n${user.position}\n");
  return "Success";
}

// Core method. Filters scrapes in case only certain data needed.
Future<List<String>> scrapeUserContent(UserData user,
    {required bool ignore}) async {
  return await Future.wait(ignore
      ? [scrapeUpcomingEvents(user)]
      : [scrapeUserInfo(user), scrapeReqs(user), scrapeUpcomingEvents(user)]);
}

// Scrape user requirements.
Future<String> scrapeReqs(UserData user) async {
    try {
      if (!verifyHTTP(user.http.homeResponse)) {
        return "Not recognized";
      } else {
        user.reqs = mapReqs(
            _stringsFromTags(user.http.homeResponse.findAll(
              // credit names
                'a',
                attrs: {
                  'style': 'margin-bottom: .5em;display: block;color:black;'
                })),
            _stringsFromTags(user.http.homeResponse.findAll(
              // credit amounts
                'span',
                attrs: {'style': 'float:right; color:grey;'})));
      }
    } on SocketException {
      return "Unstable network";
    } catch (e) {
      return e.toString().substring(0, 45);
    }

    return "Success";
}

// H: Maps credit names to values.
Map<String, List<double>> mapReqs(List<String> types, List<String> amounts) {
  Map<String, List<double>> credits = {};
  types = cleanCreditNames(types);

  for (int i = 0; i < types.length; i++) {
    List<String> components = amounts[i].replaceAll(' of', '').split(' ');

    if (components[0][0] != '\$') {
      // removing Fees tracker from progress
      credits[types[i]] = [
        double.parse(components[0]),
        double.parse(components[1])
      ];
    }
  }

  return credits;
}

// H: Remove unnecessary verbiage
List<String> cleanCreditNames(List<String> rawCredits) {
  return Iterable<String>.generate(rawCredits.length, (i) {
    return rawCredits[i]
        .replaceAll(" Credit ", "")
        .replaceAll("Progress", "")
        .replaceAll("Hour", "");
  }).toList();
}

// H: Bs4Element to String
List<String> _stringsFromTags(List<Bs4Element> tags) {
  List<String> group = [];

  for (var tag in tags) {
    group.add(tag.text);
  }

  return group;
}

// Scrape user's upcoming events.
Future<String> scrapeUpcomingEvents(UserData user) async {
  http.Response raw;
  List<String> eventLinks = [];
  int eventQuantity = 1;

  try {
    // URL with event query
    String upcomingURL = user.http.baseURL + '?action=profile&panel=events';

    raw = await http.post(
      Uri.parse(upcomingURL),
      body: user.http.data,
      headers: user.http.headers,
    );
    user.http.upcomingEventsResponse = BeautifulSoup(raw.body);
    if (!verifyHTTP(user.http.upcomingEventsResponse)) {
      return "Not recognized";
    }

    // Gather all tags w/ event links.
    user.http.upcomingEventsResponse
        .findAll('div', attrs: {'class': 'calendar-title'}).forEach((tag) {
      eventLinks.add(user.http.baseURL + tag.a!['href']!);
    });

    // Process all links simultaneously.
    user.setUpcomingEvents(
        await Future.wait(Iterable.generate(eventLinks.length, (i) {
      return handleEvent(user.http.getHTTPTags(), user.http.baseURL,
          eventLinks[i], eventQuantity++);
    })));
  } on SocketException {
    return "Unstable network";
  } catch (e) {
    return e.toString().substring(0, 45);
  }

  // Sort events from sooner to later.
  user.upcomingEvents.sort((a, b) => a.compareTo(b));

  print("events passed");
  return "Success";
}