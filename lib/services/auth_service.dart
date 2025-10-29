import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http; // Import pour http
import '../config/app_config.dart'; // Import pour AppConfig

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';
  static const _userKey = 'user_data';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        return data;
      } else {
        throw Exception(data['message'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<void> registerClient(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        body: jsonEncode(userData),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 201 || !data['success']) {
        throw Exception(data['message'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: ${e.toString()}');
    }
  }

  static Future<String?> getUserRole() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      return user['role'];
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    return userJson != null ? jsonDecode(userJson) : null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}


