import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  String username = 'admin';
  String password = 'admin';
  String basicAuth;
  final String url;

  NetworkHelper(this.url) {
    basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  Future getData() async {
    http.Response response = await http.get(Uri.parse(url),
        headers: <String, String>{'authorization': basicAuth});
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      return response.statusCode;
    }
  }
}
