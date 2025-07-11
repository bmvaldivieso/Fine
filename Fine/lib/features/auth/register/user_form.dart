import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import '../../home/controllers/home_Controller.dart';
import '../providers/formProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RegistroProvider()),],
      child: MyApp(),
    ),
  );
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
      home: RegisterScreenUser(),
    );
  }
}



class RegisterScreenUser extends StatefulWidget {
  const RegisterScreenUser({super.key});
  @override
  UserForm createState() => UserForm();
}


class UserForm extends State<RegisterScreenUser> {
  late final HomeController _homeController = Get.find<HomeController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();



  @override
  void dispose() {
    _userController.dispose();
    _passwordConfirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistroProvider>(context, listen: false);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Future<void> submitForm() async {
      if (_formKey.currentState!.validate()) {
        final String usuario = _userController.text;
        final String password = _passwordController.text;
        final String confirmPaswword = _passwordConfirmController.text;

        print('--- Datos del Formulario Representante ---');
        print('usuario: $usuario');
        print('password: $password');
        print('confirmarPassword: $confirmPaswword');
        print('---------------------------');
        //guardamos en el provaider//
        provider.actualizarUser(user:usuario, password:password, confrimPassword:confirmPaswword,);
        _homeController.gotoCodigoVerifi();
      }
    }


    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
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
                      'Usuario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Datos personales del Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),

                    Row( // Usamos un Row para colocar el asterisco al lado del texto
                      children: [
                        const Text(
                          'Usuario:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Text( // Asterisco para indicar campo obligatorio
                          ' *',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red, // Color rojo para destacarlo
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _userController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingresa su Usuario',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'el Usuario es Requerido';
                        }
                        if (value.length < 10) {
                          return 'Mínimo 10 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Ubícalo después de 'Lugar de Estudio/Trabajo'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'password:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Eje.password123',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'el password es obligatorio';
                        }
                        if (value.length < 5) {
                          return 'Mínimo 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'confirmar Password:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordConfirmController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'eje.password123',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Es obligatorio confirmar el password';
                        }
                        if (value.length < 6) { // Validación de mínimo 6 caracteres
                          return 'Mínimo 10 caracteres';
                        }
                        if(_passwordController.text != value){
                          return 'la contraseña no coincide';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 50),
                    // Botón "Next" con degradado
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitForm,
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
      ),
    );
  }
}

