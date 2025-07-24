import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_Controller.dart';
import '../services/tokkenAccesLogin.dart';

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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final HomeController _homeController = Get.find<HomeController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = _userController.text.trim();
      final password = _passwordController.text.trim();
      print('Usuario: $user');
      print('Password: $password');

      final success = await AuthServiceLogin().login(user, password);

      if (success) {
        print('Login correcto. Token almacenado.');
        _showCustomSnackBar(context,
            message: '¡Login exitoso! Bienvenido, $user',
            color: Colors.green,
            icon: Icons.check_circle);
        _homeController.gotoHomeWithIndex(0, transitionType: 'offAll');
      } else {
        print('Credenciales inválidas.');
        _showCustomSnackBar(
          context,
          message: 'Credenciales incorrectas. Revisa usuario o contraseña.',
          color: Colors.red,
          icon: Icons.error_outline,
        );
      }
    }
  }

  void _showCustomSnackBar(BuildContext context,
      {required String message, required Color color, required IconData icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
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

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
          key: _formKey,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFA6C6FF),
                  Color(0xFF20059E),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * 0.60,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(85.0),
                        topRight: Radius.circular(85.0),
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.04,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.08,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Text(
                                  'Usuario:',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                TextFormField(
                                  controller: _userController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej. maria123',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El usuario es obligatorio';
                                    }
                                    if (value.length < 4) {
                                      return 'Mínimo 4 caracteres';
                                    }
                                    if (value.contains(' ')) {
                                      return 'No se permiten espacios';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Text(
                                  'Contraseña:',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Ej. 123',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'La contraseña es obligatoria';
                                    }
                                    if (value.length < 3) {
                                      return 'Mínimo 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.04),
                                SizedBox(
                                  width: screenWidth,
                                  child: ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF20059E),
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.02),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Ingresar',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                SizedBox(
                                  width: screenWidth,
                                  child: ElevatedButton(
                                    onPressed: _homeController.goToRegistro,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFA6C6FF),
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.02),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
                Positioned(
                  top: 55,
                  left: (screenWidth - screenWidth * 1.5) / 2,
                  right: (screenWidth - screenWidth * 1.1) / 2,
                  child: Image.asset(
                    'lib/assets/images/chica.png',
                    fit: BoxFit.contain,
                    height: screenHeight * 0.40,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
