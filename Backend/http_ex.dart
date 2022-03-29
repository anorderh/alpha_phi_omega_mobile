import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

void main() async {
  // Fetch Google search results for "flutter blogs".
  final response = await http
      .get(Uri.parse('https://www.google.com/search?q=flutter+blogs'));
  final document = html_parser.parse(response.body);

  // Google has the best class names.
  final results = document.getElementsByClassName('BNeawe vvjwJb AP7Wnd');

  print('Top 10 results for "flutter blogs":\n\n');

  var placement = 1;
  for (final result in results) {
    print('#$placement: ${result.text}');
    placement++;
  }
}