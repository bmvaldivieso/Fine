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
      home: RegisterScreen(),
    );
  }
}



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  Register createState() => Register();
}




class Register extends State<RegisterScreen> {

  late final HomeController _homeController = Get.find<HomeController>();
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _tipoIdentificacionOptions = const [{'value': 'cedula', 'label': 'Cédula'}, {'value': 'ruc', 'label': 'RUC'}, {'value': 'pasaporte', 'label': 'Pasaporte'}, {'value': 'extranjero', 'label': 'Extranjero'},];
  final TextEditingController _identificacion = TextEditingController();
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _tipoIdentificacionDisplayController = TextEditingController();
  final TextEditingController _nombresApellidosController = TextEditingController();
  final TextEditingController _fechaNacimientoDisplayController = TextEditingController();
  final TextEditingController _generoDisplayController = TextEditingController();
  final List<Map<String, String>> _generoOptions = const [{'value': 'M', 'label': 'Masculino'}, {'value': 'F', 'label': 'Femenino'},];
  final TextEditingController _ocupacionDisplayController = TextEditingController();
  final List<Map<String, String>> _ocupacionOptions = const [{'value': 'estudiante', 'label': 'Estudiante'}, {'value': 'docente', 'label': 'Docente'},];
  final TextEditingController _nivelEstudioDisplayController = TextEditingController();
  final List<Map<String, String>> _nivelEstudioOptions = const [{'value': 'prebasica', 'label': 'Prebásica 1-2'}, {'value': 'basica', 'label': 'Básica 1-10'}, {'value': 'bachillerato', 'label': 'Bachillerato 1-3'}, {'value': 'universidad', 'label': 'Universidad/Superior'},];
  final TextEditingController _lugarEstudioTrabajoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _telefonoConvencionalController = TextEditingController();
  final TextEditingController _parroquiaDisplayController = TextEditingController();
  final List<Map<String, String>> _parroquiaOptions = const [{'value': 'el_valle', 'label': 'El Valle'}, {'value': 'el_sagrario', 'label': 'El Sagrario'}, {'value': 'san_sebastian', 'label': 'San Sebastián'},];
  final TextEditingController _programaAcademicoDisplayController = TextEditingController();
  final List<Map<String, String>> _programaAcademicoOptions = const [{'value': 'b2', 'label': 'B2 FIRST PREPARATION (FCE)'}, {'value': 'teachers', 'label': 'PREPARATION FOR TEACHERS'}, {'value': 'youth_intensive', 'label': 'YOUTH INTENSIVE PROGRAM'}, {'value': 'youth', 'label': 'YOUTH PROGRAM'}, {'value': 'seniors', 'label': 'SENIORS INTENSIVE PROGRAM'}, {'value': 'express', 'label': 'English Express'},];

  String? _selectedNivelEstudio;
  String? _selectedGenero;
  DateTime? _selectedFechaNacimiento;
  String? _selectedTipoIdentificacion;
  String? _selectedOcupacion;
  String? _selectedParroquia;
  String? _selectedProgramaAcademico;


