class AnuncioDetalle {
  final String titulo;
  final String contenido;
  final List<String> imagenes;
  final List<ArchivoAdjunto> archivos;
  final List<EnlaceWeb> enlaces;
  final String fecha;

  AnuncioDetalle({
    required this.titulo,
    required this.contenido,
    required this.imagenes,
    required this.archivos,
    required this.enlaces,
    required this.fecha,
  });

  factory AnuncioDetalle.fromJson(Map<String, dynamic> json) {
    return AnuncioDetalle(
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      imagenes: List<String>.from(json['imagenes'] ?? []),
      archivos: (json['archivos'] ?? [])
          .map<ArchivoAdjunto>((a) => ArchivoAdjunto.fromJson(a))
          .toList(),
      enlaces: (json['enlaces'] ?? [])
          .map<EnlaceWeb>((e) => EnlaceWeb.fromJson(e))
          .toList(),
      fecha: json['fecha_creacion'] ?? '',
    );
  }
}

class ArchivoAdjunto {
  final String nombre;
  final String url;
  final String tipo;

  ArchivoAdjunto({
    required this.nombre,
    required this.url,
    required this.tipo,
  });

  factory ArchivoAdjunto.fromJson(Map<String, dynamic> json) {
    return ArchivoAdjunto(
      nombre: json['nombre'] ?? '',
      url: json['url'] ?? '',
      tipo: json['tipo'] ?? '',
    );
  }
}

class EnlaceWeb {
  final String nombre;
  final String url;

  EnlaceWeb({
    required this.nombre,
    required this.url,
  });

  factory EnlaceWeb.fromJson(Map<String, dynamic> json) {
    return EnlaceWeb(
      nombre: json['nombre'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
