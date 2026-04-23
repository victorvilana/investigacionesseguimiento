import 'package:flutter/material.dart';
import '../../infrastructure/services/InvestigacionService.dart';

// 👉 MUDANZA: La clase ActividadItem ahora vive aquí porque el controlador maneja el estado
class ActividadItem {
  String? tipo;
  final TextEditingController valorController;

  ActividadItem({this.tipo, required this.valorController});
}

class ActividadesController extends ChangeNotifier {
  final InvestigacionService _service = InvestigacionService();

  // Variables que la pantalla necesita leer
  final double valorObjetivo;
  List<ActividadItem> itemsActividad = [];
  double totalPresupuestado = 0.0;
  bool guardando = false;

  // Constructor que recibe el presupuesto total del proyecto
  ActividadesController({
    required this.valorObjetivo,
    List<dynamic>? actividadesPrevia,
  }) {
    // Si ya existen actividades en la base de datos, las cargamos
    if (actividadesPrevia != null && actividadesPrevia.isNotEmpty) {
      for (var act in actividadesPrevia) {
        final controller = TextEditingController(text: act['valor'].toString());
        controller.addListener(_calcularTotal);

        itemsActividad.add(
          ActividadItem(tipo: act['tipo'], valorController: controller),
        );
      }
      _calcularTotal(); // Calculamos el total inicial
    } else {
      // Si no hay nada, empezamos con una fila vacía para mejorar la UX
      agregarNuevaFila();
    }
  }

  // ==========================================
  // LÓGICA DE FILAS
  // ==========================================

  void cambiarTipoActividad(int index, String? nuevoTipo, BuildContext context) {
    if (nuevoTipo == null) return;

    // Verificamos si este tipo ya fue elegido en alguna OTRA fila
    bool yaExiste = itemsActividad.asMap().entries.any(
            (entry) => entry.key != index && entry.value.tipo == nuevoTipo
    );

    if (yaExiste) {
      // Si existe, mostramos el error y NO guardamos el valor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ La actividad "$nuevoTipo" ya está seleccionada en otra fila.'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Forzamos a repintar para que el Dropdown regrese a su estado anterior
      notifyListeners();
    } else {
      // Si no existe, lo asignamos normalmente
      itemsActividad[index].tipo = nuevoTipo;
      notifyListeners();
    }
  }


  String? agregarNuevaFila() {
    // 1. Validamos la fila anterior (si existe)
    if (itemsActividad.isNotEmpty) {
      final ultimaActividad = itemsActividad.last;

      // Extraemos el valor numérico
      String valorTexto = ultimaActividad.valorController.text
          .trim()
          .replaceAll(',', '.');
      double valorNumerico = double.tryParse(valorTexto) ?? 0.0;

      // Regla A: ¿Seleccionó una actividad?
      if (ultimaActividad.tipo == null || ultimaActividad.tipo!.isEmpty) {
        return "Por favor, selecciona una actividad en la fila actual antes de agregar otra.";
      }

      // Regla B: ¿El valor es mayor a 0?
      if (valorNumerico <= 0) {
        return "El valor de la actividad debe ser mayor a \$ 0.00.";
      }
    }

    // 2. Si pasa las validaciones (o si es la primera fila), la agregamos
    final controller = TextEditingController();
    controller.addListener(_calcularTotal);
    itemsActividad.add(ActividadItem(valorController: controller));

    notifyListeners();
    return null; // Todo en orden
  }

  void eliminarFila(int index) {
    itemsActividad[index].valorController.dispose();
    itemsActividad.removeAt(index);
    _calcularTotal(); // Recalculamos el total sin esta fila

    notifyListeners();
  }

  void _calcularTotal() {
    double temporal = 0.0;
    for (var item in itemsActividad) {
      String valorTexto = item.valorController.text.trim().replaceAll(',', '.');
      temporal += double.tryParse(valorTexto) ?? 0.0;
    }
    totalPresupuestado = temporal;

    notifyListeners(); // Avisamos a la UI que actualice el número azul gigante
  }

  // Limpiamos memoria cuando se cierra la pantalla
  @override
  void dispose() {
    for (var item in itemsActividad) {
      item.valorController.dispose();
    }
    super.dispose();
  }

  // ==========================================
  // LÓGICA DE FIREBASE Y VALIDACIÓN
  // ==========================================


  Future<bool> guardarEnFirebase(String proyectoId, BuildContext context) async {
    // 👉 REGLA DE ORO: Validación estricta de igualdad
    double diferencia = valorObjetivo - totalPresupuestado;

    // Usamos un margen de error mínimo por decimales (0.01) si fuera necesario,
    // pero para este caso buscamos igualdad exacta (0.0).
    if (diferencia.abs() > 0.001) {
      String mensaje = diferencia > 0
          ? 'Faltan \$ ${diferencia.toStringAsFixed(2)} para alcanzar el total.'
          : 'Te has pasado por \$ ${(diferencia * -1).toStringAsFixed(2)} del total.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ No se puede guardar: El total de actividades debe ser igual al valor del proyecto. $mensaje'),
          backgroundColor: Colors.orange.shade900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return false; // Bloqueamos el flujo aquí
    }

    // 2. Si el valor es exacto, procedemos con el estándar de guardado
    guardando = true;
    notifyListeners();

    // Estandarización: Barra azul "Procesando"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Procesando información...', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1046C4),
        duration: Duration(milliseconds: 500),
      ),
    );

    try {
      List<Map<String, dynamic>> data = itemsActividad.map((it) => {
        'tipo': it.tipo ?? 'Sin clasificar',
        'valor': double.tryParse(it.valorController.text.replaceAll(',', '.')) ?? 0.0,
      }).toList();

      await _service.actualizarActividadesProyecto(proyectoId, data);

      if (context.mounted) {
        // Estandarización: Barra verde "Éxito"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Actividades guardadas con éxito!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

}
