import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
  final String name;
  final String job;

  Post({required this.name, required this.job});

  Future<bool> sendData() async {
    var url = Uri.parse('https://dummyjson.com/users/add');
    var response = await http.post(url,
      headers: {'Content-Type': 'application/json'}, body: jsonEncode({'firstName': name, 'lastName': job}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('User added: $name');
      return true;
    }
    print('Error: ${response.statusCode}');return false;
  }
}