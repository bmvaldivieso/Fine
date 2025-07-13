import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_english_app/core/models/componente_model.dart';
import 'package:lms_english_app/features/auth/services/matricula_service.dart';

class ComponentesView extends StatefulWidget {
  const ComponentesView({super.key});

  @override
  State<ComponentesView> createState() => _ComponentesViewState();
}

class _ComponentesViewState extends State<ComponentesView> {
  final MatriculaService _matriculaService = MatriculaService();
  bool _loading = true;
  List<Componente> _componentes = [];

  @override
  void initState() {
    super.initState();
    _cargarComponentes();
  }

  void _cargarComponentes() async {
    try {
      final result = await _matriculaService.getComponentesDisponibles();
      if (!mounted) return;
      setState(() {
        _componentes = result;
        _loading = false;
      });
    } catch (e) {
      print("Error al obtener componentes: $e");
      setState(() => _loading = false);
    }
  }

  void _irADetalle(Componente componente) {
    Get.toNamed('/detalle-curso', arguments: componente);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF7F96E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        elevation: 0,
        title: const Text('Selecciona tu paralelo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _componentes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay cursos disponibles para tu programa académico.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: _componentes.map((componente) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              componente.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Programa: ${componente.programaAcademico}"),
                            Text("Periodo: ${componente.periodo}"),
                            Text("Horario: ${componente.horario}"),
                            Text("Precio: \$${componente.precio}"),
                            Text("Cupos disponibles: ${componente.cuposDisponibles}"),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _irADetalle(componente),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Seleccionar Curso', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2042A6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
