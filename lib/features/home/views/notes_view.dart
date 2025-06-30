import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_english_app/utils/navigation_helper.dart';
import 'package:lms_english_app/widgets/custom_bottom_nav_bar.dart';
import 'package:lms_english_app/widgets/custom_drawer.dart';
import '../../../widgets/notes_header.dart';
import '../../../widgets/level_selector.dart';
import '../../../widgets/grades_table.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 127, 150, 228),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Iconsax.document,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NotesHeader(),
              SizedBox(height: screenHeight * 0.02),
              const LevelSelector(),
              SizedBox(height: screenHeight * 0.02),
              const GradesTable(),
            ],
          ),
        ),
      ),
    );
  }
}
