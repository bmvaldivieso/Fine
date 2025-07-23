import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import '../models/notification_model.dart';

class NotificationService {
  final String baseUrl = 'http://localhost:8000/api';

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await AuthServiceLogin().getAccessToken();
    final estudianteId = await AuthServiceLogin().getUserId();

    final url = Uri.parse('$baseUrl/notificaciones/estudiante/$estudianteId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar notificaciones: ${response.statusCode}');
    }
  }
}
