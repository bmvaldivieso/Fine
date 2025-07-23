import 'package:flutter/material.dart';
import 'package:lms_english_app/core/models/notification_model.dart';
import 'package:lms_english_app/core/services/notification_service.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  late Future<List<NotificationModel>> _futureNotificaciones;

  @override
  void initState() {
    super.initState();
    _futureNotificaciones = NotificationService().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Notificaciones')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _futureNotificaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final notificaciones = snapshot.data!;
          if (notificaciones.isEmpty) {
            return const Center(child: Text('No hay notificaciones disponibles.'));
          }

          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notif = notificaciones[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    notif.tipo == 'nueva_tarea'
                        ? Icons.assignment
                        : notif.tipo == 'cambio_fecha'
                          ? Icons.calendar_today
                          : Icons.grade,
                    color: Colors.indigo,
                  ),
                  title: Text(notif.descripcion),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notif.tareaTitulo != null) Text('Tarea: ${notif.tareaTitulo}'),
                      if (notif.componente != null) Text('Componente: ${notif.componente}'),
                      if (notif.calificacion != null) Text('Calificación: ${notif.calificacion}'),
                      if (notif.intentoNumero != null) Text('Intento: ${notif.intentoNumero}'),
                      Text('Fecha: ${notif.fecha}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
