import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<bool> deleteUser(int id) async {
  var url = Uri.parse('https://dummyjson.com/users/$id');
  var response = await http.delete(url);
  if (response.statusCode == 200) {
    print('User $id deleted');
    return true;
  }
  print('Error: ${response.statusCode}');
  return false;
}