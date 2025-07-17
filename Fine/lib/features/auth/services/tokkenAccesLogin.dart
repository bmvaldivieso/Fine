import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthServiceLogin {

  //final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String _baseUrl = 'http://localhost:8000/api';
  final String baseUrlIP = "http://192.168.100.28:8000/api";

  final _storage = const FlutterSecureStorage();

  Future<void> cerrarSesion() async {
    await _storage.delete(key: 'access_token');
    Get.offAllNamed('/login');
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/token/');

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String accessToken = data['access'];
        final String refreshToken = data['refresh'];
        final bool isSuperuser = data['is_superuser'] ?? false;

        // Almacenar los tokens de forma segura
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _storage.write(key: 'is_superuser', value: isSuperuser.toString());

        print('Login exitoso! Access Token: $accessToken y es superUsuario = $isSuperuser');
        return true;
      } else {
        print('Error de login: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante el login: $e');
      return false;
    }
  }







  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'is_superuser');
  }








  // Ejemplo de cómo hacer una solicitud autenticada
  Future<Map<String, dynamic>?> fetchAdminData() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No hay token de acceso. Por favor, inicie sesión.');
      return null;
    }

    final url = Uri.parse('$_baseUrl/admin/'); // Tu endpoint protegido
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al obtener datos de admin: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener datos de admin: $e');
      return null;
    }
  }
}
