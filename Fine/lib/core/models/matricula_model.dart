class Matricula {
  final int estudianteId;
  final int componenteId;
  final String metodoPago;
  final String medioEntero;
  final String cuotas;

  Matricula({
    required this.estudianteId,
    required this.componenteId,
    required this.metodoPago,
    required this.medioEntero,
    required this.cuotas,
  });

  Map<String, dynamic> toJson() {
    return {
      'componente_id': componenteId,
      'metodo_pago': metodoPago,
      'medio_entero': medioEntero,
      'cuotas': cuotas,
    };
  }
}

