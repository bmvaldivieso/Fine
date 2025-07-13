import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_english_app/core/models/componente_model.dart';
import 'package:lms_english_app/core/models/matricula_model.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

class MatriculaService {
  final String _baseUrl =
      'http://localhost:8000/api'; // Para desarrollo en navegador
  final String _baseUrlMobile =
      'http://192.168.100.28:8000/api'; // Para dispositivos físicos

  // Obtener lista de componentes según programa_academico del estudiante
  Future<List<Componente>> getComponentesDisponibles() async {
    final accessToken = await AuthServiceLogin().getAccessToken();
    if (accessToken == null) {
      throw Exception("No se pudo obtener el token de acceso");
    }

    final url = Uri.parse('$_baseUrl/componentes/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final componentes = data['componentes'] as List;
      return componentes.map((json) => Componente.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener componentes: ${response.body}");
    }
  }

  // Registrar matrícula
  Future<bool> registrarMatricula(Matricula matricula) async {
    final accessToken = await AuthServiceLogin().getAccessToken();
    if (accessToken == null) {
      print("No se pudo obtener el token");
      return false;
    }

    final url = Uri.parse('$_baseUrl/matricula/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(matricula.toJson()),
    );

    if (response.statusCode == 200) {
      print("✔ Matrícula registrada");
      return true;
    } else {
      print("✘ Error al registrar matrícula: ${response.body}");
      return false;
    }
  }

  // Registrar datos pago
  Future<bool> registrarDatosPago({
    required int componenteId,
    required String metodoPago,
    String? referencia,
    String? monto,
    String? fechaDeposito,
    String? idDepositante,
    String? nombreTarjeta,
    String? numeroTarjeta,
    String? vencimiento,
    String? cvv,
  }) async {
    final accessToken = await AuthServiceLogin().getAccessToken();
    final url = Uri.parse('$_baseUrl/datos-pago/');

    final body = {
      'componente_id': componenteId,
      'metodo_pago': metodoPago,
      'referencia': referencia,
      'monto': monto,
      'fecha_deposito': fechaDeposito,
      'id_depositante': idDepositante,
      'nombre_tarjeta': nombreTarjeta,
      'numero_tarjeta': numeroTarjeta,
      'vencimiento': vencimiento,
      'cvv': cvv,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }
}
