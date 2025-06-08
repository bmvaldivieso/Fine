import 'package:flutter/material.dart';

Widget buildDrawerItem(
  IconData icon,
  String label,
  double screenWidth, {
  bool isActive = false,
  VoidCallback? onTap,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
    decoration: isActive
        ? BoxDecoration(
            color: const Color(0xFF0D1C45),
            borderRadius: BorderRadius.circular(18),
          )
        : null,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isActive ? Colors.white : Colors.black87,
        size: screenWidth * 0.06,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    ),
  );
}
