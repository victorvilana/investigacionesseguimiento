import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class DashboardController extends ChangeNotifier {
  final InvestigacionService _investigacionService = InvestigacionService();
  StreamSubscription<QuerySnapshot>? _suscripcion;

  bool isLoading = true;

  // KPIs
  int totalProyectos = 0;
  double montoTotalPresupuestado = 0.0;
  double montoTotalCobrado = 0.0;
  double montoTotalPendiente = 0.0;

  DashboardController() {
    _inicializarStream();
  }

  void _inicializarStream() {
    _suscripcion = _investigacionService.obtenerInvestigacionesStream().listen((snapshot) {
      _calcularKPIs(snapshot.docs);
    });
  }

  void _calcularKPIs(List<QueryDocumentSnapshot> docs) {
    totalProyectos = docs.length;
    montoTotalPresupuestado = 0.0;
    montoTotalCobrado = 0.0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Sumar valor total del proyecto
      double valorProyecto = 0.0;
      if (data['valor'] != null) {
        valorProyecto = double.tryParse(data['valor'].toString()) ?? 0.0;
      }
      montoTotalPresupuestado += valorProyecto;

      // Sumar actividades pagadas de este proyecto
      final List<dynamic> actividades = data['actividades'] ?? [];
      for (var act in actividades) {
        if (act['estado'] == 'COMPLETADO' || act['pagado'] == true) {
          double valorActividad = 0.0;
          if (act['valor'] != null) {
            valorActividad = double.tryParse(act['valor'].toString()) ?? 0.0;
          }
          montoTotalCobrado += valorActividad;
        }
      }
    }

    // Calcular lo que falta por cobrar a nivel general
    montoTotalPendiente = montoTotalPresupuestado - montoTotalCobrado;
    if (montoTotalPendiente < 0) montoTotalPendiente = 0.0;

    isLoading = false;
    notifyListeners(); // Avisamos a la pantalla que redibuje los gráficos
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}