  @override
  void dispose() {
    _identificacion.dispose();
    _identificacionController.dispose();
    _tipoIdentificacionDisplayController.dispose();
    _nombresApellidosController.dispose();
    _fechaNacimientoDisplayController.dispose();
    _generoDisplayController.dispose();
    _ocupacionDisplayController.dispose();
    _lugarEstudioTrabajoController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _telefonoConvencionalController.dispose();
    _parroquiaDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistroProvider>(context, listen: false);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    Future<void> submitForm() async {
      if (_formKey.currentState!.validate()) {
        final String email = _emailController.text;
        final String? tipoIdentificacion = _selectedTipoIdentificacion;
        final String identificacion = _identificacionController.text;
        final String nombresApellidos = _nombresApellidosController.text;
        final DateTime? fechaNacimiento = _selectedFechaNacimiento;
        final String? genero = _selectedGenero;
        final String? ocupacion = _selectedOcupacion;
        final String? nivelEstudio = _selectedNivelEstudio;
        final String lugarEstudioTrabajo = _lugarEstudioTrabajoController.text;
        final String direccion = _direccionController.text;
        final String celular = _celularController.text;
        final String telefonoConvencional = _telefonoConvencionalController.text;
        final String? parroquia = _selectedParroquia;
        final String? programaAcademico = _selectedProgramaAcademico;

        print('--- Datos del Formulario ---');
        print('Correo: $email');
        print('Tipo de Identificación: $tipoIdentificacion');
        print('Número de Identificación: $identificacion');
        print('Nombres y Apellidos: $nombresApellidos');
        print('Fecha de Nacimiento: ${fechaNacimiento != null ? "${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}" : "No seleccionada"}');
        print('Género: $genero');
        print('Ocupación: $ocupacion');
        print('Nivel de Estudio: $nivelEstudio');
        print('Lugar de Estudio/Trabajo: $lugarEstudioTrabajo');
        print('Dirección: $direccion');
        print('Celular: $celular');
        print('Teléfono Convencional: $telefonoConvencional');
        print('Parroquia: $parroquia');
        print('Programa Académico: $programaAcademico');
        print('---------------------------');

        //guardamos en el provaider//
        provider.actualizarEstudiante(
          email: email,
          tipoIdentificacion: tipoIdentificacion,
          identificacion: identificacion,
          nombresApellidos: nombresApellidos,
          fechaNacimiento: fechaNacimiento,
          genero: genero,
          ocupacion: ocupacion,
          nivelEstudio: nivelEstudio,
          lugarEstudioTrabajo: lugarEstudioTrabajo,
          direccion: direccion,
          celular: celular,
          telefonoConvencional: telefonoConvencional,
          parroquia: parroquia,
          programaAcademico: programaAcademico,
        );
        _homeController.goToRepresentRegister();
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

                    Row( // Usamos un Row para colocar el asterisco al lado del texto
                      children: [
                        const Text(
                          'Tipo identificacion:',
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
                      controller: _tipoIdentificacionDisplayController, // Muestra el valor seleccionado
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione tipo',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down), // Icono de flecha para indicar que es un selector
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _tipoIdentificacionOptions.length,
                              itemBuilder: (context, index) {
                                final option = _tipoIdentificacionOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );

                        if (selectedValue != null) {
                          setState(() {
                            _selectedTipoIdentificacion = selectedValue;
                            _tipoIdentificacionDisplayController.text = _tipoIdentificacionOptions.firstWhere((option) => option['value'] == selectedValue)['label']!;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedTipoIdentificacion == null || _selectedTipoIdentificacion!.isEmpty) {
                          return 'Debe seleccionar un tipo de identificación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height:20),



                    Row( // Usamos un Row para colocar el asterisco al lado del texto
                      children: [
                        const Text(
                          'Identificacion:',
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
                      controller: _identificacionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su número de $_selectedTipoIdentificacion',
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
                          return 'El numero de $_selectedTipoIdentificacion es obligatorio';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números';
                        }
                        if (value.length < 10) {
                          return 'Mínimo 10 dígitos';
                        }
                        return null;
                      },
                    ),







                    const SizedBox(height: 20),
                    Row( // Usamos un Row para colocar el asterisco al lado del texto
                      children: [
                        const Text(
                          'Nombres y Apellidos:',
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
                      controller: _nombresApellidosController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingrese sus nombres y apellidos',
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
                          return 'Los nombres y apellidos son obligatorios';
                        }
                        if (value.length < 10) {
                          return 'Mínimo 10 caracteres';
                        }
                        return null;
                      },
                    ),



                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Fecha de Nacimiento:',
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
                      controller: _fechaNacimientoDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su fecha de nacimiento',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedFechaNacimiento ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            _selectedFechaNacimiento = pickedDate;
                            _fechaNacimientoDisplayController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedFechaNacimiento == null) {
                          return 'La fecha de nacimiento es obligatoria';
                        }
                        return null;
                      },
                    ),


                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Género:',
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
                      controller: _generoDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su género',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _generoOptions.length,
                              itemBuilder: (context, index) {
                                final option = _generoOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );
                        if (selectedValue != null) {
                          setState(() {_selectedGenero = selectedValue;_generoDisplayController.text = _generoOptions.firstWhere((option) => option['value'] == selectedValue)['label']!;});
                        }
                      },
                      validator: (value) {
                        if (_selectedGenero == null || _selectedGenero!.isEmpty) {
                          return 'El género es obligatorio';
                        }
                        return null;
                      },
                    ),


                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Ocupación:',
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
                      controller: _ocupacionDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su ocupación',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _ocupacionOptions.length,
                              itemBuilder: (context, index) {
                                final option = _ocupacionOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );
                        if (selectedValue != null) {
                          setState(() {
                            _selectedOcupacion = selectedValue;
                            _ocupacionDisplayController.text = _ocupacionOptions.firstWhere((option) => option['value'] == selectedValue)['label']!;});
                        }
                      },
                      validator: (value) {
                        if (_selectedOcupacion == null || _selectedOcupacion!.isEmpty) {
                          return 'La ocupación es obligatoria';
                        }
                        return null;
                      },
                    ),





                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Nivel de Estudio:',
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
                      controller: _nivelEstudioDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su nivel de estudio',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _nivelEstudioOptions.length,
                              itemBuilder: (context, index) {
                                final option = _nivelEstudioOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );

                        if (selectedValue != null) {
                          setState(() {
                            _selectedNivelEstudio = selectedValue;
                            _nivelEstudioDisplayController.text = _nivelEstudioOptions
                                .firstWhere((option) => option['value'] == selectedValue)['label']!;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedNivelEstudio == null || _selectedNivelEstudio!.isEmpty) {
                          return 'El nivel de estudio es obligatorio';
                        }
                        return null;
                      },
                    ),


                    // Ubícalo después de 'Nivel de Estudio'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Lugar de Estudio/Trabajo:',
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
                      controller: _lugarEstudioTrabajoController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su lugar de estudio o trabajo',
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
                          return 'El lugar de estudio/trabajo es obligatorio';
                        }
                        if (value.length < 5) {
                          return 'Mínimo 5 caracteres';
                        }
                        return null;
                      },
                    ),

                    // Ubícalo después de 'Lugar de Estudio/Trabajo'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Dirección:',
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
                      controller: _direccionController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su Direccion',
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
                          return 'La direccion es obligatorio';
                        }
                        if (value.length < 5) {
                          return 'Mínimo 5 caracteres';
                        }
                        return null;
                      },
                    ),



                    // Este campo ya lo tienes, solo verifica las validaciones y el asterisco
                    const SizedBox(height: 20), // Este SizedBox ya estaría ahí antes del campo de Email
                    Row(
                      children: [
                        const Text(
                          'Correo:', // Ya lo tienes como 'Usuario/Correo'
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'ejemplo@dominio.com',
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
                          return 'El correo es obligatorio';
                        }
                        if (value.length < 6) { // Validación de mínimo 6 caracteres
                          return 'Mínimo 6 caracteres';
                        }
                        if (!value.contains('@')) { // Validación de que contenga @
                          return 'Ingrese un correo válido (debe contener "@")';
                        }
                        return null;
                      },
                    ),

                    // Ubícalo después de 'Email'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Celular:',
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
                      controller: _celularController,
                      keyboardType: TextInputType.phone, // Teclado telefónico
                      decoration: InputDecoration(
                        hintText: 'Ingrese su número de celular',
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
                          return 'El número de celular es obligatorio';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números';
                        }
                        if (value.length < 10) { // Mínimo 10 dígitos para celular
                          return 'Mínimo 10 dígitos';
                        }
                        return null;
                      },
                    ),

                    // Ubícalo después de 'Celular'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Teléfono Convencional:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        // No tiene asterisco si no es obligatorio, pero si lo es, lo añades:
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
                      controller: _telefonoConvencionalController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su teléfono convencional',
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
                          return 'El teléfono convencional es obligatorio'; // Cambiado a obligatorio
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números';
                        }
                        if (value.length < 7 || value.length > 10) { // Ejemplo de 7 a 10 dígitos
                          return 'Debe tener entre 7 y 10 dígitos';
                        }
                        return null;
                      },
                    ),


                    // Ubícalo después de 'Teléfono Convencional'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Parroquia:',
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
                      controller: _parroquiaDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su parroquia',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _parroquiaOptions.length,
                              itemBuilder: (context, index) {
                                final option = _parroquiaOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );

                        if (selectedValue != null) {
                          setState(() {
                            _selectedParroquia = selectedValue;
                            _parroquiaDisplayController.text = _parroquiaOptions
                                .firstWhere((option) => option['value'] == selectedValue)['label']!;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedParroquia == null || _selectedParroquia!.isEmpty) {
                          return 'La parroquia es obligatoria';
                        }
                        return null;
                      },
                    ),



                    // Ubícalo después de 'Parroquia'
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Programa Académico:',
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
                      controller: _programaAcademicoDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione un programa académico',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final String? selectedValue = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _programaAcademicoOptions.length,
                              itemBuilder: (context, index) {
                                final option = _programaAcademicoOptions[index];
                                return ListTile(
                                  title: Text(option['label']!),
                                  onTap: () {
                                    Navigator.pop(context, option['value']);
                                  },
                                );
                              },
                            );
                          },
                        );

                        if (selectedValue != null) {
                          setState(() {
                            _selectedProgramaAcademico = selectedValue;
                            _programaAcademicoDisplayController.text = _programaAcademicoOptions
                                .firstWhere((option) => option['value'] == selectedValue)['label']!;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedProgramaAcademico == null || _selectedProgramaAcademico!.isEmpty) {
                          return 'El programa académico es obligatorio';
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

