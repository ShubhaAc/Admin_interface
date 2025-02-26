import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static const String baseUrl = 'http://localhost:3000'; 

  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      body: json.encode(updatedData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
}
