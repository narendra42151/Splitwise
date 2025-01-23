import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupUpdateRepository {
  final String baseUrl;

  GroupUpdateRepository({required this.baseUrl});

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/groups/$groupId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update group');
    }
  }
}
