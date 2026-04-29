import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // 👉 Necesario para formatear las fechas
import '../controllers/CargarTrabajoController.dart';

class CargarTrabajoScreen extends StatefulWidget {
  final VoidCallback onCancelar;
  final Map<String, dynamic>? proyectoAEditar;

  const CargarTrabajoScreen({
    super.key,
    required this.onCancelar,
    this.proyectoAEditar,
  });

  @override
  State<CargarTrabajoScreen> createState() => _CargarTrabajoScreenState();
}

class _CargarTrabajoScreenState extends State<CargarTrabajoScreen> {
  late final CargarTrabajoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CargarTrabajoController(
      proyectoAEditar: widget.proyectoAEditar,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
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
      },
    );
  }

  // ==========================================
  // DISEÑO WEB
  // ==========================================
  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.esModoEdicion ? "Editar Trabajo" : "Cargar Nuevo Trabajo",
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
              const Row(
                children: [
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

              // FILA 1: Código y Nombre del Proyecto
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "CÓDIGO DE INVESTIGACIÓN",
                      "Ej. INV-2024-001",
                      controller: _controller.codigoController,
                      readOnly: _controller.esModoEdicion,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTextField(
                      "NOMBRE DEL PROYECTO",
                      "Ej. Implementación de Sistema Moodle",
                      controller: _controller.nombreProyectoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FILA 2: Cliente, Empresa Contratante y Sucursal
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "CLIENTE",
                      "Nombre del cliente principal",
                      controller: _controller.clienteController,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField(
                      "EMPRESA CONTRATANTE",
                      _controller.cargandoCatalogos
                          ? "Cargando..."
                          : "Seleccione una empresa",
                      _controller.empresasDisponibles,
                      _controller.empresaSeleccionada,
                      _controller.setEmpresa,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField(
                      "SUCURSAL",
                      _controller.sucursalesDisponibles.isEmpty
                          ? "Seleccione empresa primero"
                          : "Seleccione sucursal",
                      _controller.sucursalesDisponibles,
                      _controller.sucursalSeleccionada,
                      _controller.setSucursal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FILA 3: Fechas
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      "FECHA DE INICIO",
                      "Seleccione fecha",
                      _controller.fechaInicio,
                      () => _seleccionarFecha(context, true),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDateField(
                      "FECHA DE FIN",
                      "Seleccione fecha",
                      _controller.fechaFin,
                      () => _seleccionarFecha(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FILA 4: Título de investigación
              _buildTextField(
                "TÍTULO DE LA INVESTIGACIÓN",
                "Ej. Impacto de la IA en la educación superior",
                controller: _controller.tituloController,
              ),
              const SizedBox(height: 24),

              // FILA 5: Descripción
              _buildTextField(
                "DESCRIPCIÓN DETALLADA",
                "Describa los objetivos, metodología y alcance esperado de su investigación...",
                maxLines: 5,
                controller: _controller.detalleController,
              ),
              const SizedBox(height: 24),

              // FILA 6: Universidad y Nivel
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      "UNIVERSIDAD",
                      _controller.cargandoCatalogos
                          ? "Cargando..."
                          : "Seleccione Universidad",
                      _controller.universidadesDisponibles,
                      _controller.universidadSeleccionada,
                      _controller.setUniversidad,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField(
                      "NIVEL EDUCATIVO",
                      _controller.cargandoCatalogos
                          ? "Cargando..."
                          : "Seleccione el nivel",
                      _controller.nivelesDisponibles,
                      _controller.nivelSeleccionado,
                      _controller.setNivel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FILA 7: Icono y Valor Total
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
                      controller: _controller.valorController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildBotonesAccion(),
      ],
    );
  }

  // ==========================================
  // DISEÑO MÓVIL
  // ==========================================
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.esModoEdicion ? "Editar Trabajo" : "Cargar Trabajo",
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
          controller: _controller.codigoController,
          readOnly: _controller.esModoEdicion,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "NOMBRE DEL PROYECTO",
          "Ingrese el nombre del proyecto",
          controller: _controller.nombreProyectoController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "CLIENTE",
          "Nombre del cliente",
          controller: _controller.clienteController,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          "EMPRESA CONTRATANTE",
          _controller.cargandoCatalogos
              ? "Cargando..."
              : "Seleccione una empresa",
          _controller.empresasDisponibles,
          _controller.empresaSeleccionada,
          _controller.setEmpresa,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          "SUCURSAL",
          _controller.sucursalesDisponibles.isEmpty
              ? "Seleccione empresa primero"
              : "Seleccione sucursal",
          _controller.sucursalesDisponibles,
          _controller.sucursalSeleccionada,
          _controller.setSucursal,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildDateField(
                "FECHA DE INICIO",
                "Seleccione",
                _controller.fechaInicio,
                () => _seleccionarFecha(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                "FECHA DE FIN",
                "Seleccione",
                _controller.fechaFin,
                () => _seleccionarFecha(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildTextField(
          "TÍTULO DE LA INVESTIGACIÓN",
          "Ingrese el título completo",
          controller: _controller.tituloController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "DESCRIPCIÓN DETALLADA",
          "Resumen ejecutivo y objetivos principales...",
          maxLines: 4,
          controller: _controller.detalleController,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          "UNIVERSIDAD",
          _controller.cargandoCatalogos
              ? "Cargando..."
              : "Seleccione Universidad",
          _controller.universidadesDisponibles,
          _controller.universidadSeleccionada,
          _controller.setUniversidad,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          "NIVEL EDUCATIVO",
          _controller.cargandoCatalogos ? "Cargando..." : "Seleccione el nivel",
          _controller.nivelesDisponibles,
          _controller.nivelSeleccionado,
          _controller.setNivel,
        ),
        const SizedBox(height: 20),
        _buildIconSelector(),
        const SizedBox(height: 20),
        _buildTextField(
          "VALOR TOTAL",
          "0.00",
          prefixText: "\$ ",
          isNumber: true,
          controller: _controller.valorController,
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: _buildBotonGuardar(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: _buildBotonCancelar(),
        ),
      ],
    );
  }

  // ==========================================
  // BOTONES
  // ==========================================
  Widget _buildBotonesAccion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 300, height: 54, child: _buildBotonGuardar()),
        const SizedBox(width: 24),
        SizedBox(height: 54, child: _buildBotonCancelar()),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return ElevatedButton.icon(
      onPressed: _controller.guardando
          ? null
          : () async {
              final exito = await _controller.guardarProyecto(context);
              if (exito && mounted) {
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) widget.onCancelar();
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1046C4),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: _controller.guardando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.save),
      label: Text(
        _controller.guardando
            ? "Guardando..."
            : (_controller.esModoEdicion
                  ? "Actualizar Investigación"
                  : "Guardar Investigación"),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildBotonCancelar() {
    return TextButton.icon(
      // 👉 Si está guardando, pasamos null para deshabilitarlo
      onPressed: _controller.guardando ? null : widget.onCancelar,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        backgroundColor: const Color(0xFFEEF2FF),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Opcional: Agregar un color diferente cuando está deshabilitado para que se note
        disabledBackgroundColor: Colors.grey.shade200,
      ),
      icon: const Icon(Icons.close),
      label: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // ==========================================
  // LÓGICA DE FECHAS (DISEÑO ELEGANTE Y COMPACTO)
  // ==========================================
  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1046C4),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
              surfaceContainerHigh: Colors.white,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 10,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1046C4),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          // 👉 LA SOLUCIÓN: Engañamos a Flutter para que use el diseño vertical (Portrait)
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(
                MediaQuery.of(context).size.shortestSide,
                MediaQuery.of(context).size.longestSide,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (fechaSeleccionada != null) {
      if (esInicio) {
        _controller.setFechaInicio(fechaSeleccionada);
      } else {
        _controller.setFechaFin(fechaSeleccionada);
      }
    }
  }


  // ==========================================
  // COMPONENTES REUTILIZABLES
  // ==========================================

  Widget _buildTextField(String label, String hint, {int maxLines = 1, String? prefixText, bool isNumber = false, TextEditingController? controller, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A), letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          // 👉 EL CAMBIO ESTÁ AQUÍ: Activamos el teclado multilínea si maxLines es mayor a 1
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold, fontSize: 16),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade200 : const Color(0xFFF4F6FC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          items: items
              .map(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 👉 NUEVO: Selector de fechas estilizado
  Widget _buildDateField(
    String label,
    String hint,
    DateTime? fecha,
    VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : hint,
                  style: TextStyle(
                    color: fecha != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
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
              children: List.generate(_controller.iconosDisponibles.length, (
                index,
              ) {
                final isSelected = _controller.iconoSeleccionadoIndex == index;
                return GestureDetector(
                  onTap: () => _controller.setIcono(index),
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
                      _controller.iconosDisponibles[index],
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
