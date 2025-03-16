// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final _secureStorage = const FlutterSecureStorage();

  AuthService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store token in secure storage
        await _secureStorage.write(
          key: 'access_token',
          value: data['access_token'],
        );
        await _secureStorage.write(
          key: 'username',
          value: data['user']['username'],
        );
        await _secureStorage.write(
          key: 'user_id',
          value: data['user']['id'].toString(),
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<bool> register(
      String username,
      String password, {
        String? email,
        String? fullName,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          if (email != null) 'email': email,
          if (fullName != null) 'full_name': fullName,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Store token in secure storage
        await _secureStorage.write(
          key: 'access_token',
          value: data['access_token'],
        );
        await _secureStorage.write(
          key: 'username',
          value: data['username'],
        );
        await _secureStorage.write(
          key: 'user_id',
          value: data['user_id'].toString(),
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<bool> logout() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<String?> getUsername() async {
    return await _secureStorage.read(key: 'username');
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }
}