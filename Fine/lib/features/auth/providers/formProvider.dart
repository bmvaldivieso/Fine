import 'package:flutter/material.dart';
import '../models/Form.dart';


class RegistroProvider with ChangeNotifier {
  final FormularioEstudiante _formEstudiante = FormularioEstudiante();
  final FormularioRepresentante _formRepresentante = FormularioRepresentante();
  final FormularioUser _formUser = FormularioUser();


  FormularioEstudiante get estudiante => _formEstudiante;
  FormularioRepresentante get representante => _formRepresentante;
  FormularioUser get user => _formUser;

  void actualizarEstudiante({
    required String email,
    required String? tipoIdentificacion,
    required String identificacion,
    required String nombresApellidos,
    required DateTime? fechaNacimiento,
    required String? genero,
    required String? ocupacion,
    required String? nivelEstudio,
    required String lugarEstudioTrabajo,
    required String direccion,
    required String celular,
    required String telefonoConvencional,
    required String? parroquia,
    required String? programaAcademico,
  }) {
    _formEstudiante.email = email;
    _formEstudiante.tipoIdentificacion = tipoIdentificacion;
    _formEstudiante.identificacion = identificacion;
    _formEstudiante.nombresApellidos = nombresApellidos;
    _formEstudiante.fechaNacimiento = fechaNacimiento;
    _formEstudiante.genero = genero;
    _formEstudiante.ocupacion = ocupacion;
    _formEstudiante.nivelEstudio = nivelEstudio;
    _formEstudiante.lugarEstudioTrabajo = lugarEstudioTrabajo;
    _formEstudiante.direccion = direccion;
    _formEstudiante.celular = celular;
    _formEstudiante.telefonoConvencional = telefonoConvencional;
    _formEstudiante.parroquia = parroquia;
    _formEstudiante.programaAcademico = programaAcademico;
    notifyListeners();
  }

  // Actualizar representante
  void actualizarRepresentante({
    required bool emitirFacturaAlEstudiante,
    required String? tipoIdentificacion,
    required String? identificacion,
    required String? razonSocial,
    required String? direccion,
    required String? email,
    required String? celular,
    required String? telefonoConvencional,
    required String? sexo,
    required String? estadoCivil,
    required String? origenIngresos,
    required String? parroquia,
  }) {
    _formRepresentante.emitirFacturaAlEstudiante = emitirFacturaAlEstudiante;
    _formRepresentante.tipoIdentificacion = tipoIdentificacion;
    _formRepresentante.identificacion = identificacion;
    _formRepresentante.razonSocial = razonSocial;
    _formRepresentante.direccion = direccion;
    _formRepresentante.email = email;
    _formRepresentante.celular = celular;
    _formRepresentante.telefonoConvencional = telefonoConvencional;
    _formRepresentante.sexo = sexo;
    _formRepresentante.estadoCivil = estadoCivil;
    _formRepresentante.origenIngresos = origenIngresos;
    _formRepresentante.parroquia = parroquia;
    notifyListeners();
  }

  // Actualizar representante
  void actualizarUser({
    required String? user,
    required String? password,
    required String? confrimPassword,
  }) {
    _formUser.user = user;
    _formUser.password = password;
    _formUser.confirmPassword = confrimPassword;
    notifyListeners();
  }

  //final form = Provider.of<RegistroProvider>(context).estudiante;
  //print("Correo del estudiante: ${form.email}");

}



