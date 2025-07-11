import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {

  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrlIP = "http://192.168.100.28:8000/api";

  final _storage = const FlutterSecureStorage();

  Future<bool> Regis(
  String? tipoIdentificacion,
  String? identificacion,
  String? nombresApellidos,
  DateTime? fechaNacimiento,
  String? genero,
  String? ocupacion,
  String? nivelEstudio,
  String? lugarEstudioTrabajo,
  String? direccion,
  String? email,
  String? celular,
  String? telefonoConvencional,
  String? parroquia,
  String? programaAcademico,
  bool emitirFacturaAlEstudiante,
  String? rtipoIdentificacion,
  String? ridentificacion,
  String? razonSocial,
  String? rdireccion,
  String? remail,
  String? rcelular,
  String? rtelefonoConvencional,
  String? sexo,
  String? estadoCivil,
  String? origenIngresos,
  String? rparroquia,
  String? user,
  String? password
  ) async {
    final url = Uri.parse('$_baseUrl/registro/');

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tipoIdentificacion': tipoIdentificacion,
          'identificacion': identificacion,
          'nombresApellidos':nombresApellidos,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'genero':genero,
          'ocupacion':ocupacion,
          'nivelEstudio':nivelEstudio,
          'lugarEstudioTrabajo':lugarEstudioTrabajo,
          'direccion':direccion,
          'email':email,
          'celular':celular,
          'telefonoConvencional':telefonoConvencional,
          'parroquia':parroquia,
          'programaAcademico':programaAcademico,
          'emitirFactura':emitirFacturaAlEstudiante,
          'rTipoIdentificacion':rtipoIdentificacion,
          'ridentificacion':ridentificacion,
          'razonSocial':razonSocial,
          'rdireccion':rdireccion,
          'remail':remail,
          'rcelular':rcelular,
          'rtelefonoConvencional':rtelefonoConvencional,
          'sexo':sexo,
          'estadoCivil':estadoCivil,
          'origenIngresos':origenIngresos,
          'rparroquia':rparroquia,
          'user':user,
          'password':password
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
        print('Registro exitoso! Access Token: $accessToken y es superUsuario = $isSuperuser');
        return true;
      } else {
        print('Error de Registro: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción durante el Registro: $e');
      return false;
    }
  }
}
