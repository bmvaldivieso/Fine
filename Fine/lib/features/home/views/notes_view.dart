import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lms_english_app/core/services/service_MatriculaValidate.dart';
import '../../../widgets/notes_header.dart';
import '../../../widgets/level_selector.dart';
import '../../../widgets/grades_table.dart';
import '../controllers/home_Controller.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  bool _cargando = true;
  bool _tieneMatricula = false;
  late final HomeController _homeController = Get.find<HomeController>();


  @override
  void initState() {
    super.initState();
    _verificarMatricula();
  }

  void _verificarMatricula() async {
    final authService = MatService();
    bool resultado = await authService.validarMatricula();
    if (!mounted) return;
    if (!resultado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeController.gotoHomeWithIndex(5, transitionType: 'offAll');
      });
    } else {
      setState(() {
        _tieneMatricula = true;
        _cargando = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 127, 150, 228),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.document_scanner, color: Colors.white, size: screenWidth * 0.06),
            SizedBox(width: screenWidth * 0.02),
            Text('Notes', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotesHeader(),
              SizedBox(height: 20),
              LevelSelector(),
              SizedBox(height: 20),
              GradesTable(),
            ],
          ),
        ),
      ),
    );
  }
}




















