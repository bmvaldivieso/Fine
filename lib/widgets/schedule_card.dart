import 'package:flutter/material.dart';

Widget buildScheduleCard({
  required double screenWidth,
  required String startTime,
  required String endTime,
  required String title,
  required String docente,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              startTime,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(endTime),
          ],
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 60, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFF5177),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Paralelo: A\nNivel: A1\nModalidad: Presencial'),
              Text('Docente: $docente'),
            ],
          ),
        ),
      ],
    ),
  );
}
