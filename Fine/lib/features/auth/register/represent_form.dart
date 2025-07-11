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
      home: RegisterScreenRepresentante(),
    );
  }
}

class RegisterScreenRepresentante extends StatefulWidget {
  const RegisterScreenRepresentante({super.key});
  @override
  RepresentForm createState() => RepresentForm();
}


class RepresentForm extends State<RegisterScreenRepresentante> {
  late final HomeController _homeController = Get.find<HomeController>();
  final _formKey = GlobalKey<FormState>();
  late bool _emitirFactura = false;
  final List<Map<String, String>> _tipoIdentificacionOptions = const [{'value': 'cedula', 'label': 'Cédula'}, {'value': 'ruc', 'label': 'RUC'}, {'value': 'pasaporte', 'label': 'Pasaporte'}, {'value': 'extranjero', 'label': 'Extranjero'},];
  final TextEditingController _identificacionController = TextEditingController();
  final TextEditingController _tipoIdentificacionDisplayController = TextEditingController();
  final TextEditingController _razonSocial = TextEditingController();
  final TextEditingController _generoDisplayController = TextEditingController();
  final List<Map<String, String>> _generoOptions = const [{'value': 'M', 'label': 'Masculino'}, {'value': 'F', 'label': 'Femenino'},];
  final TextEditingController _origenDisplayController = TextEditingController();
  final List<Map<String, String>> _origenIngresosOptions = const [{'value': 'empleado_publico', 'label': 'Empleado Publico'}, {'value': 'empleado_privado', 'label': 'Empleado privado'}, {'value': 'independiente', 'label': 'Independiente'}, {'value': 'ama_de_casa', 'label': 'Ama de casa'}, {'value': 'remesa', 'label': 'Remesa del Exterior'}];
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _telefonoConvencionalController = TextEditingController();
  final TextEditingController _parroquiaDisplayController = TextEditingController();
  final List<Map<String, String>> _parroquiaOptions = const [{'value': 'el_valle', 'label': 'El Valle'}, {'value': 'el_sagrario', 'label': 'El Sagrario'}, {'value': 'san_sebastian', 'label': 'San Sebastián'},];
  final TextEditingController _civilDisplayController = TextEditingController();
  final List<Map<String, String>> _estadoCiviOptions = const [{'value': 'soltero', 'label': 'Soltero'}, {'value': 'casado', 'label': 'Casado'}, {'value': 'divorciado', 'label': 'Divorsiado'}, {'value': 'viudo', 'label': 'Viudo'},];

  String? _selectOriginIngresos;
  String? _selectedGenero;
  String? _selectedTipoIdentificacion;
  String? _selectedParroquia;
  String? _selectEstadoCivil;


