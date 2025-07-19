import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:lms_english_app/features/home/controllers/home_Controller.dart';

class SubmitHomeworkView extends StatefulWidget {
  final Map asignacion;

  const SubmitHomeworkView({super.key, required this.asignacion});

  @override
  State<SubmitHomeworkView> createState() => _SubmitHomeworkViewState();
}

class _SubmitHomeworkViewState extends State<SubmitHomeworkView> {
  List<Uint8List> archivos = [];
  List<String> nombresArchivos = [];
  TextEditingController enlaceController = TextEditingController();
  bool cargando = false;
  bool enviado = false;
  bool hayContenido = false;

  int usados = 0;
  int maximos = 0;

  @override
  void initState() {
    super.initState();
    cargarIntentos();
    verificarEntregaAnterior();
    enlaceController.addListener(() {
      final tieneTexto = enlaceController.text.trim().isNotEmpty;
      setState(() {
        hayContenido = archivos.isNotEmpty || tieneTexto;
      });
    });
  }

  Future<void> verificarEntregaAnterior() async {
    final token = await AuthServiceLogin().getAccessToken();
    final entregas = await HomeworkService()
        .consultarEntregas(token!, widget.asignacion['id']);

    if (entregas.isNotEmpty) {
      setState(() {
        enviado = true;
      });
    }
  }

  Future<void> cargarIntentos() async {
    final token = await AuthServiceLogin().getAccessToken();
    final datos = await HomeworkService()
        .obtenerIntentosRestantes(token!, widget.asignacion['id']);
    setState(() {
      usados = datos['intentos_usados'];
      maximos = datos['intentos_maximos'];
    });
  }

  Future<void> seleccionarArchivos() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (resultado != null) {
      final archivosValidos = resultado.files.where((e) {
        final ext = e.extension?.toLowerCase();
        return ext == 'pdf' || ext == 'docx';
      }).toList();

      if (archivosValidos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo se permiten archivos PDF o DOCX')),
        );
        return;
      }

      setState(() {
        archivos = archivosValidos.map((e) => e.bytes!).toList();
        nombresArchivos = archivosValidos.map((e) => e.name).toList();
        hayContenido =
            archivos.isNotEmpty || enlaceController.text.trim().isNotEmpty;
      });
    }
  }

  Future<void> enviarEntrega() async {
    final hayContenido =
        archivos.isNotEmpty || enlaceController.text.trim().isNotEmpty;
    if (!hayContenido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes adjuntar al menos un archivo o enlace')),
      );
      return;
    }

    if ((maximos - usados) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya no tienes intentos disponibles')),
      );
      return;
    }

    final token = await AuthServiceLogin().getAccessToken();
    if (token == null) return;

    setState(() => cargando = true);

    try {
      final exito = await HomeworkService().entregarTarea(
        token: token,
        asignacionId: widget.asignacion['id'],
        archivos: archivos,
        nombres: nombresArchivos,
        enlace: enlaceController.text.trim().isNotEmpty
            ? enlaceController.text.trim()
            : null,
      );

      if (exito) {
        await cargarIntentos();

        setState(() {
          enviado = true;
          cargando = false;
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('✅ Entrega exitosa'),
            content: const Text('Tu tarea fue enviada correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/review-submission',
                      arguments: widget.asignacion);
                },
                child: const Text('Revisar entrega'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al entregar la tarea')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarea = widget.asignacion;
    final intentosDisponibles = maximos - usados;

    final fechaEntregaRaw = tarea['fecha_entrega'];
    final fechaEntrega = DateTime.parse(fechaEntregaRaw);
    final fechaFormateada =
        DateFormat('dd/MM/yyyy – HH:mm').format(fechaEntrega);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title:
            const Text('Entregar Tarea', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final homeController = Get.find<HomeController>();
            homeController.changeTab(8); // 👈 vuelve a HomeworkView
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tarea['titulo'] ?? 'Sin título',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea['descripcion'] ?? 'Sin descripción',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Fecha de entrega: $fechaFormateada',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.repeat, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Intentos disponibles: $intentosDisponibles de $maximos',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: seleccionarArchivos,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text('Seleccionar archivos',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2845B9),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
              const SizedBox(height: 12),
              ...nombresArchivos.map((nombre) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(child: Text(nombre)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Text(
                'Se permiten enlaces',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: enlaceController,
                decoration: const InputDecoration(
                  hintText: 'https://ejemplo.com/tarea',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              cargando
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: hayContenido && intentosDisponibles > 0
                              ? enviarEntrega
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2042A6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            '📨 Entregar',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
              if (enviado) ...[
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      if (tarea['id'] != null) {
                        Navigator.pushNamed(context, '/review-submission',
                            arguments: tarea);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'No se puede revisar sin una tarea válida')),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Revisar entrega'),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
