import 'package:flutter/material.dart';

class GradesTable extends StatelessWidget {
  const GradesTable({super.key});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    // const rowStyle = TextStyle(fontSize: 14);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A3ED1), Color(0xFF212092)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Center(child: Text("Categoria", style: headerStyle)),
                ),
                Expanded(
                  child: Center(child: Text("1 Bimestre", style: headerStyle)),
                ),
                Expanded(
                  child: Center(child: Text("2 Bimestre", style: headerStyle)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          buildRow("Tareas", "22", "20"),
          buildRow("Lecciones", "18", "18"),
          buildRow("Grupales", "26", "20"),
          buildRow("Individuales", "26", "27"),
          buildRow("Recuperacion", "-", "-"),
          buildRow("Final", "92", "85"),
          const SizedBox(height: 15),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Nota Final: 91,5",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2845B9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(String label, String b1, String b2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(child: Center(child: Text(b1))),
          Expanded(child: Center(child: Text(b2))),
        ],
      ),
    );
  }
}
