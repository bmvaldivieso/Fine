import 'package:flutter/material.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/core/services/service_MatriculaValidate.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:lms_english_app/features/home/controllers/home_Controller.dart';
import 'package:lms_english_app/utils/navigation_helper.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class HomeworkView extends StatefulWidget {
  const HomeworkView({super.key});

  @override
  State<HomeworkView> createState() => _HomeworkViewState();
}

class _HomeworkViewState extends State<HomeworkView> {
  List<dynamic> asignaciones = [];
  bool cargando = true;
  bool _tieneMatricula = false;
  final _homeController = Get.find<HomeController>();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAsignaciones();
    _verificarMatricula();
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

  void _verificarMatricula() async {
    final authService = MatService();
    bool resultado = await authService.validarMatricula();
    if (!mounted) return;
    if (!resultado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeController.gotoHomeWithIndex(5, transitionType: 'offAll');
      });
    } else {
      setState(() {
        _tieneMatricula = true;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      appBar: AppBar(
        title: const Text('📚 Mis Tareas'),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : asignaciones.isEmpty
              ? const Center(
                  child: Text(
                    '📝 No hay tareas asignadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: asignaciones.length,
                  itemBuilder: (context, index) {
                    final tarea = asignaciones[index];
                    final entregado = tarea['entregado'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            goToSubmitHomework(context, tarea);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.assignment_turned_in,
                                        color: Color(0xFF2042A6)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tarea['titulo'] ?? 'Sin título',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2042A6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fecha límite: ${formatearFecha(tarea['fecha_entrega'])}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: entregado
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        entregado
                                            ? 'Estado: Entregado'
                                            : 'Estado: Pendiente',
                                        style: TextStyle(
                                          color: entregado
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      goToSubmitHomework(context, tarea);
                                    },
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    label: const Text("Ver detalles"),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF2042A6),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
