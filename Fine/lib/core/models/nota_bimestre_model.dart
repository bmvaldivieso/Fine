class NotaBimestre {
  final int bimestre;
  final double tareas;
  final double lecciones;
  final double grupales;
  final double individuales;
  final int inasistencias;
  final double notaBimestre;

  NotaBimestre({
    required this.bimestre,
    required this.tareas,
    required this.lecciones,
    required this.grupales,
    required this.individuales,
    required this.inasistencias,
    required this.notaBimestre,
  });

  factory NotaBimestre.fromJson(Map<String, dynamic> json) {
    return NotaBimestre(
      bimestre: json['bimestre'],
      tareas: (json['tareas'] as num).toDouble(),
      lecciones: (json['lecciones'] as num).toDouble(),
      grupales: (json['grupales'] as num).toDouble(),
      individuales: (json['individuales'] as num).toDouble(),
      inasistencias: json['inasistencias'],
      notaBimestre: (json['nota_bimestre'] as num).toDouble(),
    );
  }
}
