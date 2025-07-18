import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_english_app/features/home/views/review_submission_view.dart';
import 'package:lms_english_app/features/matricula/views/componentes_view.dart';
import 'package:lms_english_app/features/matricula/views/detalle_curso_view.dart';
import 'package:lms_english_app/features/matricula/views/matricula_inicio_view.dart';
import 'package:provider/provider.dart';
import 'core/bindings/home_binding.dart';
import 'features/auth/providers/formProvider.dart';
import 'features/auth/services/tokkenAccesLogin.dart';
import 'features/home/views/home_view.dart';
import 'features/auth/login/login_auth.dart';
import 'features/home/controllers/home_Controller.dart';
import 'features/home/views/submit_homework_view.dart';

void main() {
  Get.put(HomeController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistroProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<String> _getInitialRoute() async {
    final token = await AuthServiceLogin().getAccessToken();
    return token != null ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'English LMS',
          smartManagement: SmartManagement.keepFactory,
          initialBinding: HomeBinding(),
          initialRoute: snapshot.data!,
          getPages: [
            GetPage(
              name: '/home',
              page: () {
                final indexParam =
                    int.tryParse(Get.parameters['index'] ?? '0') ?? 0;
                return HomeView(initialIndex: indexParam);
              },
            ),
            GetPage(name: '/login', page: () => LoginScreen()),
            GetPage(
                name: '/detalle-curso', page: () => const DetalleCursoView()),
            GetPage(
                name: '/matricula', page: () => const MatriculaInicioView()),
            GetPage(name: '/paralelos', page: () => const ComponentesView()),
            GetPage(
              name: '/submit-homework',
              page: () => SubmitHomeworkView(
                asignacion: Get.arguments as Map<String, dynamic>,
              ),
            ),
            GetPage(
              name: '/review-submission',
              page: () => ReviewSubmissionView(
                asignacion: Get.arguments as Map<String, dynamic>,
              ),
            ),
          ],
        );
      },
    );
  }
}
