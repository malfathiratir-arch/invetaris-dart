import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String username, String password) async {
    final url = "${ApiConfig.baseUrl}/login";

    print("Menembak ke URL: $url");
    print("Data yang dikirim: username=$username, password=$password");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      print("Status Code dari Server: ${response.statusCode}");
      print("Respon Body dari Server: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Membongkar JSON nested sesuai struktur respon api
        final String token = responseData['data']['token'];
        final String name = responseData['data']['user']['name'];

        // Simpan token dan nama ke memori lokal HP (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('name', name);

        print("BEARER TOKEN BERHASIL DISIMPAN: $token");
        print("NAMA USER BERHASIL DISIMPAN: $name");

        return true;
      } else {
        print(
          "Login gagal: Server merespon dengan status ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print('Error Login pada block catch: $e');
      return false;
    }
  }
}