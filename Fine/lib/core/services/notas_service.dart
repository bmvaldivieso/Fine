import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nota_bimestre_model.dart';

class NotasService {
  final String baseUrl = 'http://localhost:8000/api/notas/'; //Para chrome

  Future<Map<String, List<NotaBimestre>>> obtenerNotas(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Notas JSON: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);

      if (decoded is! List) {
        throw Exception('La respuesta no contiene una lista de notas');
      }

      final List<dynamic> datos = decoded;

      final Map<String, List<NotaBimestre>> resultado = {};

      for (var item in datos) {
        final String componente = item['componente'];
        final List<dynamic> notasJson = item['notas'];

        final List<NotaBimestre> notas = notasJson
            .map((notaJson) => NotaBimestre.fromJson(notaJson))
            .toList();

        resultado[componente] = notas;
      }

      return resultado;
    } else {
      throw Exception('Error al consultar las notas: ${response.statusCode}');
    }
  }
}
