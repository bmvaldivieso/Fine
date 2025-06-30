import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definimos el tamaño de la pantalla para cálculos responsivos
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA6C6FF), // Color A6C6FF
              Color(0xFF20059E), // Color 20059E
            ],
            stops: [0.0, 1.0],
          ),
        ),
        // Aquí es donde el Stack es el hijo directo del Container con el degradado.
        child: Stack(
          children: [
            // Contenedor principal para la tarjeta blanca (ocupa la parte inferior)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // La altura de la tarjeta blanca debe ser suficiente para contener todo su contenido.
              // Ajusta este valor si el contenido no cabe o si hay mucho espacio.
              height: screenHeight * 0.60, // Ajustado a 70% para que la imagen tenga más espacio arriba
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(85.0), // Manteniendo los 85 que usaste
                    topRight: Radius.circular(85.0), // Manteniendo los 85 que usaste
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Correo:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Correo',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Contraseña:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '********',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Acción para el botón Ingresar
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF20059E),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Ingresar',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Acción para el botón Matricularse
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFA6C6FF),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Matricularse',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Imagen de la chica posicionada absolutamente
            // El Positioned debe ser un hijo directo del Stack
            Positioned(
              // Calculamos el 'top' para que esté en el centro vertical de la parte superior
              // y un poco empujada hacia abajo.
              // screenHeight * 0.15 dejará el 15% de espacio desde arriba.
              top:55,
              // Calculamos 'left' y 'right' para centrar la imagen
              // Asumimos un ancho deseado para la imagen (ej. 70% del ancho de pantalla).
              // (screenWidth - (ancho deseado de la imagen)) / 2
              left: (screenWidth - screenWidth * 1.5) / 2,
              right: (screenWidth - screenWidth * 1.1) / 2,
              child: Image.asset(
                'lib/assets/images/chica.png',
                fit: BoxFit.contain,
                // Ajusta la altura de la imagen para que se vea bien
                // Por ejemplo, 30% de la altura de la pantalla.
                height: screenHeight * 0.40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}