class FormularioEstudiante {
  // Estudiante
  String? tipoIdentificacion;
  String? identificacion;
  String? nombresApellidos;
  DateTime? fechaNacimiento;
  String? genero;
  String? ocupacion;
  String? nivelEstudio;
  String? lugarEstudioTrabajo;
  String? direccion;
  String? email;
  String? celular;
  String? telefonoConvencional;
  String? parroquia;
  String? programaAcademico;


  Map<String, dynamic> toJson() {
    return {
      "tipo_identificacion": tipoIdentificacion,
      "identificacion": identificacion,
      "nombres_apellidos": nombresApellidos,
      "fecha_nacimiento": fechaNacimiento?.toIso8601String(),
      "genero": genero,
      "ocupacion": ocupacion,
      "nivel_estudio": nivelEstudio,
      "lugar_estudio_trabajo": lugarEstudioTrabajo,
      "direccion": direccion,
      "email": email,
      "celular": celular,
      "telefono_convencional": telefonoConvencional,
      "parroquia": parroquia,
      "programa_academico": programaAcademico,
    };
  }
}

class FormularioRepresentante {
  // Representante
  bool emitirFacturaAlEstudiante = false;
  String? tipoIdentificacion;
  String? identificacion;
  String? razonSocial;
  String? direccion;
  String? email;
  String? celular;
  String? telefonoConvencional;
  String? sexo;
  String? estadoCivil;
  String? origenIngresos;
  String? parroquia;

  Map<String, dynamic> toJson() {
    return {
      "emitir_factura_al_estudiante": emitirFacturaAlEstudiante,
      "rep_tipo_identificacion": tipoIdentificacion,
      "rep_identificacion": identificacion,
      "rep_razon_social": razonSocial,
      "rep_direccion": direccion,
      "rep_email": email,
      "rep_celular": celular,
      "rep_telefono_convencional": telefonoConvencional,
      "rep_sexo": sexo,
      "rep_estado_civil": estadoCivil,
      "rep_origen_ingresos": origenIngresos,
      "rep_parroquia": parroquia,
    };
  }
}

class FormularioUser {
  // Usuario
  String? user;
  String? password;
  String? confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      "user": user,
      "password": password,
      "confirm_password": confirmPassword,
    };
  }
}
