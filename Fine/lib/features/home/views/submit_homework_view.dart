import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';

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
    print('Asignación recibida: ${widget.asignacion}');
    print(
        'ID de asignación: ${widget.asignacion['id']} (${widget.asignacion['id'].runtimeType})');

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
            title: const Text('¡Entrega exitosa!'),
            content: const Text('Tu tarea fue enviada correctamente'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialogo
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
      print('Error al entregar: $e');
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al entregar la tarea')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarea = widget.asignacion;
    final hayContenido =
        archivos.isNotEmpty || enlaceController.text.trim().isNotEmpty;
    final intentosDisponibles = maximos - usados;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F8),
      appBar: AppBar(
        title: const Text('Entregar tarea'),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
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
              const SizedBox(height: 12),
              Text(tarea['descripcion'] ?? 'Sin descripción'),
              const SizedBox(height: 20),
              Text('Fecha de entrega: ${tarea['fecha_entrega']}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Text('Intentos restantes: $intentosDisponibles de $maximos',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              ElevatedButton.icon(
                onPressed: seleccionarArchivos,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar archivo'),
              ),
              const SizedBox(height: 12),
              ...nombresArchivos.map((nombre) => Text('📄 $nombre')).toList(),
              const SizedBox(height: 20),
              TextField(
                controller: enlaceController,
                decoration: const InputDecoration(
                  labelText: 'Enlace adicional (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: hayContenido && intentosDisponibles > 0
                          ? enviarEntrega
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2845B9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: const Text(
                        'Entregar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              if (enviado) ...[
                const SizedBox(height: 20),
                TextButton(
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
                  child: const Text('Revisar entrega'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
