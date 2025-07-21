import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anuncio_model.dart';
import '../models/anuncio_detalle_model.dart';

Future<List<Anuncio>> obtenerAnuncios(String token) async {
  final String baseUrl = 'http://localhost:8000/api';

    final response = await http.get(
      Uri.parse('$baseUrl/estudiante/anuncios/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

  if (response.statusCode == 200) {
    final List jsonData = json.decode(response.body);
    return jsonData.map((a) => Anuncio.fromJson(a)).toList();
  } else {
    throw Exception('Error al cargar los anuncios');
  }
}

Future<AnuncioDetalle> obtenerDetalleAnuncio(int id, String token) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/estudiante/anuncio/$id/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return AnuncioDetalle.fromJson(jsonData);
  } else {
    throw Exception('Error al cargar detalle del anuncio');
  }
}
