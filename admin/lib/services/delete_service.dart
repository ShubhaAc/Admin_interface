//import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteService {
  static const String baseUrl = 'http://localhost:3000'; 

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
