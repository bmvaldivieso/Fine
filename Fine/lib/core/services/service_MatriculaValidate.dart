import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

class MatService {

  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrlIP = "http://192.168.100.28:8000/api";

  Future<bool> validarMatricula() async {

    final accessToken = await AuthServiceLogin().getAccessToken();
    if (accessToken == null) {
      print('No hay token de acceso.');
      return false;
    }

    final url = Uri.parse('$_baseUrl/notas/');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken',},);
      if (response.statusCode == 200) {
        print("✔ Matrícula válida");
        return true;
      } else {
        print("tokken de acceso");
        print(accessToken);
        print("✘ No tiene matrícula: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error al validar matrícula: $e');
      return false;
    }
  }
}
