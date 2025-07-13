import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lms_english_app/core/models/nota_bimestre_model.dart';
import 'package:lms_english_app/core/services/notas_service.dart';
import 'package:lms_english_app/widgets/grades_table.dart';
import 'package:lms_english_app/widgets/level_selector.dart';
import 'package:lms_english_app/widgets/notes_header.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  Map<String, List<NotaBimestre>> notasPorComponente = {};
  List<String> componentesDisponibles = [];
  List<NotaBimestre> notasActuales = [];
  double notaFinal = 0;
  int totalInasistencias = 0;
  bool cargando = true;
  String nombreEstudiante = '';

  @override
  void initState() {
    super.initState();
    cargarNombreEstudiante();
    cargarNotas();
  }

  Future<void> cargarNombreEstudiante() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/estudiante/perfil/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => nombreEstudiante = data['nombres_apellidos']);
      } else {
        print('Error al obtener nombre: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener nombre: $e');
    }
  }

  Future<void> cargarNotas() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();
      final resultado = await NotasService().obtenerNotas(token!);

      setState(() {
        notasPorComponente = resultado;
        componentesDisponibles = resultado.keys.toList();
        cargando = false;

        if (componentesDisponibles.isNotEmpty) {
          actualizarComponenteSeleccionado(componentesDisponibles.first);
        }
      });
    } catch (e) {
      print('Error al cargar notas: $e');
      setState(() => cargando = false);
    }
  }

  void actualizarComponenteSeleccionado(String componente) {
    final notas = notasPorComponente[componente] ?? [];

    final promedio = notas.length == 2
        ? (notas[0].notaBimestre + notas[1].notaBimestre) / 2
        : (notas.isNotEmpty ? notas.first.notaBimestre : 0);

    final inasistencias =
        notas.fold<int>(0, (total, n) => total + n.inasistencias);

    setState(() {
      notasActuales = notas;
      notaFinal = promedio.toDouble();
      totalInasistencias = inasistencias;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notas del Estudiante',
            style: TextStyle(color: Colors.white)),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NotesHeader(studentname: nombreEstudiante),
                      const SizedBox(height: 12),
                      LevelSelector(
                        componentes: componentesDisponibles,
                        onSelected: actualizarComponenteSeleccionado,
                      ),
                      const SizedBox(height: 25),
                      if (notasActuales.isNotEmpty) ...[
                        GradesTable(notas: notasActuales),
                        const SizedBox(height: 20),
                        Text(
                          "Nota Final: ${notaFinal.toStringAsFixed(1)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF2845B9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Inasistencias: $totalInasistencias",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            color: const Color(0xFF9F2D70),
                          ),
                        ),
                      ] else ...[
                        const Center(
                            child: Text(
                                "No hay notas registradas para este componente."))
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
