class Anuncio {
  final int id;
  final String titulo;
  final DateTime fechaCreacion;

  Anuncio({required this.id, required this.titulo, required this.fechaCreacion});

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      id: json['id'],
      titulo: json['titulo'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
