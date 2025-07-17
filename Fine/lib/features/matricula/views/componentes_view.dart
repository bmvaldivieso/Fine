import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_english_app/core/models/componente_model.dart';
import 'package:lms_english_app/features/auth/services/matricula_service.dart';
import 'package:iconsax/iconsax.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        elevation: 2,
        title: const Text('Selecciona tu paralelo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E2D5E)))
          : _componentes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay cursos disponibles para tu programa académico.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04, vertical: 20),
                  itemCount: _componentes.length,
                  itemBuilder: (context, index) {
                    final componente = _componentes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Iconsax.teacher,
                                  color: Color(0xFF1E2D5E), size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  componente.nombre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2D5E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(Iconsax.book, 'Programa',
                              componente.programaAcademico),
                          _infoRow(
                              Iconsax.calendar, 'Periodo', componente.periodo),
                          _infoRow(
                              Iconsax.clock, 'Horario', componente.horario),
                          _infoRow(Iconsax.money_2, 'Precio',
                              '\$${componente.precio}'),
                          _infoRow(Iconsax.people, 'Cupos disponibles',
                              '${componente.cuposDisponibles}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 180, // ✅ Puedes ajustar este valor
                                child: ElevatedButton.icon(
                                  onPressed: () => _irADetalle(componente),
                                  icon: const Icon(Iconsax.tick_square,
                                      color: Colors.white),
                                  label: const Text('Seleccionar Curso',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53E3E),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E2D5E)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
