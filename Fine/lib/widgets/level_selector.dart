import 'package:flutter/material.dart';

class LevelSelector extends StatefulWidget {
  final List<String> componentes;
  final ValueChanged<String> onSelected;

  const LevelSelector({
    super.key,
    required this.componentes,
    required this.onSelected,
  });

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  late String selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.componentes.isNotEmpty
        ? widget.componentes.first
        : 'Sin componentes';
  }

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
            const Text('Selecciona Componente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.componentes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final nivel = widget.componentes[index];
                  final isSelected = nivel == selectedLevel;

                  return ListTile(
                    title: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBD3E9), Color(0xFFBBDEFB)],
                              ),
                            )
                          : null,
                      child: Text(nivel, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                    onTap: () {
                      setState(() => selectedLevel = nivel);
                      widget.onSelected(nivel); // ⬅️ Notifica al padre
                      Navigator.pop(context);
                    },
                  );
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedLevel, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
