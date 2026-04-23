import 'package:flutter/material.dart';
import '../../infrastructure/services/CatalogoService.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class CargarTrabajoController extends ChangeNotifier {
  final CatalogoService _catalogoService = CatalogoService();
  final InvestigacionService _investigacionService = InvestigacionService();

  // Controladores de texto
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController detalleController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

  // Listas para los combos
  List<String> empresasDisponibles = [];
  List<String> nivelesDisponibles = [];
  List<String> universidadesDisponibles = [];

  // Selecciones
  String? empresaSeleccionada;
  String? nivelSeleccionado;
  String? universidadSeleccionada;
  int iconoSeleccionadoIndex = 0;

  // Estados de carga
  bool cargandoCatalogos = true;
  bool guardando = false;

  final Map<String, dynamic>? proyectoAEditar;
  bool get esModoEdicion => proyectoAEditar != null;

  final List<IconData> iconosDisponibles = [
    Icons.school, Icons.science, Icons.menu_book, Icons.biotech,
    Icons.psychology, Icons.computer, Icons.calculate, Icons.language,
    Icons.architecture, Icons.add,
  ];

  // Constructor: inicializa y carga datos
  CargarTrabajoController({this.proyectoAEditar}) {
    _inicializar();
  }

  Future<void> _inicializar() async {
    // 1. Cargar datos si estamos editando
    if (esModoEdicion) {
      final data = proyectoAEditar!;
      codigoController.text = data['id'] ?? '';
      tituloController.text = data['titulo'] ?? '';
      detalleController.text = data['detalle'] ?? '';
      valorController.text = (data['valor'] ?? 0.0).toString();

      if (data['icono'] != null) {
        int index = iconosDisponibles.indexWhere((icon) => icon.codePoint == data['icono']);
        if (index != -1) iconoSeleccionadoIndex = index;
      }
    }

    // 2. Descargar catálogos
    final resultados = await Future.wait([
      _catalogoService.obtenerEmpresas(),
      _catalogoService.obtenerNivelesEducativos(),
      _catalogoService.obtenerUniversidades(),
    ]);

    empresasDisponibles = resultados[0];
    nivelesDisponibles = resultados[1];
    universidadesDisponibles = resultados[2];

    // 3. Asignar selecciones si editamos
    if (esModoEdicion) {
      final data = proyectoAEditar!;
      if (empresasDisponibles.contains(data['empresacontratante'])) empresaSeleccionada = data['empresacontratante'];
      if (nivelesDisponibles.contains(data['niveleducativo'])) nivelSeleccionado = data['niveleducativo'];
      if (universidadesDisponibles.contains(data['universidad'])) universidadSeleccionada = data['universidad'];
    }

    cargandoCatalogos = false;
    notifyListeners(); // Avisamos a la UI que ya puede dibujar los combos
  }

  // Setters para la UI
  void setEmpresa(String? val) { empresaSeleccionada = val; notifyListeners(); }
  void setNivel(String? val) { nivelSeleccionado = val; notifyListeners(); }
  void setUniversidad(String? val) { universidadSeleccionada = val; notifyListeners(); }
  void setIcono(int index) { iconoSeleccionadoIndex = index; notifyListeners(); }

  // Lógica de Guardado (Incluye la Estandarización Visual)
  Future<bool> guardarProyecto(BuildContext context) async {
    if (codigoController.text.trim().isEmpty || tituloController.text.trim().isEmpty ||
        detalleController.text.trim().isEmpty || valorController.text.trim().isEmpty ||
        empresaSeleccionada == null || universidadSeleccionada == null || nivelSeleccionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, completa todos los campos del formulario.', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    guardando = true;
    notifyListeners();

    // 👉 ESTANDARIZACIÓN: Barra azul de procesando
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Procesando información...', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF1046C4), duration: Duration(milliseconds: 500),
    ));

    try {
      double valorNumerico = double.tryParse(valorController.text.trim().replaceAll(',', '.')) ?? 0.0;
      int codigoIcono = iconosDisponibles[iconoSeleccionadoIndex].codePoint;

      if (esModoEdicion) {
        await _investigacionService.actualizarInvestigacion(
          codigo: codigoController.text.trim(), titulo: tituloController.text.trim(),
          detalle: detalleController.text.trim(), empresa: empresaSeleccionada!,
          universidad: universidadSeleccionada!, nivelEducativo: nivelSeleccionado!,
          icono: codigoIcono, valor: valorNumerico,
        );
      } else {
        await _investigacionService.guardarInvestigacion(
          codigo: codigoController.text.trim(), titulo: tituloController.text.trim(),
          detalle: detalleController.text.trim(), empresa: empresaSeleccionada!,
          universidad: universidadSeleccionada!, nivelEducativo: nivelSeleccionado!,
          icono: codigoIcono, valor: valorNumerico,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(esModoEdicion ? '¡Investigación actualizada con éxito!' : '¡Investigación guardada con éxito!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green, duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating,
        ));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red,
        ));
      }
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    tituloController.dispose();
    detalleController.dispose();
    valorController.dispose();
    super.dispose();
  }
}