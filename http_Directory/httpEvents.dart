import 'package:http/http.dart' as http;
import 'http.dart' as local_http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/EventPage/Events.dart';

String add_url =
    'https://www.apoonline.org/alphadelta/memberhome.php?action=eventattendeeadd';
String remove_url =
    'https://www.apoonline.org/alphadelta/memberhome.php?action=eventattendeeremove';
String __csrf_magic = local_http.data['__csrf_magic']!;

void addSelf(int id, String comment, int haveCar, int driveOthers) async {
  Map<String, String> data = {
    '__csrf_magic':  __csrf_magic,
    'eventid': id.toString(),
    'user[comments]': comment,
    'user[haveCar]': haveCar.toString(),
    'user[drivehowmanyothers]': driveOthers.toString()
  };

  http.Response response = await http.post(
      Uri.parse(add_url),
      body: data,
      headers: local_http.headers);

  // print(response.statusCode);
  // print(response.body);
}

void removeSelf(int id) async {
  String queryURL = remove_url + '&eventid=$id';

  http.Response response = await http.get(
      Uri.parse(queryURL),
      headers: local_http.headers);

  // print(response.statusCode);
  // print(response.body);
}
