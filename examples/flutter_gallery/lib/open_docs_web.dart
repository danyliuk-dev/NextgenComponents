import 'package:web/web.dart' as web;

void openDocs(String page) {
  web.window.open(
    'http://127.0.0.1:5182/docs/manual/$page',
    '_blank',
    'noopener',
  );
}
