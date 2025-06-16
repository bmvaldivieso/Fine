// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/bindings/home_binding.dart';
import 'features/home/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English LMS',
      initialBinding: HomeBinding(),
      initialRoute: '/home',
      getPages: [
        GetPage(
          name: '/home',
          page: () {
            final indexParam = int.tryParse(Get.parameters['index'] ?? '0') ?? 0;
            return HomeView(initialIndex: indexParam);
          },
        ),
        // GetPage(name: '/login', page: () => LoginView()),
        // GetPage(name: '/settings', page: () => SettingsView()),
      ],
    );
  }
}
