import 'package:flutter/material.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:lms_english_app/utils/navigation_helper.dart';
import 'package:intl/intl.dart';

class HomeworkView extends StatefulWidget {
  const HomeworkView({super.key});

  @override
  State<HomeworkView> createState() => _HomeworkViewState();
}

class _HomeworkViewState extends State<HomeworkView> {
  List<dynamic> asignaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAsignaciones();
  }

  Future<void> cargarAsignaciones() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();
      final datos = await HomeworkService().obtenerAsignaciones(token!);
      setState(() {
        asignaciones = datos;
        cargando = false;
      });
    } catch (e) {
      print('Error al cargar tareas: $e');
      setState(() => cargando = false);
    }
  }

  String formatearFecha(String fecha) {
    final dateTime = DateTime.parse(fecha);
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      appBar: AppBar(
        title: const Text('Mis tareas asignadas'),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : asignaciones.isEmpty
              ? const Center(child: Text('No hay tareas disponibles'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: asignaciones.length,
                  itemBuilder: (context, index) {
                    final tarea = asignaciones[index];
                    final entregado = tarea['entregado'] ?? false;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        title: Text(
                          tarea['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha límite: ${formatearFecha(tarea['fecha_entrega'])}'),
                            const SizedBox(height: 5),
                            Text(
                              entregado ? 'Estado: Entregado' : 'Estado: Pendiente',
                              style: TextStyle(
                                color: entregado ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          goToSubmitHomework(context, tarea);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
