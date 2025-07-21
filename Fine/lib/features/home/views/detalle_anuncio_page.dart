import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms_english_app/core/models/anuncio_detalle_model.dart';
import 'package:lms_english_app/core/services/anuncios_service.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleAnuncioPage extends StatefulWidget {
  final int anuncioId;

  const DetalleAnuncioPage({Key? key, required this.anuncioId}) : super(key: key);

  @override
  State<DetalleAnuncioPage> createState() => _DetalleAnuncioPageState();
}

class _DetalleAnuncioPageState extends State<DetalleAnuncioPage> {
  late Future<AnuncioDetalle> _anuncioFuture;

  @override
  void initState() {
    super.initState();
    _anuncioFuture = cargarDetalle();
  }

  Future<AnuncioDetalle> cargarDetalle() async {
    final token = await AuthServiceLogin().getAccessToken();
    return await obtenerDetalleAnuncio(widget.anuncioId, token!);
  }

  void _abrirEnlace(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  void _descargarArchivo(ArchivoAdjunto archivo) async {
    final url = archivo.url;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar el archivo')),
      );
    }
  }

  void _verArchivo(ArchivoAdjunto archivo) async {
    final url = '${archivo.url}?preview=true';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la vista previa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del anuncio', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF3F6FC),
      body: FutureBuilder<AnuncioDetalle>(
        future: _anuncioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('❌ Error al cargar el anuncio.'));
          }

          final anuncio = snapshot.data!;
          final enlaces = anuncio.enlaces;

          final fechaRaw = anuncio.fecha;
          DateTime fecha = DateTime.tryParse(fechaRaw) ?? DateTime.now();
          String fechaFormateada =
              DateFormat('dd/MM/yyyy – HH:mm').format(fecha);

          // Filtrar solo archivos cuyo tipo sea 'documento'
          final archivosDocumentos = anuncio.archivos
              .where((archivo) => archivo.tipo.toLowerCase() == 'documento')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anuncio.titulo,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fechaFormateada,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                if (anuncio.imagenes.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      anuncio.imagenes[0],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                Text(
                  anuncio.contenido,
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),

                const SizedBox(height: 30),

                if (enlaces.isNotEmpty) ...[
                  const Text(
                    '🔗 Enlaces relacionados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ...enlaces.map(
                    (e) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.link, color: Colors.green),
                        title: Text(
                          e.url,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => _abrirEnlace(e.url),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (archivosDocumentos.isNotEmpty) ...[
                  const Text(
                    '📎 Archivos adjuntos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ...archivosDocumentos.map(
                    (archivo) => Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.insert_drive_file, color: Colors.blue),
                        title: Text(archivo.nombre),
                        subtitle: Text('Tipo: ${archivo.tipo}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _verArchivo(archivo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _descargarArchivo(archivo),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
