import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MatriculaInicioView extends StatelessWidget {
  const MatriculaInicioView({super.key});

  void _iniciarMatricula() {
    Get.toNamed('/paralelos');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF7F96E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2042A6),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Iconsax.document_text, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Matrícula',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: screenWidth * 0.85,
          padding: EdgeInsets.all(screenWidth * 0.08),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: screenWidth * 0.15, color: const Color(0xFFFF0150)),
              const SizedBox(height: 20),
              Text(
                '¿Listo para comenzar tu matrícula?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _iniciarMatricula,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Iniciar Matrícula', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0150),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
