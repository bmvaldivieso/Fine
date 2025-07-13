import 'package:flutter/material.dart';

class NotesHeader extends StatelessWidget {
  const NotesHeader({super.key, required this.studentname});

  final String studentname;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Notes",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Student: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFF4F9A),
                ),
              ),
              TextSpan(
                text: studentname,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Seleccionar Nivel",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
