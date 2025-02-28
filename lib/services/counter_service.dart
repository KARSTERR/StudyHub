import 'dart:convert';
import 'package:http/http.dart' as http;

class CounterService {
  final String baseUrl;

  CounterService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<int> getCounter(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/counters/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['value'];
      } else {
        throw Exception('Failed to load counter');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<int> updateCounter(String id, int value) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/counters/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'value': value}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['value'];
      } else {
        throw Exception('Failed to update counter');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}