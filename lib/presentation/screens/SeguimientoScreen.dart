import 'package:flutter/material.dart';

import '../controllers/SeguimientoController.dart';


class SeguimientoScreen extends StatefulWidget {
  final Map<String, dynamic> proyecto;
  final VoidCallback onCancelar;

  const SeguimientoScreen({
    super.key,
    required this.proyecto,
    required this.onCancelar,
  });

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

  class _SeguimientoScreenState extends State<SeguimientoScreen> {
  // 1. Instanciamos el controlador
  late final SeguimientoController _controller;

  @override
  void initState() {
  super.initState();
  _controller = SeguimientoController();
  // 2. Le enviamos los datos del proyecto al iniciar
  _controller.inicializar(widget.proyecto);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Envolvemos todo en un ListenableBuilder
    return ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          // Mostramos un loader mientras trae las quincenas de Firebase
          if (_controller.cargando) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1046C4)));
          }

          return Container(
            color: const Color(0xFFF8F9FD),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWeb = constraints.maxWidth > 900;
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(top: isWeb ? 40.0 : 24.0, left: isWeb ? 40.0 : 24.0, right: isWeb ? 40.0 : 24.0, bottom: 100.0),
                    child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
                  );
                },
              ),
            ),
          );
        }
    );
  }

  // ==========================================
  // DISEÑOS PRINCIPALES
  // ==========================================

  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNavegacionSuperior(),
        const SizedBox(height: 24),
        _buildInfoProyecto(), // 👉 La Tarjeta de Contexto que diseñamos
        const SizedBox(height: 32),
        _buildContenedorPrincipal(isWeb: true),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNavegacionSuperior(),
        const SizedBox(height: 16),
        _buildInfoProyecto(), // 👉 La Tarjeta de Contexto que diseñamos
        const SizedBox(height: 32),
        _buildContenedorPrincipal(isWeb: false),
      ],
    );
  }

  // ==========================================
  // COMPONENTES
  // ==========================================

  Widget _buildNavegacionSuperior() {
    return InkWell(
      onTap: widget.onCancelar,
      child: Row(
        children: [
          Icon(Icons.arrow_back, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            "Listado de investigaciones / Ingreso de Seguimiento",
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 👉 EL ENCABEZADO EXACTO DE ACTIVIDADES SCREEN
  Widget _buildInfoProyecto() {
    // Si tienes fechaRegistro en tu BD, úsala. Si no, usamos la fecha actual por ahora.
    DateTime fecha = widget.proyecto['fechaRegistro'] != null
        ? (widget.proyecto['fechaRegistro'] as dynamic).toDate()
        : DateTime.now();
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.proyecto['titulo'] ?? 'Sin título',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _chip("ID: ${widget.proyecto['id']}"),
                    const SizedBox(width: 8),
                    _chip("Empresa: ${widget.proyecto['empresacontratante'] ?? 'N/A'}", isGray: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
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
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      fechaFormateada,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _chip(String label, {bool isGray = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGray ? Colors.grey.shade200 : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildContenedorPrincipal({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 40 : 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Tus TextFields de búsqueda se mantienen igual) ...

          const SizedBox(height: 32),
          if (isWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _headerText("NOMBRE DE LA ACTIVIDAD")),
                  Expanded(flex: 2, child: _headerText("SOLICITUD DE PAGO", center: true)),
                  Expanded(flex: 2, child: _headerText("QUINCENA", center: true)),
                  Expanded(flex: 2, child: _headerText("PAGADO", center: true)),
                  Expanded(flex: 2, child: _headerText("ESTADO", center: true)),
                ],
              ),
            ),

          // 👉 CONECTAMOS LA LISTA DEL CONTROLADOR
          ...List.generate(_controller.actividades.length, (index) {
            return isWeb ? _buildFilaWeb(index) : _buildFilaMobile(index);
          }),

          const SizedBox(height: 40),

          _buildResumenFinanciero(isWeb),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: isWeb ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              TextButton(onPressed: widget.onCancelar, child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),

              // 👉 CONECTAMOS EL BOTÓN DE GUARDAR
              ElevatedButton(
                onPressed: _controller.guardando ? null : () async {
                  final exito = await _controller.guardarCambios(widget.proyecto['id'], context);
                  if (exito && mounted) {
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) widget.onCancelar();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1046C4), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                ),
                child: _controller.guardando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Guardar Cambios", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _headerText(String text, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.0),
    );
  }


  Widget _buildResumenFinanciero(bool isWeb) {
    // 1. Solo pedimos datos, no calculamos nada aquí
    double totalProyecto = double.tryParse(widget.proyecto['valor']?.toString() ?? '0') ?? 0.0;

    // 👉 Le pedimos el cálculo al Cerebro
    double totalCobrado = _controller.calcularTotalCobrado();
    double saldoPendiente = _controller.calcularSaldoPendiente(totalProyecto);

    // 2. Diseño del Banner (Esto se mantiene igual)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Flex(
        direction: isWeb ? Axis.horizontal : Axis.vertical,
        children: [
          // --- SECCIÓN COBRADO ---
          Expanded(
            flex: isWeb ? 1 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TOTAL COBRADO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_box, color: Color(0xFF2E7D32), size: 16),
                        const SizedBox(width: 4),
                        const Text("Dinero ingresado", style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Text("\$ ${totalCobrado.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
              ],
            ),
          ),

          if (isWeb) Container(height: 40, width: 1, color: Colors.green.shade200, margin: const EdgeInsets.symmetric(horizontal: 24)),
          if (!isWeb) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.green.shade200, height: 1)),

          // --- SECCIÓN PENDIENTE ---
          Expanded(
            flex: isWeb ? 1 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SALDO PENDIENTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text("Por recaudar", style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Text("\$ ${saldoPendiente.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👉 FILA WEB
  Widget _buildFilaWeb(int index) {
    final item = _controller.actividades[index]; // <-- Usa _controller
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FC), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                // 👉 NUEVO: Mostrar el valor de la actividad
                Text(
                  "Valor: \$${(item['valor'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

            ),
          ),
          Expanded(flex: 2, child: _buildToggleSwitch(item['solicitudPago'], (val) => _controller.toggleSolicitudPago(index, val))),
          Expanded(flex: 2, child: _buildDropdownQuincena(item, index)),
          Expanded(flex: 2, child: _buildToggleSwitch(item['pagado'], (val) => _controller.togglePagado(index, val))),
          Expanded(flex: 2, child: Center(child: _buildBadgeEstado(_controller.obtenerEstado(item)))), // <-- Lógica dinámica
        ],
      ),
    );
  }

  // 👉 FILA MÓVIL
  Widget _buildFilaMobile(int index) {
    final item = _controller.actividades[index]; // <-- Usa _controller
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FC), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 👉 NUEVO: Envolvemos en Column para mostrar el valor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      "Valor: \$${(item['valor'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildBadgeEstado(_controller.obtenerEstado(item)),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          const Text("QUINCENA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDropdownQuincena(item, index),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SOLICITUD PAGO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildToggleSwitch(item['solicitudPago'], (val) => _controller.toggleSolicitudPago(index, val), showText: true),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PAGADO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildToggleSwitch(item['pagado'], (val) => _controller.togglePagado(index, val), showText: true),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  // 👉 CONTROLES REUTILIZABLES
  Widget _buildToggleSwitch(bool value, ValueChanged<bool> onChanged, {bool showText = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white, activeTrackColor: const Color(0xFF1046C4),
          inactiveThumbColor: Colors.white, inactiveTrackColor: Colors.grey.shade300,
        ),
        if (showText) const SizedBox(width: 4),
        if (showText) Text(value ? "Sí" : "No", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildDropdownQuincena(Map<String, dynamic> item, int index) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item['quincena'],
          hint: const Text("Seleccione", style: TextStyle(fontSize: 12, color: Colors.grey)), // <-- Por si viene nulo
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
          onChanged: (String? newValue) => _controller.setQuincena(index, newValue),
          items: _controller.opcionesQuincena.map<DropdownMenuItem<String>>((String value) { // <-- Traemos del controller
            return DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBadgeEstado(String estado) {
    Color bgColor;
    Color textColor;

    switch (estado) {
      case "EN PROCESO":
        bgColor = const Color(0xFFE3F2FD); // Azul clarito
        textColor = const Color(0xFF1565C0);
        break;
      case "COMPLETADO":
        bgColor = const Color(0xFFE8F5E9); // Verde clarito
        textColor = const Color(0xFF2E7D32);
        break;
      default: // PENDIENTE
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(estado, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}