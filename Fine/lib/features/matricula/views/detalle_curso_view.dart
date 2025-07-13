import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lms_english_app/core/models/componente_model.dart';
import 'package:lms_english_app/core/models/matricula_model.dart';
import 'package:lms_english_app/features/auth/services/matricula_service.dart';

class DetalleCursoView extends StatefulWidget {
  const DetalleCursoView({super.key});

  @override
  State<DetalleCursoView> createState() => _DetalleCursoViewState();
}

class _DetalleCursoViewState extends State<DetalleCursoView> {
  late Componente componente;
  String metodoPago = 'deposito';
  String medioEntero = 'redes_sociales';
  bool enviado = false;
  bool mostrandoDatosBancarios = false;
  String cuotas = '1'; // Valor por defecto

  final opcionesCuotas = {
    '1': '1 cuota',
    '2': '2 cuotas',
  };

  final _referenciaController = TextEditingController();
  final _montoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _idDepositanteController = TextEditingController();

  final _nombreTarjetaController = TextEditingController();
  final _numeroTarjetaController = TextEditingController();
  final _vencimientoController = TextEditingController();
  final _cvvController = TextEditingController();

  final MatriculaService _service = MatriculaService();

  final metodoPagoOpciones = {
    'deposito': 'Depósito',
    'transferencia': 'Transferencia',
    'tarjeta': 'Tarjeta (3 a 6 meses sin intereses)',
  };

  final medioEnteroOpciones = {
    'redes_sociales': 'Redes Sociales',
    'pagina_web': 'Página Web',
    'referido': 'Referido',
    'otro': 'Otro',
  };

  @override
  void initState() {
    super.initState();
    componente = Get.arguments as Componente;
  }

  Future<void> finalizarMatricula() async {
    // Validaciones si están visibles los campos
    if (mostrandoDatosBancarios) {
      if (metodoPago == 'deposito' || metodoPago == 'transferencia') {
        if (_referenciaController.text.isEmpty ||
            _montoController.text.isEmpty ||
            _fechaController.text.isEmpty ||
            _idDepositanteController.text.isEmpty) {
          Get.snackbar(
            'Campos incompletos',
            'Por favor llena todos los datos del depósito/transferencia antes de continuar.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (metodoPago == 'tarjeta') {
        if (_nombreTarjetaController.text.isEmpty ||
            _numeroTarjetaController.text.isEmpty ||
            _vencimientoController.text.isEmpty ||
            _cvvController.text.isEmpty) {
          Get.snackbar(
            'Campos incompletos',
            'Por favor llena todos los datos de la tarjeta antes de continuar.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    // Registro normal de la matrícula
    final matricula = Matricula(
      estudianteId: 0,
      componenteId: componente.id,
      metodoPago: metodoPago,
      medioEntero: medioEntero,
      cuotas: cuotas,
    );

    final result = await _service.registrarMatricula(matricula);
    if (result) {
      setState(() => enviado = true);

      // 1. Enviar datos bancarios si se mostraron
      if (mostrandoDatosBancarios) {
        await _service.registrarDatosPago(
          componenteId: componente.id,
          metodoPago: metodoPago,
          referencia: _referenciaController.text,
          monto: _montoController.text,
          fechaDeposito: _fechaController.text,
          idDepositante: _idDepositanteController.text,
          nombreTarjeta: _nombreTarjetaController.text,
          numeroTarjeta: _numeroTarjetaController.text,
          vencimiento: _vencimientoController.text,
          cvv: _cvvController.text,
        );
      }

      // 2. Mostrar mensaje
      Get.snackbar(
        '🎓 ¡Bienvenido al curso!',
        'Tu matrícula en ${componente.nombre} fue confirmada. Te deseamos mucho éxito en tu camino académico.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
      // 3. Redireccionar
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Error', 'Hubo un problema al registrar la matrícula',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget buildDropdown(String label, String value, Map<String, String> opciones,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: opciones.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Curso'),
        backgroundColor: const Color(0xFF2042A6),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(componente.nombre,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Programa: ${componente.programaAcademico}"),
              Text("Periodo: ${componente.periodo}"),
              Text("Horario: ${componente.horario}"),
              Text("Precio: \$${componente.precio}"),
              Text("Cupos disponibles: ${componente.cuposDisponibles}"),
              const SizedBox(height: 20),
              buildDropdown("Método de Pago", metodoPago, metodoPagoOpciones,
                  (val) {
                if (val != null) setState(() => metodoPago = val);
              }),
              const SizedBox(height: 15),
              buildDropdown(
                  "¿Cómo te enteraste?", medioEntero, medioEnteroOpciones,
                  (val) {
                if (val != null) setState(() => medioEntero = val);
              }),
              const SizedBox(height: 15),
              buildDropdown("Número de cuotas", cuotas, opcionesCuotas, (val) {
                if (val != null) setState(() => cuotas = val);
              }),
              const SizedBox(height: 15),
              if (mostrandoDatosBancarios) ...[
                if (metodoPago == 'deposito' ||
                    metodoPago == 'transferencia') ...[
                  const Text("Datos del depósito / transferencia",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _referenciaController,
                    decoration: const InputDecoration(
                        labelText: 'Número de referencia (6 dígitos)'),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextFormField(
                    controller: _montoController,
                    decoration: const InputDecoration(
                        labelText: 'Monto del depósito (máx. \$250)'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                  TextField(
                    controller: _fechaController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Fecha del depósito'),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        _fechaController.text =
                            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      }
                    },
                  ),
                  TextFormField(
                    controller: _idDepositanteController,
                    decoration:
                        const InputDecoration(labelText: 'ID depositante'),
                    maxLength: 20,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                        "Cuenta bancaria: BANCO DE LOJA CRECE DIARIO 2900939374"),
                  ),
                ],
                if (metodoPago == 'tarjeta') ...[
                  const Text("Datos de tarjeta",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreTarjetaController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre en la tarjeta'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
                    ],
                  ),
                  TextFormField(
                    controller: _numeroTarjetaController,
                    decoration: const InputDecoration(
                        labelText: 'Número de tarjeta (16 dígitos)'),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _vencimientoController,
                          decoration: const InputDecoration(
                              labelText: 'Vencimiento (MM/AA)'),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,2}/?\d{0,2}'))
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(labelText: 'CVV'),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => setState(
                    () => mostrandoDatosBancarios = !mostrandoDatosBancarios),
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text("Datos del Depósito",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2042A6)),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: enviado ? null : finalizarMatricula,
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text("Finalizar Matrícula",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
