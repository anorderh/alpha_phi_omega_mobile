import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/EventPage/Events.dart';
import 'package:example/Backend/apo_objects.dart';

String base_url = 'https://www.apoonline.org/alphadelta/memberhome.php';


Map<String, String> data = {
  'redirect': 'memberhome.php',
  'submit': 'Log In',
  // '__csrf_magic' : 'sid:8b9cc0dfe0aa8077cd5bdfc7a111bf19a7869aa4,1642106437'
};

Map<String, String> headers = {
  // 'Cookie': 'PHPSESSID=ibme3ub48cf8vvg28g9rv4khi2',
  'Accept-Encoding': 'gzip, deflate, br'
};


Future<BeautifulSoup> initHTTP(String user, String pw) async {
  data['email'] = user;
  data['password'] = pw;
  headers.remove('Cookie');
  headers.remove('__csrf_magic');

  print("REQUEST #1: RETRIEVING PHPSESSID");
  var response = await http.post(
    Uri.parse(base_url),
    body: data,
    headers: headers,
  );
  headers['Cookie'] = response.headers['set-cookie']!.split(';')[0];
  print(headers['Cookie']);

  print("REQUEST #2: RETRIEVING CSRF");
  response = await http.post(
    Uri.parse(base_url),
    body: data,
    headers: headers,
  );
  data['__csrf_magic'] = BeautifulSoup(response.body).find('input')!['value']!;
  print(data['__csrf_magic']);

  print("REQUEST 3: VALIDATING LOGIN");
  response = await http.post(
    Uri.parse(base_url),
    body: data,
    headers: headers,
  );

  return BeautifulSoup(response.body);
}


Future<Map<String, dynamic>> profileDetails(BeautifulSoup soup) async {
  Map<String, dynamic> details = {};

  details['name'] =
      _spaceString(soup.find('div', attrs: {'id': 'topheader-name'})!.text);
  details['image_url'] =
      'https://www.apoonline.org/alphadelta/' + soup.find('img')!['src']!;

  details['progress'] = mapCredits(
    _stringsFromTags(soup.findAll( // credit names
        'a', attrs: {'style':'margin-bottom: .5em;display: block;color:black;'})),
    _stringsFromTags(soup.findAll( // credit amounts
          'span', attrs: {'style':'float:right; color:grey;'})));

  details['position'] = await retrievePosition(details['name']);
  details ['upcomingEvents'] = retrieveUpcoming(
      soup.findAll('div', attrs: {'class':'calendar-infobox'}));

  return details;
  }


  String _spaceString(String input) {
    for (int i = 1; i < input.length; i++) {
      if (input[i] == input[i].toUpperCase()) {
        input =
            input.substring(0, i) + ' ' + input.substring(i, input.length);
        break;
      }
    }
    return input;
  }

  Future<String> retrievePosition(String name) async {
    var response = await http.post(
      Uri.parse(base_url + '?action=brothers'),
      body: data,
      headers: headers,
    );
    var soup = BeautifulSoup(response.body).find('section', attrs: {'id': 'body'})!;
    List<Bs4Element> officers = soup.find('div', attrs: {'id': 'officers'})!
        .findAll('div', attrs: {'style':'padding: 5px 0px;display: grid;grid-template-columns: min-content auto;grid-column-gap: 8px;'});

    for (var officer in officers) {
      if (officer.nodes[1].text == name) {
        return officer.find('div', attrs: {'style':'font-size: 0.9em;color: #666;'})!.text;
      }
    }

    List<Bs4Element> actives =
        soup.find('div', attrs: {'id': 'actives'})!.findAll('div', attrs: {'style':'padding: 5px 0px;'})
            ..addAll(
            soup.find('div', attrs: {'id': 'bad standing'})!.findAll('div', attrs: {'style':'padding: 5px 0px;'})
        );

    for (var active in actives) {
      if (active.a!.text == name) {
        return 'Active';
      }
    }

    List<Bs4Element> pledges = soup.find('div', attrs: {'id': 'pledges'})!
        .findAll('div', attrs: {'style':'padding: 5px 0px;'});

    for (var pledge in pledges) {
      if (pledge.a!.text == name) {
        return 'Pledge';
      }
    }

    return 'Associate/Alumni/LOA';
  }


  List<String> _stringsFromTags(List<Bs4Element> tags) {
    List<String> group = [];

    for (var tag in tags) {
      group.add(tag.text);
    }

    return group;
  }

  Map<String, List<double>> mapCredits(List<String> types, List<String> amounts) {
    Map<String, List<double>> credits = {};

    for (var type in types) {
      List<String> components = amounts[0].replaceAll(' of', '').split(' ');

      if (components[0][0] != '\$') { // removing Fees tracker from progress
        credits[type] = [double.parse(components[0]), double.parse(components[1])];
      }

      amounts.removeAt(0);
    }

    return credits;
  }

  List<String> retrieveUpcoming(List<Bs4Element> tags) {
    List<String> eventLinks = [];
    for (Bs4Element tag in tags) {
      eventLinks.add(base_url + tag.find('a')!['href']!);
    }

    return eventLinks;

  }


