import 'package:flutter/material.dart';
import 'package:lms_english_app/core/models/anuncio_model.dart';
import 'package:lms_english_app/core/services/anuncios_service.dart';
import 'package:lms_english_app/core/services/service_MatriculaValidate.dart';
import 'package:lms_english_app/features/auth/services/tokkenAccesLogin.dart';
import 'package:lms_english_app/features/home/views/detalle_anuncio_page.dart';
import 'package:get/get.dart';
import 'package:lms_english_app/features/home/controllers/home_Controller.dart';

class ListaAnunciosPage extends StatefulWidget {
  const ListaAnunciosPage({super.key});

  @override
  _ListaAnunciosPageState createState() => _ListaAnunciosPageState();
}

class _ListaAnunciosPageState extends State<ListaAnunciosPage> {
  late Future<List<Anuncio>> anuncios;
  final _homeController = Get.find<HomeController>();
  bool _tieneMatricula = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    anuncios = cargarAnuncios();
    _verificarMatricula();
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
      if (!mounted) return;
      setState(() {
        _tieneMatricula = true;
        _cargando = false;
      });
    }
  }

  Future<List<Anuncio>> cargarAnuncios() async {
    try {
      final token = await AuthServiceLogin().getAccessToken();
      print("TOKEN: $token");
      final anuncios = await obtenerAnuncios(token!);
      print("CANTIDAD DE ANUNCIOS: ${anuncios.length}");
      return anuncios;
    } catch (e) {
      print("ERROR: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 137, 160, 236),
      appBar: AppBar(
          title: Text("Anuncios", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2042A6)),
      body: FutureBuilder<List<Anuncio>>(
        future: anuncios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text("Error al cargar los anuncios"));

          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const Center(child: Text("No hay anuncios disponibles"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final anuncio = lista[index];
              final ahora = DateTime.now();
              final esHoy = anuncio.fechaCreacion.year == ahora.year &&
                  anuncio.fechaCreacion.month == ahora.month &&
                  anuncio.fechaCreacion.day == ahora.day;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign,
                        color: Color.fromARGB(255, 51, 221, 51),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anuncio.titulo,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${anuncio.fechaCreacion.day}/${anuncio.fechaCreacion.month}/${anuncio.fechaCreacion.year} – ${anuncio.fechaCreacion.hour}:${anuncio.fechaCreacion.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleAnuncioPage(anuncioId: anuncio.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDA70FD), Color(0xFFA6C6FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Detalle",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
