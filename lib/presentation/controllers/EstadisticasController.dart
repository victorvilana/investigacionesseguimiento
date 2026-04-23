import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class EstadisticasController extends ChangeNotifier {
  final InvestigacionService _investigacionService = InvestigacionService();
  StreamSubscription<QuerySnapshot>? _suscripcion;

  bool isLoading = true;

  // 1. Datos para el Gráfico de Barras
  Map<String, double> ingresosPorQuincena = {};
  double maxIngreso = 0;

  // 👉 AQUÍ ESTÁN LAS VARIABLES QUE TE ESTABA PIDIENDO LA PANTALLA
  // 2. Datos para el Gráfico de Anillo
  double totalCobrado = 0.0;
  double totalPendiente = 0.0;

  // 3. Datos para el Ranking de Empresas
  List<MapEntry<String, double>> rankingEmpresas = [];

  EstadisticasController() {
    _inicializarStream();
  }

  void _inicializarStream() {
    _suscripcion = _investigacionService.obtenerInvestigacionesStream().listen((snapshot) {
      _procesarDatos(snapshot.docs);
    });
  }

  void _procesarDatos(List<QueryDocumentSnapshot> docs) {
    Map<String, double> mapaQuincenas = {};
    Map<String, double> mapaEmpresas = {};
    double calcMaxIngreso = 0;
    double calcCobrado = 0;
    double calcPresupuestoTotal = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Extraer datos generales del proyecto
      double valorProyecto = double.tryParse(data['valor']?.toString() ?? '0') ?? 0.0;
      String empresa = data['empresacontratante'] ?? 'Sin Empresa';

      calcPresupuestoTotal += valorProyecto;

      // Sumar al ranking de empresas
      mapaEmpresas[empresa] = (mapaEmpresas[empresa] ?? 0.0) + valorProyecto;

      final List<dynamic> actividades = data['actividades'] ?? [];

      for (var act in actividades) {
        if (act['estado'] == 'COMPLETADO' || act['pagado'] == true) {
          double valorActividad = double.tryParse(act['valor']?.toString() ?? '0') ?? 0.0;
          calcCobrado += valorActividad;

          // Agrupar por quincena
          if (act['quincena'] != null && act['quincena'].toString().isNotEmpty) {
            String quincena = act['quincena'].toString();
            mapaQuincenas[quincena] = (mapaQuincenas[quincena] ?? 0.0) + valorActividad;
          }
        }
      }
    }

    // Calcular el máximo para las barras
    for (var valor in mapaQuincenas.values) {
      if (valor > calcMaxIngreso) calcMaxIngreso = valor;
    }

    // Ordenar el ranking de empresas de mayor a menor
    var listaOrdenada = mapaEmpresas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Guardar en el estado
    ingresosPorQuincena = mapaQuincenas;
    maxIngreso = calcMaxIngreso;
    totalCobrado = calcCobrado;
    totalPendiente = (calcPresupuestoTotal - calcCobrado) > 0 ? (calcPresupuestoTotal - calcCobrado) : 0.0;
    rankingEmpresas = listaOrdenada.take(5).toList(); // Tomamos solo el Top 5

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}