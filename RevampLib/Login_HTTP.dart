import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:example/RevampLib/AppData.dart';

Future<void> initHTTP(String user, String pw) async {
  UserHTTP _http = mainUser.http;

  // update user & pw
  _http.data['email'] = user;
  _http.data['password'] = pw;

  // clear cookie & csrf magic stored prior
  _http.headers.remove('Cookie');
  _http.headers.remove('__csrf_magic');

  print("REQUEST #1: RETRIEVING PHPSESSID");
  var response = await http.post(
    Uri.parse(base_url),
    body: _http.data,
    headers: _http.headers,
  );
  _http.headers['Cookie'] = response.headers['set-cookie']!.split(';')[0];
  print(_http.headers['Cookie']);

  print("REQUEST #2: RETRIEVING CSRF");
  response = await http.post(
    Uri.parse(base_url),
    body: _http.data,
    headers: _http.headers,
  );
  _http.data['__csrf_magic'] = BeautifulSoup(response.body).find('input')!['value']!;
  print(_http.data['__csrf_magic']);

  print("REQUEST 3: VALIDATING LOGIN");
  response = await http.post(
    Uri.parse(base_url),
    body: _http.data,
    headers: _http.headers,
  );

  _http.homeResponse = BeautifulSoup(response.body);

  if (verifyHTTP(_http)) {
    mainUser.http = _http;
    mainUser.email = user;
  }
}

bool verifyHTTP(UserHTTP _http) {
  if (_http.homeResponse.find('div', attrs: {'id': 'topheader-name'}) != null) {
    _http.validLogin = true;
    return true;
  } else {
    return false;
  }
}