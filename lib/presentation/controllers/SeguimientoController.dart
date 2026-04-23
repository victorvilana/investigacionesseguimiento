import 'package:flutter/material.dart';
import '../../infrastructure/services/CatalogoService.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class SeguimientoController extends ChangeNotifier {
  final CatalogoService _catalogoService = CatalogoService();
  final InvestigacionService _investigacionService = InvestigacionService();

  bool cargando = true;
  bool guardando = false;

  List<String> opcionesQuincena = [];
  List<Map<String, dynamic>> actividades = [];

  // Lógica de Estado
  String obtenerEstado(Map<String, dynamic> actividad) {
    if (actividad['pagado'] == true) return "COMPLETADO";
    if (actividad['solicitudPago'] == true) return "EN PROCESO";
    return "PENDIENTE";
  }

  Future<void> inicializar(Map<String, dynamic> proyecto) async {
    // 1. Descargamos el catálogo de quincenas
    opcionesQuincena = await _catalogoService.obtenerQuincenas();

    // 2. Extraemos las actividades del proyecto
    List<dynamic> actividadesPrevias = proyecto['actividades'] ?? [];

    // 3. Mapeamos los datos siguiendo tus reglas de negocio
    actividades = actividadesPrevias.map((act) {
      String quincenaGuardada = act['quincena'] ?? '';

      return {
        'nombre': act['tipo'] ?? 'Actividad sin nombre',
        'solicitudPago': act['solicitudPago'] ?? false,
        'pagado': act['pagado'] ?? false,
        'quincena': opcionesQuincena.contains(quincenaGuardada) ? quincenaGuardada : null,

        // 👉 AÑADE ESTA LÍNEA PARA NO PERDER EL PRECIO EN MEMORIA
        'valor': act['valor'] ?? 0.0,
      };
    }).toList();

    cargando = false;
    notifyListeners(); // Avisamos a la UI que ya puede dibujar
  }

  // Funciones para actualizar el estado desde la UI
  void toggleSolicitudPago(int index, bool valor) {
    actividades[index]['solicitudPago'] = valor;
    notifyListeners();
  }

  void togglePagado(int index, bool valor) {
    actividades[index]['pagado'] = valor;
    notifyListeners();
  }

  void setQuincena(int index, String? valor) {
    actividades[index]['quincena'] = valor;
    notifyListeners();
  }

  // Guardar en Firebase
  Future<bool> guardarCambios(String proyectoId, BuildContext context) async {
    guardando = true;
    notifyListeners();

    // Barra azul de procesando
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Procesando información...', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF1046C4), duration: Duration(milliseconds: 500),
    ));

    try {
      // Formateamos de vuelta para Firebase
      List<Map<String, dynamic>> datosParaFirebase = actividades.map((act) => {
        'tipo': act['nombre'],
        'solicitudPago': act['solicitudPago'],
        'pagado': act['pagado'],
        'quincena': act['quincena'],
        'estado': obtenerEstado(act),

        // 👉 AÑADE ESTA LÍNEA PARA DEVOLVER EL PRECIO A FIREBASE
        'valor': act['valor'],
      }).toList();


      // Aquí reutilizamos el método que actualiza el array de actividades
      await _investigacionService.actualizarActividadesProyecto(proyectoId, datosParaFirebase);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Seguimiento actualizado con éxito!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green, duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating,
        ));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // ==========================================
  // LÓGICA FINANCIERA
  // ==========================================

  double calcularTotalCobrado() {
    double total = 0.0;
    for (var act in actividades) {
      if (act['pagado'] == true || act['estado'] == 'COMPLETADO') {
        total += double.tryParse(act['valor']?.toString() ?? '0') ?? 0.0;
      }
    }
    return total;
  }

  double calcularSaldoPendiente(double totalProyecto) {
    double saldo = totalProyecto - calcularTotalCobrado();
    return saldo < 0 ? 0.0 : saldo; // Evitamos números negativos
  }


}