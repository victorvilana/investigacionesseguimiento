import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class ListadoProyectosController extends ChangeNotifier {
  final InvestigacionService _investigacionService = InvestigacionService();

  // Suscripción para escuchar cambios en tiempo real desde Firebase
  StreamSubscription<QuerySnapshot>? _suscripcion;

  // Listas de datos
  List<Map<String, dynamic>> _todosLosProyectos = [];
  List<Map<String, dynamic>> proyectosFiltrados = [];

  bool isLoading = true;
  String searchQuery = "";

  ListadoProyectosController() {
    _inicializarStream();
  }

  // 👉 1. ESCUCHAR FIREBASE EN TIEMPO REAL
  void _inicializarStream() {
    _suscripcion = _investigacionService.obtenerInvestigacionesStream().listen((snapshot) {
      // Convertimos los documentos a una lista de mapas
      _todosLosProyectos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Le inyectamos el ID directamente al mapa
        return data;
      }).toList();

      isLoading = false;
      aplicarFiltro(); // Aplicamos filtro por si había una búsqueda activa
    });
  }

  // 👉 2. LÓGICA DE BÚSQUEDA Y FILTRADO
  void actualizarBusqueda(String query) {
    searchQuery = query.toLowerCase();
    aplicarFiltro();
  }

  void aplicarFiltro() {
    if (searchQuery.isEmpty) {
      proyectosFiltrados = List.from(_todosLosProyectos);
    } else {
      proyectosFiltrados = _todosLosProyectos.where((proyecto) {
        final id = (proyecto['id'] ?? '').toString().toLowerCase();
        final titulo = (proyecto['titulo'] ?? '').toString().toLowerCase();
        return id.contains(searchQuery) || titulo.contains(searchQuery);
      }).toList();
    }
    notifyListeners(); // Avisamos a la UI que redibuje la lista
  }

  // 👉 3. LÓGICA DE NEGOCIO (CÁLCULOS MATEMÁTICOS)
  double calcularProgreso(Map<String, dynamic> proyecto) {
    final List<dynamic> actividades = proyecto['actividades'] ?? [];
    if (actividades.isEmpty) return 0.0;

    int completadas = 0;
    for (var act in actividades) {
      if (act['estado'] == 'COMPLETADO' || act['pagado'] == true) completadas++;
    }
    return completadas / actividades.length;
  }

  double calcularMontoPorCobrar(Map<String, dynamic> proyecto) {
    double valorTotal = 0.0;
    if (proyecto['valor'] != null) {
      valorTotal = double.tryParse(proyecto['valor'].toString()) ?? 0.0;
    }

    final List<dynamic> actividades = proyecto['actividades'] ?? [];
    double montoPagado = 0.0;

    for (var act in actividades) {
      if (act['estado'] == 'COMPLETADO' || act['pagado'] == true) {
        double valorActividad = 0.0;
        if (act['valor'] != null) {
          valorActividad = double.tryParse(act['valor'].toString()) ?? 0.0;
        }
        montoPagado += valorActividad;
      }
    }
    double pendiente = valorTotal - montoPagado;
    return pendiente < 0 ? 0.0 : pendiente;
  }

  // 👉 4. LÓGICA DE ELIMINACIÓN
  Future<String?> eliminarProyecto(String idProyecto) async {
    try {
      await _investigacionService.eliminarInvestigacion(idProyecto);
      return null; // Nulo significa Éxito
    } catch (e) {
      return e.toString(); // Retorna el error
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel(); // Apagamos el stream para no consumir memoria
    super.dispose();
  }
}