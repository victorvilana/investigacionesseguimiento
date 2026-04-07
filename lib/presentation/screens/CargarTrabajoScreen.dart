import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../infrastructure/services/CatalogoService.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class CargarTrabajoScreen extends StatefulWidget {
  final VoidCallback onCancelar;
  final Map<String, dynamic>?
  proyectoAEditar; // 👉 Puede ser nulo (Nuevo) o tener datos (Editar)

  const CargarTrabajoScreen({
    super.key,
    required this.onCancelar,
    this.proyectoAEditar,
  });

  @override
  State<CargarTrabajoScreen> createState() => _CargarTrabajoScreenState();
}

class _CargarTrabajoScreenState extends State<CargarTrabajoScreen> {
  final CatalogoService _catalogoService = CatalogoService();
  final InvestigacionService _investigacionService = InvestigacionService();

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  List<String> _empresasDisponibles = [];
  bool _cargandoEmpresas = true;

  List<String> _nivelesDisponibles = [];
  bool _cargandoNiveles = true;

  List<String> _universidadesDisponibles = [];
  bool _cargandoUniversidades = true;

  String? _empresaSeleccionada;
  String? _nivelSeleccionado;
  String? _universidadSeleccionada;
  int _iconoSeleccionadoIndex = 0;

  bool _guardando = false;

  final List<IconData> _iconosDisponibles = [
    Icons.school,
    Icons.science,
    Icons.menu_book,
    Icons.biotech,
    Icons.psychology,
    Icons.computer,
    Icons.calculate,
    Icons.language,
    Icons.architecture,
    Icons.add,
  ];

