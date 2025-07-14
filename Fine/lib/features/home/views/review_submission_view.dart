import 'package:flutter/material.dart';
import 'package:lms_english_app/core/services/homework_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewSubmissionView extends StatefulWidget {
  final Map asignacion;
  const ReviewSubmissionView({super.key, required this.asignacion});

  @override
  State<ReviewSubmissionView> createState() => _ReviewSubmissionViewState();
}

class _ReviewSubmissionViewState extends State<ReviewSubmissionView> {
  List<dynamic> entregas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarEntregas();
  }

  void abrirEnlace(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Future<void> cargarEntregas() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();
      final datos = await HomeworkService()
          .consultarEntregas(token!, widget.asignacion['id']);
      setState(() {
        entregas = datos;
        cargando = false;
      });
    } catch (e) {
      print('Error al consultar entregas: $e');
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        title: const Text('Revisar entrega'),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : entregas.isEmpty
              ? const Center(child: Text('No hay entregas registradas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: entregas.length,
                  itemBuilder: (context, index) {
                    final entrega = entregas[index];
                    final archivos = entrega['archivos'] ?? [];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Intento #${entrega['intento']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Fecha: ${entrega['fecha']}',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            const Text('Documentos entregados:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...archivos.map<Widget>((archivo) {
                              final tipo = archivo['tipo'];
                              if (tipo == 'file') {
                                return ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(archivo['nombre']),
                                  subtitle:
                                      Text('Tipo: ${archivo['extension']}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      // Aquí colocarías lógica de descarga si se usa links o rutas
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Descargando...')),
                                      );
                                    },
                                  ),
                                );
                              } else if (tipo == 'link') {
                                return ListTile(
                                  leading: const Icon(Icons.link),
                                  title: const Text('Enlace compartido'),
                                  subtitle: Text(archivo['url']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.open_in_browser),
                                    onPressed: () =>
                                        abrirEnlace(archivo['url']),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
