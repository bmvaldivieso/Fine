import 'package:flutter/material.dart';

Widget buildActivityCard({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Color color1,
  required Color color2,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2]),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
        ),
      ],
    ),
  );
}
