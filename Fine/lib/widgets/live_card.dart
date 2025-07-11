import 'package:flutter/material.dart';

Widget buildLiveCard({
  required BuildContext context,
  required String title,
  required String description,
  required Gradient gradient,
  required IconData icon,
  required Color btnColor,
  required Color textColor,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(15),
    ),
    padding: EdgeInsets.all(screenWidth * 0.04),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: screenWidth * 0.1),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
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
              SizedBox(height: screenHeight * 0.005),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Join Class', style: TextStyle(color: textColor)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
