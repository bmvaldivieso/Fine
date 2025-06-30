import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enrollment Representative App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EnrollmentRepresentativeScreen(), // Carga directamente la pantalla de representante
    );
  }
}

class EnrollmentRepresentativeScreen extends StatelessWidget {
  const EnrollmentRepresentativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
            top: -screenHeight * 0.25,
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

          // Contenedor para el contenido principal (Representante, Datos, Campos, Botón)
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
                  const SizedBox(height: 10),
                  const Text(
                    'Representante', // Título para este formulario
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Informacion del representante', // Subtítulo para este formulario
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildTextFieldWithLabel('Tipo de identificacion:', 'Ruc'),
                  const SizedBox(height: 20),
                  _buildTextFieldWithLabel('Identificacion:', 'Ingrese aqui'),
                  const SizedBox(height: 20),
                  _buildTextFieldWithLabel('Nombres:', 'Ingrese aqui'),
                  const SizedBox(height: 20),
                  _buildTextFieldWithLabel('Apellidos:', 'Ingrese aqui'),

                  const SizedBox(height: 50),
                  _buildNextButton(),
                  const SizedBox(height: 20),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Acción para el botón Next
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
                  Color(0xFF09244B),
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
                'Next',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}