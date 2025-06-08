import 'package:flutter/material.dart';

Widget buildSimpleCard({
  required BuildContext context,
  required String title,
  required Color color1,
  required Color color2,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  // final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2]),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
