import 'package:flutter/material.dart';
import 'package:lms_english_app/core/models/nota_bimestre_model.dart';

class GradesTable extends StatelessWidget {
  final List<NotaBimestre> notas;

  const GradesTable({super.key, required this.notas});

  @override
  Widget build(BuildContext context) {
    const headerStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF5A3ED1), Color(0xFF212092)]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                    child:
                        Center(child: Text("Categoría", style: headerStyle))),
                Expanded(
                    child:
                        Center(child: Text("1º Bimestre", style: headerStyle))),
                Expanded(
                    child:
                        Center(child: Text("2º Bimestre", style: headerStyle))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          buildRow(
            "Tareas",
            bimestreValue(notas, 1, (n) => n.tareas),
            bimestreValue(notas, 2, (n) => n.tareas),
          ),
          buildRow(
            "Lecciones",
            bimestreValue(notas, 1, (n) => n.lecciones),
            bimestreValue(notas, 2, (n) => n.lecciones),
          ),
          buildRow(
            "Grupales",
            bimestreValue(notas, 1, (n) => n.grupales),
            bimestreValue(notas, 2, (n) => n.grupales),
          ),
          buildRow(
            "Individuales",
            bimestreValue(notas, 1, (n) => n.individuales),
            bimestreValue(notas, 2, (n) => n.individuales),
          ),
          buildRow(
            "Promedio",
            bimestreValue(notas, 1, (n) => n.notaBimestre),
            bimestreValue(notas, 2, (n) => n.notaBimestre),
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

  String bimestreValue(
    List<NotaBimestre> notas,
    int bimestre,
    double Function(NotaBimestre nota) extractor,
  ) {
    final nota = notas.firstWhere((n) => n.bimestre == bimestre,
        orElse: () => NotaBimestre(
              bimestre: bimestre,
              tareas: 0,
              lecciones: 0,
              grupales: 0,
              individuales: 0,
              inasistencias: 0,
              notaBimestre: 0,
            ));
    return extractor(nota).toStringAsFixed(0);
  }
}
