import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/services/service_MatriculaValidate.dart';
import '../../../widgets/live_card.dart';
import '../../../widgets/activity_card.dart';
import '../../../widgets/simple_card.dart';
import '../../../widgets/custom_drawer.dart';
import '../controllers/home_Controller.dart';



class CourseView extends StatefulWidget {
  const CourseView({super.key});
  @override
  State<CourseView> createState() => _CourseView();
}


class _CourseView extends State<CourseView> {
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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 127, 150, 228),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.school, color: Colors.white, size: screenWidth * 0.06),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'My Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class online',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            buildLiveCard(
              context: context,
              title: 'Grammatical',
              description: 'Deepens grammatical structures',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5177), Color(0xFFE4376F)],
              ),
              icon: Icons.headphones,
              btnColor: Colors.white,
              textColor: const Color(0xFFE4376F),
            ),
            SizedBox(height: screenHeight * 0.015),
            buildLiveCard(
              context: context,
              title: 'Practice class',
              description: 'Deepens grammatical structures',
              gradient: const LinearGradient(
                colors: [Color(0xFF4A77FF), Color(0xFF2641DB)],
              ),
              icon: Icons.headphones,
              btnColor: Colors.white,
              textColor: const Color(0xFF2641DB),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Activities',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.03,
              mainAxisSpacing: screenWidth * 0.03,
              childAspectRatio: 3 / 2.6,
              children: [
                buildActivityCard(
                  context: context,
                  title: 'Listen',
                  subtitle: '20 levels in total\n5 completed\n15 to complete',
                  color1: const Color(0xFF5A48FF),
                  color2: const Color(0xFF3124D8),
                ),
                buildSimpleCard(
                  context: context,
                  title: 'Game',
                  color1: Colors.orange,
                  color2: Colors.redAccent,
                ),
                buildSimpleCard(
                  context: context,
                  title: 'Game',
                  color1: Colors.purple,
                  color2: Colors.blue,
                ),
                buildSimpleCard(
                  context: context,
                  title: 'Homework',
                  color1: Colors.cyan,
                  color2: Colors.blueAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
