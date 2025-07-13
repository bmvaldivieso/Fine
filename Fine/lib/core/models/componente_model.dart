class Componente {
  final int id;
  final String nombre;
  final String programaAcademico;
  final String periodo;
  final String horario;
  final int cuposDisponibles;
  final double precio;

  Componente({
    required this.id,
    required this.nombre,
    required this.programaAcademico,
    required this.periodo,
    required this.horario,
    required this.cuposDisponibles,
    required this.precio,
  });

  factory Componente.fromJson(Map<String, dynamic> json) {
    return Componente(
      id: json['id'],
      nombre: json['nombre'],
      programaAcademico: json['programa_academico'],
      periodo: json['periodo'],
      horario: json['horario'],
      cuposDisponibles: json['cupos_disponibles'],
      precio: (json['precio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'programa_academico': programaAcademico,
      'periodo': periodo,
      'horario': horario,
      'cupos_disponibles': cuposDisponibles,
      'precio': precio,
    };
  }
}
