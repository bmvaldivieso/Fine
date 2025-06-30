import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Si ya usas GetX
import 'dart:math'; // Para Math.pi para la rotación



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ejemplo de Drawer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyDrawerScreen(),
    );
  }
}


class MyDrawerScreen extends StatefulWidget {
  const MyDrawerScreen({super.key});

  @override
  State<MyDrawerScreen> createState() => _MyDrawerScreenState();
}





class _MyDrawerScreenState extends State<MyDrawerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;
  // Cambiado a BorderRadiusGeometry? para compatibilidad con ClipRRect
  late Animation<BorderRadiusGeometry?> _borderRadiusAnimation;

  // Usamos GetX RxBool para controlar el estado del drawer fácilmente
  final RxBool _isDrawerOpen = false.obs; // Aquí está tu variable observable de GetX

  // Ancho deseado de tu Drawer
  final double _drawerWidth = 250.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Duración de la animación
    );

    // Animación de escala: de 1.0 (tamaño original) a 0.8 (más pequeño)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Curva de animación
      ),
    );

    // Animación de deslizamiento: de 0.0 (posición original) al ancho del drawer (se mueve a la derecha)
    _slideAnimation = Tween<double>(begin: 0.0, end: _drawerWidth).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Animación de rotación (para el efecto 3D): de 0 grados a -10 grados (aproximadamente, usa radianes)
    // El 'end' es un ángulo en radianes. pi / 18 es 10 grados, y negativo para rotar hacia la izquierda/atrás
    _rotationAnimation = Tween<double>(begin: 0.0, end: -pi / 18).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Animación de BorderRadius: de sin borde a borde circular
    _borderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.zero,
      end: BorderRadius.circular(30.0), // Radio de borde deseado
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Listener para actualizar _isDrawerOpen cuando la animación termina
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isDrawerOpen.value = true;
      } else if (status == AnimationStatus.dismissed) {
        _isDrawerOpen.value = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Es importante liberar el controlador
    super.dispose();
  }

  // Función para alternar el estado del drawer
  void _toggleDrawer() {
    if (_isDrawerOpen.value) {
      _animationController.reverse(); // Si está abierto, ciérralo
    } else {
      _animationController.forward(); // Si está cerrado, ábrelo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Pantalla con Drawer Animado'),
        leading: IconButton( // Este es el icono de menú personalizado
          icon: const Icon(Icons.menu), // Icono de hamburguesa
          onPressed: _toggleDrawer, // Llama a la función para alternar el drawer
        ),
      ),
      body: Stack(
        children: [
          // 1. Contenido del Drawer (el menú lateral)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _drawerWidth, // Ancho del Drawer
            child: Material( // Un Material widget para dar elevación y fondo al drawer
              elevation: 10,
              color: const Color(0xFF3284FF), // Color de fondo del drawer
              child: SafeArea(
                child: Column(
                  children: [
                    // Sección del perfil en el Drawer (similar a tu imagen)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/psicologia-app-liid.firebasestorage.app/o/images%2FmarcianoLogin.png?alt=media&token=18eb7af9-c30b-4dd8-b134-2abcf42ae056'
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Carlos Lopez', // Puedes hacer esto dinámico como en tu AppBar
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white70),
                    // Lista de opciones del menú
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          _buildDrawerItem(Icons.school, 'Curses', () {
                            _toggleDrawer(); // Cierra el drawer
                            Get.snackbar('Navegación', 'Ir a Cursos');
                          }),
                          _buildDrawerItem(Icons.schedule, 'Schedule', () {
                            _toggleDrawer(); // Cierra el drawer
                            Get.snackbar('Navegación', 'Ir a Horario');
                          }),
                          _buildDrawerItem(Icons.payment, 'Payments', () {
                            _toggleDrawer(); // Cierra el drawer
                            Get.snackbar('Navegación', 'Ir a Pagos');
                          }),
                          _buildDrawerItem(Icons.notes, 'Notes', () {
                            _toggleDrawer(); // Cierra el drawer
                            Get.snackbar('Navegación', 'Ir a Notas');
                          }),
                          _buildDrawerItem(Icons.message, 'Message', () {
                            _toggleDrawer(); // Cierra el drawer
                            Get.snackbar('Navegación', 'Ir a Mensajes');
                          }),
                        ],
                      ),
                    ),
                    // Botón "Cerrar Sesión" en la parte inferior del Drawer
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _toggleDrawer(); // Cierra el drawer antes de la acción
                            Get.snackbar('Acción', 'Cerrando Sesión...');
                            // Aquí iría tu lógica de cierre de sesión
                            // await _authService.signOutCompletely();
                            // await FirebaseAuth.instance.signOut();
                            // homeController.goToCarga();
                          },
                          icon: const Icon(Icons.logout, color: Colors.black87),
                          label: const Text('Cerrar Sesion', style: TextStyle(color: Colors.black87)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Contenido Principal de la Pantalla (el Body que se anima)
          // Quitamos el Obx que envolvía todo el AnimatedBuilder
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                // Esto es crucial para el efecto 3D de perspectiva
                alignment: Alignment.centerLeft, // Rotar desde el borde izquierdo
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspectiva 3D
                  ..rotateY(_rotationAnimation.value) // Rotación en el eje Y
                  ..scale(_scaleAnimation.value) // Escala
                  ..translate(_slideAnimation.value), // Deslizamiento horizontal

                child: Obx(() => GestureDetector( // <-- Obx movido aquí para escuchar _isDrawerOpen
                  // Cierra el drawer si se hace tap en la pantalla principal
                  onTap: _isDrawerOpen.value ? _toggleDrawer : null,
                  child: AbsorbPointer( // Impide interacciones con el body si el drawer está abierto
                    absorbing: _isDrawerOpen.value,
                    child: ClipRRect( // Para el borde redondeado del body
                      borderRadius: _borderRadiusAnimation.value!, // Asegúrate de que no sea nulo
                      child: Container(
                        // Tu contenido original del body va aquí
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF87CEEB), // Un color de ejemplo similar al de la imagen
                              Color(0xFFADD8E6),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Contenido Principal Aquí',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Obx(() => ElevatedButton( // <-- Otro Obx aquí para el texto del botón
                                onPressed: _toggleDrawer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                ),
                                child: Text(_isDrawerOpen.value ? 'Cerrar Menú' : 'Abrir Menú'),
                              )), // Fin del Obx del botón
                              const SizedBox(height: 20),
                              const Text(
                                'Este es el body que se anima.',
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )), // Fin del Obx del GestureDetector
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function para crear los items del Drawer
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}