import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

class EstudianteService {
  final String perfilUrl = 'http://localhost:8000/api/estudiante/perfil/'; //Para chrome

  Future<String> obtenerNombre() async {
    final token = await AuthServiceLogin().getAccessToken();

    final response = await http.get(
      Uri.parse(perfilUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['nombres_apellidos'];
    } else {
      throw Exception('Error al obtener nombre del estudiante');
    }
  }
}
