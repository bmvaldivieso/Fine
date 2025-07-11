import 'dart:convert';
import 'package:http/http.dart' as http;

class CodService {

  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrlIP = "http://192.168.100.28:8000/api";


  Future<bool> cod(String email) async {
    final url = Uri.parse('$_baseUrl/cod/');

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'email': email}),);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String message = data['message'];
        print('codigo Enviado Correctamente $message');
        return true;
      } else {
        print('Error al enviar codigo: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante el login: $e');
      return false;
    }
  }

  Future<bool> verifCod(String cod,String correo) async {
    final url = Uri.parse('$_baseUrl/verif/');

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'codigo': cod,'email':correo}),);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool success = data['success'] ?? false;
        final String message = data['message'] ?? '';
        print('Respuesta de Django: $message');
        return success;
      } else {
        print('Error al verificar código con Django: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante la verificación con Django: $e');
      return false;
    }
  }

}
