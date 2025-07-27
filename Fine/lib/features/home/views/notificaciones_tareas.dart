import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lms_english_app/core/models/notification_model.dart';
import 'package:lms_english_app/core/services/notification_service.dart';
import 'package:lms_english_app/core/services/service_MatriculaValidate.dart';
import 'package:lms_english_app/features/home/controllers/home_Controller.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  late Future<List<NotificationModel>> _futureNotificaciones;
  final _homeController = Get.find<HomeController>();
  bool _tieneMatricula = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _futureNotificaciones = NotificationService().fetchNotifications();
    _verificarMatricula();
  }

  void _verificarMatricula() async {
    final authService = MatService();
    bool resultado = await authService.validarMatricula();
    if (!mounted) return;
    if (!resultado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeController.gotoHomeWithIndex(5, transitionType: 'offAll');
      });
    } else {
      if (!mounted) return;
      setState(() {
        _tieneMatricula = true;
        _cargando = false;
      });
    }
  }

  String formatearFecha(String fechaOriginal) {
    final dateTime = DateTime.parse(fechaOriginal);
    return DateFormat('dd MMM yyyy – HH:mm').format(dateTime);
  }

  IconData obtenerIcono(String tipo) {
    switch (tipo) {
      case 'nueva_tarea':
        return Icons.assignment_outlined;
      case 'cambio_fecha':
        return Icons.calendar_today_outlined;
      case 'calificacion':
        return Icons.grade_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color obtenerColor(String tipo) {
    switch (tipo) {
      case 'nueva_tarea':
        return Colors.blueAccent;
      case 'cambio_fecha':
        return Colors.orange;
      case 'calificacion':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget construirContenido(NotificationModel notif) {
    final fecha = formatearFecha(notif.fecha);

    Widget encabezado(String texto) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0150),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }

    switch (notif.tipo) {
      case 'cambio_fecha':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            encabezado('Tarea'),
            Text('📝 ${notif.descripcion}'),
            Text('⏰ Fecha: $fecha'),
          ],
        );

      case 'calificacion':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            encabezado('Tarea'),
            Text('📌 Tarea-Calificada: ${notif.tareaTitulo ?? 'Sin título'}'),
            if (notif.calificacion != null)
              Text('⭐ Calificación: ${notif.calificacion}'),
            Text('⏰ Fecha: $fecha'),
          ],
        );

      case 'nueva_tarea':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            encabezado('Tarea'),
            Text('📌 Tarea-Creada: ${notif.tareaTitulo ?? 'Sin título'}'),
            Text('⏰ Fecha: $fecha'),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            encabezado('Tarea'),
            Text('📣 ${notif.descripcion}'),
            Text('⏰ Fecha: $fecha'),
          ],
        );
    }
  }

  void verNotificacion(NotificationModel notif) {
    final homeController = Get.find<HomeController>();
    homeController.changeTab(8);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 137, 160, 236),
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2042A6),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _futureNotificaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('🚨 Error al cargar: ${snapshot.error}'),
            );
          }

          final notificaciones = snapshot.data!;
          if (notificaciones.isEmpty) {
            return const Center(
              child: Text('✨ No hay notificaciones nuevas.'),
            );
          }

          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notif = notificaciones[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xD9FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: obtenerColor(notif.tipo), width: 2.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: obtenerColor(notif.tipo),
                      child:
                          Icon(obtenerIcono(notif.tipo), color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: construirContenido(notif)),
                    TextButton(
                      onPressed: () => verNotificacion(notif),
                      child: const Text(
                        'Ver',
                        style: TextStyle(color: Color(0xFFD9B70D)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
