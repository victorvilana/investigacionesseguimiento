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
  final TextEditingController nombreProyectoController = TextEditingController();
  final TextEditingController clienteController = TextEditingController();

  // 👉 ELIMINAMOS sucursalController, ahora será de selección dinámica

  // 👉 NUEVO: Mapa para guardar las empresas con sus respectivas sucursales
  Map<String, List<String>> mapaEmpresas = {};

  // Listas para los combos
  List<String> empresasDisponibles = [];
  List<String> sucursalesDisponibles = []; // 👉 Lista dinámica
  List<String> nivelesDisponibles = [];
  List<String> universidadesDisponibles = [];

  // Selecciones
  String? empresaSeleccionada;
  String? sucursalSeleccionada; // 👉 Nueva selección
  String? nivelSeleccionado;
  String? universidadSeleccionada;
  int iconoSeleccionadoIndex = 0;

  DateTime? fechaInicio;
  DateTime? fechaFin;

  bool cargandoCatalogos = true;
  bool guardando = false;

  final Map<String, dynamic>? proyectoAEditar;
  bool get esModoEdicion => proyectoAEditar != null;

  final List<IconData> iconosDisponibles = [
    Icons.school, Icons.science, Icons.menu_book, Icons.biotech,
    Icons.psychology, Icons.computer, Icons.calculate, Icons.language,
    Icons.architecture, Icons.add,
  ];

  CargarTrabajoController({this.proyectoAEditar}) {
    _inicializar();
  }

  Future<void> _inicializar() async {
    // 1. Descargar catálogos (Fíjate que llamamos al nuevo método)
    try {
      final resultados = await Future.wait([
        _catalogoService.obtenerEmpresasYSucursales(), // 👉 Nuevo método
        _catalogoService.obtenerNivelesEducativos(),
        _catalogoService.obtenerUniversidades(),
      ]);

      mapaEmpresas = resultados[0] as Map<String, List<String>>;
      empresasDisponibles = mapaEmpresas.keys.toList();
      nivelesDisponibles = resultados[1] as List<String>;
      universidadesDisponibles = resultados[2] as List<String>;
    } catch (e) {
      debugPrint("Error al cargar catálogos: $e");
    }

    // 2. Cargar datos si estamos editando
    if (esModoEdicion) {
      final data = proyectoAEditar!;
      codigoController.text = data['id'] ?? '';
      tituloController.text = data['titulo'] ?? '';
      detalleController.text = data['detalle'] ?? '';
      valorController.text = (data['valor'] ?? 0.0).toString();
      nombreProyectoController.text = data['nombreProyecto'] ?? '';
      clienteController.text = data['cliente'] ?? '';

      if (data['fechaInicio'] != null) fechaInicio = (data['fechaInicio'] as dynamic).toDate();
      if (data['fechaFin'] != null) fechaFin = (data['fechaFin'] as dynamic).toDate();

      if (data['icono'] != null) {
        int index = iconosDisponibles.indexWhere((icon) => icon.codePoint == data['icono']);
        if (index != -1) iconoSeleccionadoIndex = index;
      }

      // 👉 Asignar selecciones de catálogos y sucursal
      if (empresasDisponibles.contains(data['empresacontratante'])) {
        empresaSeleccionada = data['empresacontratante'];
        // Al saber la empresa, cargamos sus sucursales
        sucursalesDisponibles = mapaEmpresas[empresaSeleccionada] ?? [];

        if (sucursalesDisponibles.contains(data['sucursal'])) {
          sucursalSeleccionada = data['sucursal'];
        }
      }
      if (nivelesDisponibles.contains(data['niveleducativo'])) nivelSeleccionado = data['niveleducativo'];
      if (universidadesDisponibles.contains(data['universidad'])) universidadSeleccionada = data['universidad'];
    }

    cargandoCatalogos = false;
    notifyListeners();
  }

  // Setters para la UI
  void setEmpresa(String? val) {
    empresaSeleccionada = val;
    // 👉 MAGIA AQUÍ: Al cambiar la empresa, cambiamos la lista de sucursales y borramos la anterior
    sucursalSeleccionada = null;
    if (val != null && mapaEmpresas.containsKey(val)) {
      sucursalesDisponibles = mapaEmpresas[val]!;
    } else {
      sucursalesDisponibles = [];
    }
    notifyListeners();
  }

  void setSucursal(String? val) { sucursalSeleccionada = val; notifyListeners(); } // 👉 Nuevo setter
  void setNivel(String? val) { nivelSeleccionado = val; notifyListeners(); }
  void setUniversidad(String? val) { universidadSeleccionada = val; notifyListeners(); }
  void setIcono(int index) { iconoSeleccionadoIndex = index; notifyListeners(); }
  void setFechaInicio(DateTime fecha) { fechaInicio = fecha; notifyListeners(); }
  void setFechaFin(DateTime fecha) { fechaFin = fecha; notifyListeners(); }

  Future<bool> guardarProyecto(BuildContext context) async {
    // Validamos que la sucursal haya sido seleccionada del dropdown
    if (codigoController.text.trim().isEmpty || tituloController.text.trim().isEmpty ||
        detalleController.text.trim().isEmpty || valorController.text.trim().isEmpty ||
        nombreProyectoController.text.trim().isEmpty || clienteController.text.trim().isEmpty ||
        sucursalSeleccionada == null || empresaSeleccionada == null || // 👉 sucursalSeleccionada
        universidadSeleccionada == null || nivelSeleccionado == null ||
        fechaInicio == null || fechaFin == null) {

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, completa todos los campos.', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    guardando = true;
    notifyListeners();

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
          nombreProyecto: nombreProyectoController.text.trim(), cliente: clienteController.text.trim(),
          sucursal: sucursalSeleccionada!, // 👉 Guardamos la selección
          fechaInicio: fechaInicio!, fechaFin: fechaFin!,
        );
      } else {
        await _investigacionService.guardarInvestigacion(
          codigo: codigoController.text.trim(), titulo: tituloController.text.trim(),
          detalle: detalleController.text.trim(), empresa: empresaSeleccionada!,
          universidad: universidadSeleccionada!, nivelEducativo: nivelSeleccionado!,
          icono: codigoIcono, valor: valorNumerico,
          nombreProyecto: nombreProyectoController.text.trim(), cliente: clienteController.text.trim(),
          sucursal: sucursalSeleccionada!, // 👉 Guardamos la selección
          fechaInicio: fechaInicio!, fechaFin: fechaFin!,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(esModoEdicion ? '¡Actualizado con éxito!' : '¡Guardado con éxito!',
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
    nombreProyectoController.dispose();
    clienteController.dispose();
    super.dispose();
  }
}