  // 👉 Detectamos si estamos en MODO EDICIÓN
  bool get _esModoEdicion => widget.proyectoAEditar != null;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
    _precargarDatosSiEsEdicion(); // 👉 Precargamos los textos
  }

  // Llenamos los TextFields inmediatamente
  void _precargarDatosSiEsEdicion() {
    if (_esModoEdicion) {
      final data = widget.proyectoAEditar!;
      _codigoController.text = data['id'] ?? '';
      _tituloController.text = data['titulo'] ?? '';
      _detalleController.text = data['detalle'] ?? '';
      _valorController.text = (data['valor'] ?? 0.0).toString();

      // Buscamos cuál es el ícono seleccionado
      if (data['icono'] != null) {
        int index = _iconosDisponibles.indexWhere(
          (icon) => icon.codePoint == data['icono'],
        );
        if (index != -1) _iconoSeleccionadoIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _tituloController.dispose();
    _detalleController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    final resultados = await Future.wait([
      _catalogoService.obtenerEmpresas(),
      _catalogoService.obtenerNivelesEducativos(),
      _catalogoService.obtenerUniversidades(),
    ]);

    if (mounted) {
      setState(() {
        _empresasDisponibles = resultados[0];
        _nivelesDisponibles = resultados[1];
        _universidadesDisponibles = resultados[2];

        // 👉 Una vez cargados los catálogos, asignamos los valores de los Dropdowns
        if (_esModoEdicion) {
          final data = widget.proyectoAEditar!;

          if (_empresasDisponibles.contains(data['empresacontratante'])) {
            _empresaSeleccionada = data['empresacontratante'];
          }
          if (_nivelesDisponibles.contains(data['niveleducativo'])) {
            _nivelSeleccionado = data['niveleducativo'];
          }
          if (_universidadesDisponibles.contains(data['universidad'])) {
            _universidadSeleccionada = data['universidad'];
          }
        }

        _cargandoEmpresas = false;
        _cargandoNiveles = false;
        _cargandoUniversidades = false;
      });
    }
  }

  Future<void> _guardarInvestigacion() async {
    if (_codigoController.text.trim().isEmpty ||
        _tituloController.text.trim().isEmpty ||
        _detalleController.text.trim().isEmpty ||
        _valorController.text.trim().isEmpty ||
        _empresaSeleccionada == null ||
        _universidadSeleccionada == null ||
        _nivelSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos del formulario.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      String valorCorregido = _valorController.text.trim().replaceAll(',', '.');
      double valorNumerico = double.tryParse(valorCorregido) ?? 0.0;
      int codigoIcono = _iconosDisponibles[_iconoSeleccionadoIndex].codePoint;

      // 👉 DECIDIMOS QUÉ MÉTODO LLAMAR
      if (_esModoEdicion) {
        await _investigacionService.actualizarInvestigacion(
          codigo: _codigoController.text
              .trim(), // El código no cambia, lo usamos para buscar
          titulo: _tituloController.text.trim(),
          detalle: _detalleController.text.trim(),
          empresa: _empresaSeleccionada!,
          universidad: _universidadSeleccionada!,
          nivelEducativo: _nivelSeleccionado!,
          icono: codigoIcono,
          valor: valorNumerico,
        );
      } else {
        await _investigacionService.guardarInvestigacion(
          codigo: _codigoController.text.trim(),
          titulo: _tituloController.text.trim(),
          detalle: _detalleController.text.trim(),
          empresa: _empresaSeleccionada!,
          universidad: _universidadSeleccionada!,
          nivelEducativo: _nivelSeleccionado!,
          icono: codigoIcono,
          valor: valorNumerico,
        );
      }

      if (mounted) {
        final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esModoEdicion
                  ? '¡Investigación actualizada con éxito!'
                  : '¡Investigación guardada con éxito!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _limpiarFormulario();
        await snackBarController.closed;
        if (mounted) widget.onCancelar();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _limpiarFormulario() {
    _codigoController.clear();
    _tituloController.clear();
    _detalleController.clear();
    _valorController.clear();
    setState(() {
      _empresaSeleccionada = null;
      _nivelSeleccionado = null;
      _universidadSeleccionada = null;
      _iconoSeleccionadoIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FD),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isWeb ? 40.0 : 24.0,
                right: isWeb ? 40.0 : 24.0,
                bottom: 100.0,
              ),
              child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // DISEÑOS WEB Y MÓVIL
  // ==========================================
  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👉 Cambiamos el título según el modo
        Text(
          _esModoEdicion ? "Editar Trabajo" : "Cargar Nuevo Trabajo",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Complete los detalles de su nueva investigación académica para iniciar el seguimiento institucional.",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.subject, color: Color(0xFF1046C4)),
                  SizedBox(width: 8),
                  Text(
                    "Información General",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  // 👉 El campo de Código ahora bloquea la escritura si estamos editando
                  Expanded(
                    child: _buildTextField(
                      "CÓDIGO DE INVESTIGACIÓN",
                      "Ej. INV-2024-001",
                      controller: _codigoController,
                      readOnly: _esModoEdicion,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField(
                      "EMPRESA CONTRATANTE",
                      _cargandoEmpresas
                          ? "Cargando..."
                          : "Seleccione una empresa",
                      _empresasDisponibles,
                      _empresaSeleccionada,
                      (val) => setState(() => _empresaSeleccionada = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildTextField(
                "TÍTULO DE LA INVESTIGACIÓN",
                "Ej. Impacto de la IA en la educación superior",
                controller: _tituloController,
              ),
              const SizedBox(height: 24),

              _buildTextField(
                "DESCRIPCIÓN DETALLADA",
                "Describa los objetivos, metodología y alcance esperado de su investigación...",
                maxLines: 5,
                controller: _detalleController,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      "UNIVERSIDAD",
                      _cargandoUniversidades
                          ? "Cargando..."
                          : "Seleccione Universidad",
                      _universidadesDisponibles,
                      _universidadSeleccionada,
                      (val) => setState(() => _universidadSeleccionada = val),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField(
                      "NIVEL EDUCATIVO",
                      _cargandoNiveles ? "Cargando..." : "Seleccione el nivel",
                      _nivelesDisponibles,
                      _nivelSeleccionado,
                      (val) => setState(() => _nivelSeleccionado = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(flex: 2, child: _buildIconSelector()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      "VALOR TOTAL",
                      "0.00",
                      prefixText: "\$ ",
                      isNumber: true,
                      controller: _valorController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarInvestigacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1046C4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                // 👉 Cambiamos el texto del botón
                label: Text(
                  _guardando
                      ? "Guardando..."
                      : (_esModoEdicion
                            ? "Actualizar Investigación"
                            : "Guardar Investigación"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              height: 54,
              child: TextButton.icon(
                onPressed: () {
                  _limpiarFormulario();
                  widget.onCancelar();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  backgroundColor: const Color(0xFFEEF2FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.close),
                label: const Text(
                  "Cancelar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _esModoEdicion ? "Editar Trabajo" : "Cargar Trabajo",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Complete los detalles para registrar una nueva investigación académica en el sistema.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        _buildTextField(
          "CÓDIGO DE INVESTIGACIÓN",
          "EJ: INV-2024-001",
          controller: _codigoController,
          readOnly: _esModoEdicion,
        ),
        const SizedBox(height: 20),

        _buildDropdownField(
          "EMPRESA CONTRATANTE",
          _cargandoEmpresas ? "Cargando..." : "Seleccione una empresa",
          _empresasDisponibles,
          _empresaSeleccionada,
          (val) => setState(() => _empresaSeleccionada = val),
        ),
        const SizedBox(height: 20),

        _buildTextField(
          "TÍTULO DE LA INVESTIGACIÓN",
          "Ingrese el nombre completo del proyecto",
          controller: _tituloController,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          "DESCRIPCIÓN DETALLADA",
          "Resumen ejecutivo y objetivos principales...",
          maxLines: 4,
          controller: _detalleController,
        ),
        const SizedBox(height: 20),

        _buildDropdownField(
          "UNIVERSIDAD",
          _cargandoUniversidades ? "Cargando..." : "Seleccione Universidad",
          _universidadesDisponibles,
          _universidadSeleccionada,
          (val) => setState(() => _universidadSeleccionada = val),
        ),
        const SizedBox(height: 20),

        _buildDropdownField(
          "NIVEL EDUCATIVO",
          _cargandoNiveles ? "Cargando..." : "Seleccione el nivel",
          _nivelesDisponibles,
          _nivelSeleccionado,
          (val) => setState(() => _nivelSeleccionado = val),
        ),
        const SizedBox(height: 20),

        _buildIconSelector(),
        const SizedBox(height: 20),

        _buildTextField(
          "VALOR TOTAL",
          "0.00",
          prefixText: "\$ ",
          isNumber: true,
          controller: _valorController,
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _guardando ? null : _guardarInvestigacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1046C4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _guardando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _esModoEdicion
                        ? "Actualizar Investigación"
                        : "Guardar Investigación",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              _limpiarFormulario();
              widget.onCancelar();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1046C4),
              side: const BorderSide(color: Color(0xFFD6DDF0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // COMPONENTES REUTILIZABLES DEL FORMULARIO
  // ==========================================

  // 👉 Agregamos `readOnly` al TextField
  Widget _buildTextField(
    String label,
    String hint, {
    int maxLines = 1,
    String? prefixText,
    bool isNumber = false,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly, // 👉 Si es true, el teclado no se abre
          maxLines: maxLines,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: Color(0xFF1046C4),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            filled: true,
            // Si es de solo lectura, lo ponemos un poco más oscuro para que se note
            fillColor: readOnly
                ? Colors.grey.shade200
                : const Color(0xFFF4F6FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF4F6FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ICONO DE LA INVESTIGACIÓN",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_iconosDisponibles.length, (index) {
                final isSelected = _iconoSeleccionadoIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _iconoSeleccionadoIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1046C4)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconosDisponibles[index],
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
