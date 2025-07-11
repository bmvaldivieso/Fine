// views/empty/enroll_prompt_view.dart
import 'package:flutter/material.dart';

class EnrollPromptView extends StatelessWidget {
  const EnrollPromptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                'No tienes matrícula actualmente.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Por favor matricúlate para acceder a este Contenido.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Redirige a pantalla de matrícula si la tienes
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Matricúlate'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
