import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> putting(String name, String job, int id) async {
  var url = Uri.parse('https://dummyjson.com/users/$id');
  var response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'firstName': name, 'lastName': job}),
  );
  if (response.statusCode == 200) {
    print('Updated user $id');
    return true;
  }
  print('Error: ${response.statusCode}');
  return false;
}