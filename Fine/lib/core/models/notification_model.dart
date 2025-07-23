class NotificationModel {
  final int id;
  final String tipo;
  final String descripcion;
  final String fecha;
  final String? tareaTitulo;
  final String? componente;
  final double? calificacion;
  final int? intentoNumero;

  NotificationModel({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    this.tareaTitulo,
    this.componente,
    this.calificacion,
    this.intentoNumero,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      fecha: json['fecha'],
      tareaTitulo: json['tarea_titulo'],
      componente: json['componente'],
      calificacion: json['calificacion']?.toDouble(),
      intentoNumero: json['intento_numero'],
    );
  }
}
