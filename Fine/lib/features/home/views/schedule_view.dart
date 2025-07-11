// schedule_view.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_english_app/utils/navigation_helper.dart';
import '../../../widgets/schedule_card.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_bottom_nav_bar.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 127, 150, 228),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Día de la semana',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final day in [
                    'Lun',
                    'Mar',
                    'Mi',
                    'Ju',
                    'Vie',
                    'Sab',
                    'Dom',
                  ])
                    Container(
                      margin: EdgeInsets.only(right: screenWidth * 0.02),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: day == 'Lun'
                            ? const Color(0xFFFF5177)
                            : Color(0xFF2042A6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Lunes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            buildScheduleCard(
              screenWidth: screenWidth,
              startTime: '9:00 AM',
              endTime: '10:00 AM',
              title: 'Grammatical',
              docente: 'Lic. Cinthia Rojas',
            ),
            buildScheduleCard(
              screenWidth: screenWidth,
              startTime: '13:00 PM',
              endTime: '15:00 PM',
              title: 'Practice class',
              docente: 'Lic. Cinthia Rojas',
            ),
          ],
        ),
      ),
    );
  }
}
