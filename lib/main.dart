import 'package:flutter/material.dart';

import 'package:lms_english_app/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'English LMS',
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 22),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
      ),
      initialRoute: '/course',
      routes: {
        '/course': (context) => const CourseView(),
        '/schedule': (context) => const ScheduleView(),
        '/notes': (context) => const NotesView(),
      },
    );
  }
}
