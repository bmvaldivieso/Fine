import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import '../../home/controllers/home_Controller.dart';
import '../models/Form.dart';
import '../providers/formProvider.dart';
import '../services/registerDjango.dart';
import '../services/verifiCodAcces.dart';

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
      home: codigVerifi(),
    );
  }
}





class codigVerifi extends StatefulWidget {
  const codigVerifi({super.key});
  @override
  codigo createState() => codigo();
}


class codigo extends State<codigVerifi> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  late final HomeController _homeController = Get.find<HomeController>();


  ///aqui enviamos el codigo al usuario//
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Pantalla de verificación iniciada. Intentando enviar código...');
      final formRepre = Provider.of<RegistroProvider>(context, listen: false).representante;
      if (formRepre.email != null && formRepre.email!.isNotEmpty) {
        final success = await CodService().cod(formRepre.email!);
        if (success) {
          print('Código enviado correctamente a: ${formRepre.email}');
        } else {
          print('El código NO ha sido enviado. Hubo un error para: ${formRepre.email}');
        }
      } else {
        print('Error: No se encontró un correo electrónico para enviar el código.');
      }
    });
  }


  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  //solo mostramos una breve notificacion en la interfaz//
  void _showCustomSnackBar(BuildContext context, {required String message, required Color color, required IconData icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  registro(FormularioEstudiante formEstudi,FormularioRepresentante formRepre,FormularioUser formuser ) async {
    final registroExitoso = await AuthService().Regis(
        formEstudi.tipoIdentificacion,
        formEstudi.identificacion,
        formEstudi.nombresApellidos,
        formEstudi.fechaNacimiento,
        formEstudi.genero,
        formEstudi.ocupacion,
        formEstudi.nivelEstudio,
        formEstudi.lugarEstudioTrabajo,
        formEstudi.direccion,
        formEstudi.email,
        formEstudi.celular,
        formEstudi.telefonoConvencional,
        formEstudi.parroquia,
        formEstudi.programaAcademico,
        formRepre.emitirFacturaAlEstudiante,
        formRepre.tipoIdentificacion,
        formRepre.identificacion,
        formRepre.razonSocial,
        formRepre.direccion,
        formRepre.email,
        formRepre.celular,
        formRepre.telefonoConvencional,
        formRepre.sexo,
        formRepre.estadoCivil,
        formRepre.origenIngresos,
        formRepre.parroquia,
        formuser.user,
        formuser.password,
    );

    if (registroExitoso) {
      _showCustomSnackBar(context, message: '🎉 Registro exitoso Bienvenido, ${formuser.user}', color: Colors.green, icon: Icons.check_circle);
      _homeController.gotoWelcome(formuser.user!);
    } else {
      _showCustomSnackBar(context, message: '❌ Registro fallido por favor revisar la cedula o el correo', color: Colors.red, icon: Icons.error);
    }
  }



  @override
  Widget build(BuildContext context) {
    final formEstudi = Provider.of<RegistroProvider>(context).estudiante;
    final formRepre = Provider.of<RegistroProvider>(context).representante;
    final formuser = Provider.of<RegistroProvider>(context).user;
    final String correoEnd = formRepre.email ?? 'correo no disponible';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    //aqui le enviamos el codigo escrito del usuario a django para validarlo en el backend//
    Future<void> submitForm() async {
      if (_formKey.currentState!.validate()) {
        final String codigo = _codigoController.text;

        print('--- Datos del Formulario finales ---');
        print('codigo: $codigo');
        print('---------------------------');

        final success = await CodService().verifCod(codigo,correoEnd);
        if (success) {
          print('✅ Código verificado correctamente en Django');
          _showCustomSnackBar(context, message: '¡Codigo Verificado Exitoso!', color: Colors.green, icon: Icons.check_circle);
          //hacemos la persistencia de datos//
          registro(formEstudi,formRepre,formuser);
        } else {
          _showCustomSnackBar(context, message: '¡Error codigo incorrecto verificar, ${formuser.user}', color: Colors.red, icon: Icons.check_circle);
          print('El código no es válido o hubo un error');
        }
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
                          'Ultimo Paso Verificacion',
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
                      'Validacion',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Codigo de Verificacion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),

                    Row( // Usamos un Row para colocar el asterisco al lado del texto
                      children: [
                        Text(
                          'Se ha Enviado un codigo de verificacion \nal correo $correoEnd',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _codigoController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingresa su codigo',
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
                          return 'el codigo es requerido';
                        }
                        if (value.length < 5 || value.length > 7) {
                          return 'Mínimo 5 caracteres y maximo 7';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números revisa que no haya letras ni espacios';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:submitForm,
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
                                'Verificar',
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

