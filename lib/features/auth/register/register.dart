import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enrollment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EnrollmentScreen(),
    );
  }
}

class EnrollmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Contenedor principal blanco que ocupa toda la pantalla
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),

          // 2. El círculo grande de fondo con degradado (la "luna" cortada)
          Positioned(
            top: -screenHeight * 0.25, // Ajusta este valor para mover el círculo arriba/abajo
            left: -screenWidth * 0.2, // Ajusta este valor para mover el círculo izquierda/derecha
            child: Container(
              width: screenWidth * 1.4,
              height: screenWidth * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF619BFF), // Color 619BFF (azul claro)
                    Color(0xFF20059E), // Color 20059E (azul oscuro)
                  ],
                ),
              ),
              // *** Stack como hijo del círculo para contener la imagen y el texto a voluntad ***
              child: Stack(
                children: [
                  // Gorro de graduación con opacidad
                  Positioned(
                    // Ajusta estos valores para mover el gorro
                    top: 280, // Mueve el gorro desde la parte superior del círculo
                    left: 80, // Mueve el gorro desde la izquierda del círculo
                    // right: null, // Puedes usar left/right, o top/bottom, o ambos para dimensionar
                    // bottom: null,
                    child: Opacity(
                      opacity: 0.54, // Opacidad al 34%
                      child: Image.asset(
                        'lib/assets/images/gorro.png',
                        width: 350, // Ajusta el ancho del gorro
                        height: 350, // Ajusta la altura del gorro
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Título "Matricula" encima del gorro
                  Positioned(
                    // Ajusta estos valores para mover la palabra "Matricula"
                    top: 400, // Mueve el texto desde la parte superior del círculo
                    left: 0,
                    right: 0, // Usar left y right 0 con Center asegura centrado horizontalmente
                    child: Center(
                      child: Text(
                        'Matricula',
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

          // Contenedor para el contenido principal (Estudiante, Datos, Campos, Botón)
          Positioned(
            top: screenHeight * 0.40,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Estudiante',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Datos personales del estudiante',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 30),

                  _buildTextFieldWithLabel('Tipo de identificacion:', 'Ruc'),
                  SizedBox(height: 20),
                  _buildTextFieldWithLabel('Identificacion:', 'Ingrese aqui'),
                  SizedBox(height: 20),
                  _buildTextFieldWithLabel('Nombres:', 'Ingrese aqui'),
                  SizedBox(height: 20),
                  _buildTextFieldWithLabel('Apellidos:', 'Ingrese aqui'),

                  SizedBox(height: 50),
                  // Botón "Next" con degradado
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Acción para el botón Next
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
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
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF09244B), // Color 09244B
                                Color(0xFF20059E), // Color 20059E
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }
}