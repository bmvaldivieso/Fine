import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class HomeworkService {
  final String baseUrl = 'http://localhost:8000/api';

  // Obtener asignaciones publicadas
  Future<List<dynamic>> obtenerAsignaciones(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/asignaciones/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener asignaciones: ${response.statusCode}');
    }
  }

  // Entregar tarea con archivos y enlaces
  Future<bool> entregarTarea({
    required String token,
    required int asignacionId,
    required List<Uint8List> archivos,
    required List<String> nombres,
    String? enlace,
  }) async {
    final uri = Uri.parse('$baseUrl/asignaciones/$asignacionId/entregar/');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Agregar archivos
    for (int i = 0; i < archivos.length; i++) {
      final nombre = nombres[i];
      final mime = lookupMimeType(nombre) ?? 'application/octet-stream';

      request.files.add(http.MultipartFile.fromBytes(
        'archivo_$i',
        archivos[i],
        filename: nombre,
        contentType: MediaType.parse(mime),
      ));
    }

    // Agregar enlace si existe
    if (enlace != null && enlace.isNotEmpty) {
      request.fields['enlace'] = enlace;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al entregar tarea: ${response.statusCode}');
    }
  }

  // Consultar entregas realizadas
  Future<List<dynamic>> consultarEntregas(
      String token, int asignacionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/asignaciones/$asignacionId/entrega/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['entregas'] ?? [];
    } else {
      throw Exception('Error al consultar entregas: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> obtenerIntentosRestantes(
      String token, int asignacionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/asignaciones/$asignacionId/intentos/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al consultar intentos');
    }
  }
}
