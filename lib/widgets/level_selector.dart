import 'package:flutter/material.dart';

class LevelSelector extends StatefulWidget {
  const LevelSelector({super.key});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  String selectedLevel = 'Nivel A1';
  final List<String> levels = [
    'Nivel A1',
    'Nivel A2',
    'Nivel B1',
    'Nivel B2',
    'Nivel C1',
  ];

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nivel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: levels.length * 2,
                itemBuilder: (context, index) {
                  if (index.isEven) {
                    return const Divider(height: 1);
                  } else {
                    final levelIndex = index ~/ 2;
                    final level = levels[levelIndex];
                    final isSelected = level == selectedLevel;

                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFBD3E9),
                                    Color(0xFFBBDEFB),
                                  ],
                                ),
                              )
                            : null,
                        child: Text(
                          level,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedLevel = level;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4F9A),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedLevel,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
