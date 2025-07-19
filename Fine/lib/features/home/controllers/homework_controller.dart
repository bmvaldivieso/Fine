import 'package:get/get.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

class HomeworkController extends GetxController {
  var asignaciones = <dynamic>[].obs;
  var cargando = true.obs;

  Future<void> cargarAsignaciones() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();
      final datos = await HomeworkService().obtenerAsignaciones(token!);
      asignaciones.value = datos;
    } catch (e) {
      print('Error al cargar tareas: $e');
    } finally {
      cargando.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    cargarAsignaciones();
  }
}