  @override
  void dispose() {
    _identificacionController.dispose();
    _tipoIdentificacionDisplayController.dispose();
    _generoDisplayController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _telefonoConvencionalController.dispose();
    _razonSocial.dispose();
    _origenDisplayController.dispose();
    _civilDisplayController.dispose();
    _parroquiaDisplayController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistroProvider>(context, listen: false);
    final formEstudi = Provider.of<RegistroProvider>(context).estudiante;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;



    Future<void> submitForm() async {
      if (_formKey.currentState!.validate()) {
        final String email = _emailController.text;
        final String? tipoIdentificacion = _selectedTipoIdentificacion;
        final String identificacion = _identificacionController.text;
        final String razonSocial = _razonSocial.text;
        final String? genero = _selectedGenero;
        final String? estadoCivil = _selectEstadoCivil;
        final String? origenIngresos = _selectOriginIngresos;
        final bool facturaEmit = _emitirFactura;
        final String direccion = _direccionController.text;
        final String celular = _celularController.text;
        final String telefonoConvencional = _telefonoConvencionalController.text;
        final String? parroquia = _selectedParroquia;

        print('--- Datos del Formulario Representante ---');
        print('Correo: $email');
        print('Tipo de Identificación: $tipoIdentificacion');
        print('Número de Identificación: $identificacion');
        print('Razon social: $razonSocial');
        print('Género: $genero');
        print('estado Civil: $estadoCivil');
        print('Origen Ingresos: $origenIngresos');
        print('factura Emitida: $facturaEmit');
        print('Dirección: $direccion');
        print('Celular: $celular');
        print('Teléfono Convencional: $telefonoConvencional');
        print('Parroquia: $parroquia');
        print('---------------------------');

        //guardamos en el provaider//
        provider.actualizarRepresentante(
          emitirFacturaAlEstudiante:facturaEmit,
          tipoIdentificacion:tipoIdentificacion,
          identificacion:identificacion,
          razonSocial:razonSocial,
          direccion:direccion,
          email:email,
          celular:celular,
          telefonoConvencional:telefonoConvencional,
          sexo:genero,
          estadoCivil:estadoCivil,
          origenIngresos:origenIngresos,
          parroquia:parroquia,
        );
        //aqui llamar al ultimo paso del registro//
        _homeController.goToUserRegister();
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
                      'Representante',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Datos personales del Representante',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),

                    CheckboxListTile(
                      title: const Text(
                        'Emitir factura al estudiante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      value: _emitirFactura, // <-- Vinculado a la variable de estado
                      onChanged: (bool? newValue) {
                        setState(() {
                          _emitirFactura = newValue ?? false; // <-- Actualiza la variable y redibuja
                          if (_emitirFactura) {

                            print('Checkbox: Factura marcada para emitir $_emitirFactura.');
                            print("Correo del estudiante: ${formEstudi.email}");
                            _selectedTipoIdentificacion=formEstudi.tipoIdentificacion!;
                            _tipoIdentificacionDisplayController.text = formEstudi.tipoIdentificacion!;
                            _identificacionController.text = formEstudi.identificacion!;
                            _razonSocial.text = formEstudi.nombresApellidos!;
                            _direccionController.text = formEstudi.direccion!;
                            _emailController.text = formEstudi.email!;
                            _celularController.text = formEstudi.celular!;
                            _telefonoConvencionalController.text = formEstudi.telefonoConvencional!;

                          } else {
                            print('Checkbox: Factura desmarcada.');
                            _selectedTipoIdentificacion='';
                            _tipoIdentificacionDisplayController.text = '';
                            _identificacionController.text = '';
                            _razonSocial.text = '';
                            _direccionController.text = '';
                            _emailController.text = '';
                            _celularController.text = '';
                            _telefonoConvencionalController.text = '';
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading, // Checkbox a la izquierda
                      activeColor: const Color(0xFF20059E), // Color del checkbox cuando está marcado
                    ),
                    const SizedBox(height: 20),

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
                          'Razon Social:',
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
                      controller: _razonSocial,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Ingresa Razon social',
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
                          return 'este campo es reuqerido';
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
                          'Sexo:',
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
                          'Estado Civil:',
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
                      controller: _civilDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su estado civil',
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
                              itemCount: _estadoCiviOptions.length,
                              itemBuilder: (context, index) {
                                final option = _estadoCiviOptions[index];
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
                            _selectEstadoCivil = selectedValue;
                            _civilDisplayController.text = _estadoCiviOptions.firstWhere((option) => option['value'] == selectedValue)['label']!;});
                        }
                      },
                      validator: (value) {
                        if (_selectEstadoCivil == null || _selectEstadoCivil!.isEmpty) {
                          return 'El estado civil es obligatorio';
                        }
                        return null;
                      },
                    ),





                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Origen Ingresos:',
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
                      controller: _origenDisplayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione su fuente de Ingresos',
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
                              itemCount: _origenIngresosOptions.length,
                              itemBuilder: (context, index) {
                                final option = _origenIngresosOptions[index];
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
                            _selectOriginIngresos = selectedValue;
                            _origenDisplayController.text = _origenIngresosOptions
                                .firstWhere((option) => option['value'] == selectedValue)['label']!;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectOriginIngresos == null || _selectOriginIngresos!.isEmpty) {
                          return 'la fuente de ingresos es obligatoria';
                        }
                        return null;
                      },
                    ),


                    // Ubícalo después de 'Nivel de Estudio'
                    const SizedBox(height: 20),

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
                          'Email:', // Ya lo tienes como 'Usuario/Correo'
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

