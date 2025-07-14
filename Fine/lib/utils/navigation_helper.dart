import 'package:flutter/material.dart';

void handleBottomNavTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushNamed(context, '/home');
      break;
    case 1:
      Navigator.pushNamed(context, '/course');
      break;
    case 2:
      Navigator.pushNamed(context, '/messages');
      break;
    case 3:
      Navigator.pushNamed(context, '/schedule');
      break;
  }
}

void goToSubmitHomework(BuildContext context, Map<String, dynamic> tarea) {
  Navigator.pushNamed(
    context,
    '/submit-homework',
    arguments: tarea,
  );
}

