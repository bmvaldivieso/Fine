import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        const SnackBar(content: Text('No se pudo abrir el enlace')),
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
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: const Text('📄 Revisar entrega'),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : entregas.isEmpty
              ? const Center(
                  child: Text(
                    '🚫 No hay entregas registradas',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: entregas.length,
                  itemBuilder: (context, index) {
                    final entrega = entregas[index];
                    final archivos = entrega['archivos'] ?? [];

                    final fechaRaw = entrega['fecha'];
                    DateTime fecha =
                        DateTime.tryParse(fechaRaw) ?? DateTime.now();
                    String fechaFormateada =
                        DateFormat('dd/MM/yyyy – HH:mm').format(fecha);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.assignment_turned_in,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('Intento #${entrega['intento']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text('Fecha: $fechaFormateada',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 25),
                            const Text(
                              '📎 Documentos entregados',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            ...archivos.map<Widget>((archivo) {
                              final tipo = archivo['tipo'];
                              if (tipo == 'file') {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.insert_drive_file,
                                          color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            archivo['nombre'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text('Tipo: ${archivo['extension']}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      )),
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () async {
                                          final entregaId = entrega['_id'];
                                          final nombre = archivo['nombre'];
                                          final url =
                                              'http://localhost:8000/api/descargar/$entregaId/$nombre';

                                          final uri = Uri.parse(url);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'No se pudo descargar el archivo')),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () async {
                                          final entregaId = entrega['_id'];
                                          final nombre = archivo['nombre'];
                                          final url =
                                              'http://localhost:8000/api/descargar/$entregaId/$nombre?preview=true';

                                          final uri = Uri.parse(url);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'No se pudo abrir la vista previa')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else if (tipo == 'link') {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link,
                                          color: Colors.green),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          archivo['url'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_in_browser),
                                        onPressed: () async {
                                          final url = archivo['url'];
                                          if (url != null &&
                                              Uri.tryParse(url)
                                                      ?.hasAbsolutePath ==
                                                  true) {
                                            final uri = Uri.parse(url);
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Enlace inválido')),
                                              );
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('URL mal formada')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
