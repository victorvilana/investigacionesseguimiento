import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../infrastructure/services/CatalogoService.dart';
import '../controllers/ActividadesController.dart';

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> proyecto;
  final VoidCallback onCancelar;

  const ActividadesScreen({
    super.key,
    required this.proyecto,
    required this.onCancelar,
  });

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  // 👉 INSTANCIA DEL CONTROLADOR (El cerebro de la pantalla)
  late final ActividadesController _controller;
  final CatalogoService _catalogoService = CatalogoService();

  List<String> _tiposActividad = [];
  bool _cargandoCatalogos = true;

  @override
  void initState() {
    super.initState();

    // 👉 PASO CLAVE: Extraemos el array de la base de datos y se lo pasamos al cerebro (Controller)
    _controller = ActividadesController(
      valorObjetivo: (widget.proyecto['valor'] as num).toDouble(),
      actividadesPrevia: widget
          .proyecto['actividades'], // <-- Aquí pasamos el array de Firebase
    );

    _cargarCatalogos();
  }

  // Eliminamos el _controller.agregarNuevaFila() de aquí,
  // porque el constructor del controlador ya decide si agregar una o cargar las existentes.
  Future<void> _cargarCatalogos() async {
    final actividades = await _catalogoService.obtenerActividades();
    if (mounted) {
      setState(() {
        _tiposActividad = actividades;
        _cargandoCatalogos = false;
      });
    }
  }

  Future<void> _cargarDatosIniciales() async {
    final actividades = await _catalogoService.obtenerActividades();
    if (mounted) {
      setState(() {
        _tiposActividad = actividades;
        _cargandoCatalogos = false;
      });
      _controller.agregarNuevaFila(); // Agregamos la primera fila vacía
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpiamos controladores de texto
    super.dispose();
  }

  // ==========================================
  // CONSTRUCTOR DE INTERFAZ
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder para que la pantalla se repinte automáticamente
    // cada vez que el controlador llame a notifyListeners() (al sumar o agregar filas)
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
                    top: isWeb ? 40.0 : 24.0,
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
  // DISEÑOS (WEB Y MÓVIL)
  // ==========================================

  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNavegacionSuperior(),
        const SizedBox(height: 24),

        // 👉 AHORA SOLO LLAMAMOS A LA TARJETA UNIFICADA
        _buildInfoProyecto(),

        const SizedBox(height: 32),
        _buildContenedorPrincipal(isWeb: true),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PROYECTO SELECCIONADO",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1046C4),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),

        // 👉 USAMOS LA MISMA TARJETA HERMOSA PARA MÓVIL
        _buildInfoProyecto(),

        const SizedBox(height: 32),
        _buildContenedorPrincipal(isWeb: false),
      ],
    );
  }

  // ==========================================
  // COMPONENTES DE SOPORTE
  // ==========================================

  Widget _buildContenedorPrincipal({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 40 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 1. TÍTULO, SUBTÍTULO Y BUSCADOR RECUPERADOS
          if (isWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Actividades Planificadas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Defina los hitos y costos asociados a esta investigación",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Filtrar actividades...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.filter_list,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Actividades Planificadas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar actividades...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // 👉 2. ENCABEZADOS DE COLUMNA RECUPERADOS (SOLO WEB)
          if (isWeb) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "NOMBRE DE LA ACTIVIDAD",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Text(
                    "VALOR DE LA TAREA (USD)",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 48,
                ), // Espacio para alinear con el ícono de basura
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 👉 3. LISTA DE ACTIVIDADES Y RESTO DEL CONTENIDO
          ...List.generate(_controller.itemsActividad.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: isWeb ? _buildFilaWeb(index) : _buildFilaMobile(index),
            );
          }),

          _buildBotonAgregar(),
          const SizedBox(height: 40),
          _buildResumenTotal(isWeb),
          const SizedBox(height: 40),
          _buildAccionesFinales(isWeb),
        ],
      ),
    );
  }

  Widget _buildFilaWeb(int index) {
    final item = _controller.itemsActividad[index];
    return Row(
      children: [
        Expanded(flex: 2, child: _buildSelectorTipo(index)),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: _buildCampoValor(index)),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _controller.eliminarFila(index),
        ),
      ],
    );
  }

  Widget _buildFilaMobile(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ACTIVIDAD",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _controller.eliminarFila(index),
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          _buildSelectorTipo(index),
          const SizedBox(height: 16),
          const Text(
            "VALOR (USD)",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildCampoValor(index),
        ],
      ),
    );
  }

  Widget _buildSelectorTipo(int index) {
    return DropdownButtonFormField<String>(
      value: _controller.itemsActividad[index].tipo,
      decoration: _inputStyle(
        _cargandoCatalogos ? "Cargando..." : "Seleccione...",
      ),
      items: _tiposActividad
          .map(
            (t) => DropdownMenuItem(
              value: t,
              child: Text(
                t,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: (val) => _controller.cambiarTipoActividad(index, val, context),
    );
  }

  Widget _buildCampoValor(int index) {
    return TextFormField(
      controller: _controller.itemsActividad[index].valorController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      //decoration: _inputStyle("\$ 0.00", isMoney: true),
      decoration: _inputStyle("0.00", isMoney: true),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1046C4),
      ),
    );
  }

  Widget _buildResumenTotal(bool isWeb) {
    final esCorrecto =
        _controller.totalPresupuestado == _controller.valorObjetivo;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: esCorrecto ? const Color(0xFFE8F5E9) : const Color(0xFFF4F6FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TOTAL PRESUPUESTADO",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                esCorrecto
                    ? "✅ Presupuesto Cuadrado"
                    : "Objetivo: \$ ${_controller.valorObjetivo.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12,
                  color: esCorrecto ? Colors.green.shade700 : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            "\$ ${_controller.totalPresupuestado.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1046C4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesFinales(bool isWeb) {
    return Row(
      mainAxisAlignment: isWeb
          ? MainAxisAlignment.end
          : MainAxisAlignment.center,
      children: [
        TextButton(onPressed: widget.onCancelar, child: const Text("Cancelar")),
        const SizedBox(width: 16),

        ElevatedButton(
          onPressed: _controller.guardando
              ? null
              : () async {
                  final exito = await _controller.guardarEnFirebase(
                    widget.proyecto['id'],
                    context,
                  );
                  if (exito && mounted) {
                    // Esperamos un momento para que el usuario vea la barra verde antes de cerrar
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) widget.onCancelar();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1046C4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _controller.guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Guardar Actividades",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  // Estilos y Helpers menores...
  InputDecoration _inputStyle(String hint, {bool isMoney = false}) {
    return InputDecoration(
      hintText: hint,
      prefixText: isMoney ? "\$ " : null,
      filled: true,
      fillColor: isMoney ? const Color(0xFFEEF2FF) : const Color(0xFFF4F6FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBotonAgregar() {
    return OutlinedButton.icon(
      // 👉 Actualizamos el onPressed
      onPressed: () {
        // Ejecutamos la función del controlador y guardamos el resultado
        String? mensajeError = _controller.agregarNuevaFila();

        // Si el controlador nos devolvió un error, dibujamos el SnackBar
        if (mensajeError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ $mensajeError',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      icon: const Icon(Icons.add),
      label: const Text("Agregar Actividad"),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildNavegacionSuperior() {
    return InkWell(
      onTap: widget.onCancelar,
      child: Row(
        children: [
          Icon(Icons.arrow_back, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            "Listado / Ingreso de Actividades",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }


  // 👉 1. NUEVA TARJETA DE CONTEXTO UNIFICADA
  Widget _buildInfoProyecto() {
    DateTime fecha = (widget.proyecto['fechaRegistro'] as dynamic).toDate();
    String fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna Izquierda: Título y Chips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.proyecto['titulo'] ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _chip("ID: ${widget.proyecto['id']}"),
                    const SizedBox(width: 8),
                    _chip("Empresa: ${widget.proyecto['empresacontratante']}", isGray: true),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Columna Derecha: Cuadro Azul de Fecha
          // 👉 Columna Derecha: Cuadro Azul de Fecha (AHORA CON ÍCONO)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1046C4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FECHA DE INICIO",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8), // Un poquito más de espacio para respirar
                Row(
                  children: [
                    // 👉 Aquí agregamos el ícono del calendario
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fechaFormateada,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👉 2. MANTENEMOS TU CHIP INTACTO
  Widget _chip(String label, {bool isGray = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGray ? Colors.grey.shade200 : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildBotonPlanificadoMobile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1046C4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.event_available, color: Colors.white),
    );
  }
}
