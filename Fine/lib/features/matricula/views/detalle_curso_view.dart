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
  String cuotas = '1';

  final opcionesCuotas = {'1': '1 cuota', '2': '2 cuotas'};

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
    if (mostrandoDatosBancarios) {
      if (metodoPago == 'deposito' || metodoPago == 'transferencia') {
        if (_referenciaController.text.isEmpty ||
            _montoController.text.isEmpty ||
            _fechaController.text.isEmpty ||
            _idDepositanteController.text.isEmpty) {
          Get.snackbar('Campos incompletos',
              'Por favor llena todos los datos del depósito/transferencia.',
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
      }

      if (metodoPago == 'tarjeta') {
        if (_nombreTarjetaController.text.isEmpty ||
            _numeroTarjetaController.text.isEmpty ||
            _vencimientoController.text.isEmpty ||
            _cvvController.text.isEmpty) {
          Get.snackbar('Campos incompletos',
              'Por favor llena todos los datos de la tarjeta.',
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
      }
    }

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

      Get.snackbar('🎓 ¡Bienvenido al curso!',
          'Tu matrícula en ${componente.nombre} fue confirmada.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM);
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: opciones.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Curso', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2042A6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(componente.nombre,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📘 Programa: ${componente.programaAcademico}"),
                      Text("🗓️ Periodo: ${componente.periodo}"),
                      Text("🕒 Horario: ${componente.horario}"),
                      Text("💵 Precio: \$${componente.precio}"),
                      Text("🎯 Cupos: ${componente.cuposDisponibles}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildDropdown("Método de Pago", metodoPago, metodoPagoOpciones,
                  (val) => setState(() => metodoPago = val!)),
              buildDropdown("¿Cómo te enteraste del curso?", medioEntero,
                  medioEnteroOpciones, (val) => setState(() => medioEntero = val!)),
              buildDropdown("Número de cuotas", cuotas, opcionesCuotas,
                  (val) => setState(() => cuotas = val!)),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => mostrandoDatosBancarios = !mostrandoDatosBancarios),
                icon: Icon(mostrandoDatosBancarios
                    ? Icons.visibility_off
                    : Icons.visibility),
                label: Text(mostrandoDatosBancarios
                    ? 'Ocultar Datos de Pago'
                    : 'Mostrar Datos de Pago'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2042A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              if (mostrandoDatosBancarios) ...[
                const SizedBox(height: 20),
                if (metodoPago == 'deposito' || metodoPago == 'transferencia')
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Datos del Depósito o Transferencia",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _referenciaController,
                            decoration: const InputDecoration(
                                labelText: 'Número de referencia (6 dígitos)',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _montoController,
                            decoration: const InputDecoration(
                                labelText: 'Monto (\$)',
                                border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _fechaController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                labelText: 'Fecha del depósito',
                                border: OutlineInputBorder()),
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
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _idDepositanteController,
                            decoration: const InputDecoration(
                                labelText: 'ID del depositante',
                                border: OutlineInputBorder()),
                            maxLength: 20,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]'))
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text(
                              "🏦 Cuenta: BANCO DE LOJA CRECE DIARIO\nNro: 2900939374",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (metodoPago == 'tarjeta')
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Datos de la Tarjeta",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nombreTarjetaController,
                            decoration: const InputDecoration(
                                labelText: 'Nombre en la tarjeta',
                                border: OutlineInputBorder()),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z ]'))
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _numeroTarjetaController,
                            decoration: const InputDecoration(
                                labelText: 'Número de tarjeta (16 dígitos)',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _vencimientoController,
                                  decoration: const InputDecoration(
                                      labelText: 'Vencimiento (MM/AA)',
                                      border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d{0,2}/?\d{0,2}'))
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  decoration: const InputDecoration(
                                      labelText: 'CVV',
                                      border: OutlineInputBorder()),
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
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: enviado ? null : finalizarMatricula,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text("Finalizar Matrícula",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
