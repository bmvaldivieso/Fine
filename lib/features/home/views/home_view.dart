// lib/features/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_Controller.dart';
import 'course_view.dart';
import 'schedule_view.dart';
import 'notes_view.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

class HomeView extends GetView<HomeController> {
  final int initialIndex;

  const HomeView({super.key, this.initialIndex = 0});

  final List<Widget> _pages = const [
    CourseView(),
    ScheduleView(),
    Placeholder(),
    Placeholder(),
    NotesView(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<HomeController>(() => HomeController());
    Future.microtask(() {
      if (controller.currentIndex.value != initialIndex) {
        controller.changeTab(initialIndex);
      }
    });
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
      )),
    );
  }
}


