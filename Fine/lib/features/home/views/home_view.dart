// lib/features/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_english_app/features/home/views/homework_view.dart';
import 'package:lms_english_app/features/home/views/submit_homework_view.dart';
import 'package:lms_english_app/features/matricula/views/componentes_view.dart';
import 'package:lms_english_app/features/matricula/views/detalle_curso_view.dart';
import 'package:lms_english_app/features/matricula/views/matricula_inicio_view.dart';
import '../../../shared/widgets/notMatricula.dart';
import '../controllers/home_Controller.dart';
import 'course_view.dart';
import 'schedule_view.dart';
import 'notes_view.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';
import 'listado_anuncios.dart';

class HomeView extends GetView<HomeController> {
  final int initialIndex;

  HomeView({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> _pages = [
      const ScheduleView(), //Indice 0
      const CourseView(),
      const Placeholder(), //Indice 2 //Indice 1
      ListaAnunciosPage(), //Indice 3
      //drawer
      const NotesView(), //Indice 4
      //validacionMatricula la pantalla es llamada si no hay matricula//
      //EnrollPromptView(),
      const MatriculaInicioView(), //Indice 5
      const ComponentesView(), //Indice 6
      const DetalleCursoView(), //Indice 7
      const HomeworkView(), //Indice 8
      Obx(() {
        final tarea = controller.tareaSeleccionada.value;
        if (tarea == null) return const Center(child: Text('Sin asignación'));
        return SubmitHomeworkView(asignacion: tarea);
      }), //Indice 9
    ];

    //importante no mover esto nos ayuda a regresar al home para navegar
    //a la siguiente pantalla que nosotros queramos//
    Get.lazyPut<HomeController>(() => HomeController());
    Future.microtask(() {
      if (controller.currentIndex.value != initialIndex) {
        controller.changeTab(initialIndex);
      }
    });

    return Scaffold(
      //tenemos el drawer//
      drawer: const CustomDrawer(),
      //tenemos el appbar//
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Iconsax.clock, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Schedule',
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
      //tenemos el body aqui se renderiza todas las pantallas//
      body: Obx(() => _pages[controller.currentIndex.value]),
      //tenemos el footer//
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          )),
    );
  }
}
