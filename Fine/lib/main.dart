import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'core/bindings/home_binding.dart';
import 'features/auth/providers/formProvider.dart';
import 'features/auth/services/tokkenAccesLogin.dart';
import 'features/home/views/home_view.dart';
import 'features/auth/login/login_auth.dart';
import 'features/home/controllers/home_Controller.dart';


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
                final indexParam = int.tryParse(Get.parameters['index'] ?? '0') ?? 0;
                return HomeView(initialIndex: indexParam);
              },
            ),
            GetPage(name: '/login', page: () => LoginScreen()),
          ],
        );
      },
    );
  }
}






