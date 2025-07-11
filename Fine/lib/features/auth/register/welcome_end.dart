import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../home/controllers/home_Controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(userName: 'hola',),
    );
  }
}





class WelcomeScreen extends StatelessWidget {
  final String userName;

  const WelcomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final HomeController _homeController = Get.find<HomeController>();


    return Scaffold(
      body: Stack(
        children: [
          // Contenedor principal blanco que ocupa toda la pantalla
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),

          // El círculo grande de fondo con degradado (la "luna" cortada)
          Positioned(
            top: -screenHeight * 0.25, // Mantenemos el top ajustado
            left: -screenWidth * 0.2,
            child: Container(
              width: screenWidth * 1.4,
              height: screenWidth * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF619BFF),
                    Color(0xFF20059E),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Gorro de graduación con opacidad
                  Positioned(
                    top: 280,
                    left: 80,
                    child: Opacity(
                      opacity: 0.54,
                      child: Image.asset(
                        'lib/assets/images/gorro.png',
                        width: 350,
                        height: 350,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Título "Matricula" encima del gorro
                  Positioned(
                    top: 400,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Registro',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // *** Contenido de la pantalla "Welcome" ***
          Positioned(
            top: screenHeight * 0.55, // Ajusta este valor para subir o bajar el contenido "Welcome"
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centrar todo el contenido
              children: [
                // Texto "Welcome"
                Text(
                  'Welcome $userName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 70, // Tamaño grande para "Welcome"
                    fontWeight: FontWeight.w800, // Grosor muy alto (Heavy/Black)
                    color: Colors.black,
                  ),
                ),
                // Texto "to your English course"
                Text(
                  'to your English course',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30, // Tamaño más pequeño
                    fontWeight: FontWeight.normal, // Grosor normal
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Botón "Get Start"
          Positioned(
            bottom: screenHeight * 0.1, // Posiciona el botón desde la parte inferior
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.8, // Ancho responsivo para el botón
                child: ElevatedButton(
                  onPressed: () {
                    _homeController.gotoHomeWithIndex(0, transitionType: 'offAll');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.white.withOpacity(0.2);
                        }
                        return null;
                      },
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF09244B), // Mismo degradado que los botones anteriores
                          Color(0xFF20059E),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Text(
                        'Get Start',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}