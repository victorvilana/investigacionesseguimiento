import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/ListadoProyectosController.dart';

class ListadoProyectosScreen extends StatefulWidget {
  final VoidCallback onNuevoProyecto;
  final Function(Map<String, dynamic>) onEditarProyecto;
  final Function(Map<String, dynamic>) onIngresarActividades;
  final Function(Map<String, dynamic>) onIngresarSeguimiento;
  final bool esModoSeguimiento;

  const ListadoProyectosScreen({
    super.key,
    required this.onNuevoProyecto,
    required this.onEditarProyecto,
    required this.onIngresarActividades,
    required this.onIngresarSeguimiento,
    this.esModoSeguimiento = false,
  });

  @override
  State<ListadoProyectosScreen> createState() => _ListadoProyectosScreenState();
}

class _ListadoProyectosScreenState extends State<ListadoProyectosScreen> {
  // 👉 1. Instanciamos el Controlador
  late final ListadoProyectosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ListadoProyectosController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 👉 2. Envolvemos la UI para que escuche al Controlador
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 900;

            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FD),
              floatingActionButton: isWeb
                  ? FloatingActionButton.extended(
                onPressed: widget.onNuevoProyecto,
                backgroundColor: const Color(0xFF1046C4),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Nuevo Proyecto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
                  : FloatingActionButton(
                onPressed: widget.onNuevoProyecto,
                backgroundColor: const Color(0xFF1046C4),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.only(top: 40.0, left: isWeb ? 40.0 : 24.0, right: isWeb ? 40.0 : 24.0, bottom: 100.0),
                child: _buildContenidoDinamico(isWeb),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContenidoDinamico(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildSearchAndFilters(isWeb: isWeb),
        const SizedBox(height: 32),

        // 👉 3. Usamos las variables del controlador en lugar de un StreamBuilder
        if (_controller.isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF1046C4)))
        else if (_controller.proyectosFiltrados.isEmpty && _controller.searchQuery.isEmpty)
          _buildEstadoVacio(mensaje: "No hay proyectos guardados en el sistema.")
        else if (_controller.proyectosFiltrados.isEmpty)
            _buildEstadoVacio(mensaje: 'No se encontraron resultados para "${_controller.searchQuery}".', icono: Icons.search_off_rounded)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.proyectosFiltrados.length,
              itemBuilder: (context, index) {
                final datosCompletos = _controller.proyectosFiltrados[index];

                // Pedimos los cálculos al cerebro
                double montoPendiente = _controller.calcularMontoPorCobrar(datosCompletos);

                final String idDoc = datosCompletos['id'];
                final String titulo = datosCompletos['titulo'] ?? 'Sin título';
                final String empresa = datosCompletos['empresacontratante'] ?? 'Sin Empresa';
                final int iconoCode = datosCompletos['icono'] ?? Icons.science.codePoint;

                String fechaFormateada = "Sin fecha";
                if (datosCompletos['fechaRegistro'] != null) {
                  DateTime fecha = (datosCompletos['fechaRegistro'] as Timestamp).toDate();
                  fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
                }

                if (isWeb) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProjectCardWeb(
                      iconCode: iconoCode, empresa: empresa, id: idDoc, titulo: titulo, fechaTexto: fechaFormateada, montoPorCobrar: montoPendiente, datosCompletos: datosCompletos,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProjectCardMobile(
                      iconCode: iconoCode, empresa: empresa, id: idDoc, titulo: titulo, fechaTexto: fechaFormateada, montoPorCobrar: montoPendiente, datosCompletos: datosCompletos,
                    ),
                  );
                }
              },
            ),
      ],
    );
  }

  // ==========================================
  // COMPONENTES SECUNDARIOS E IGUALES A TU CÓDIGO
  // ==========================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Listado de Proyectos", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text("Gestione y supervise todas las investigaciones activas.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSearchAndFilters({required bool isWeb}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Flex(
        direction: isWeb ? Axis.horizontal : Axis.vertical,
        children: [
          Flexible(
            flex: isWeb ? 1 : 0,
            child: TextField(
              onChanged: _controller.actualizarBusqueda, // 👉 Directo al cerebro
              decoration: InputDecoration(
                hintText: "Buscar por código o título...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          if (isWeb) Container(height: 30, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 8)),
          if (!isWeb) const Divider(height: 1, color: Color(0xFFEEEEEE)),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Color(0xFF1046C4)),
            label: const Text("Filtros Avanzados", style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio({required String mensaje, IconData icono = Icons.folder_open}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFD6DDF0))),
      child: Column(
        children: [
          Icon(icono, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No hay resultados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(mensaje, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==========================================
  // LÓGICA DE ELIMINACIÓN Y TARJETAS
  // ==========================================

  Future<void> _confirmarEliminacion(Map<String, dynamic> proyecto) async {
    final String idProyecto = proyecto['id'];
    final String tituloProyecto = proyecto['titulo'] ?? 'Sin título';

    // 👉 1. NUEVA VALIDACIÓN: Verificar si ya existe información de seguimiento
    final List<dynamic> actividades = proyecto['actividades'] ?? [];
    bool tieneSeguimiento = false;

    for (var act in actividades) {
      // Si la actividad tiene quincena, solicitud de pago, ya fue pagada, o está completada,
      // consideramos que el proyecto ya tiene seguimiento en curso.
      if (act['pagado'] == true ||
          act['solicitudPago'] == true ||
          (act['quincena'] != null && act['quincena'].toString().isNotEmpty) ||
          act['estado'] == 'COMPLETADO' ||
          act['estado'] == 'EN PROCESO') {
        tieneSeguimiento = true;
        break;
      }
    }

    // 👉 2. SI TIENE SEGUIMIENTO: Bloqueamos y mostramos alerta
    if (tieneSeguimiento) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(Icons.block, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 8),
                const Text("Acción denegada"),
              ],
            ),
            content: Text.rich(TextSpan(
              text: "No es posible eliminar el proyecto:\n\n",
              children: [
                TextSpan(text: tituloProyecto, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                const TextSpan(text: "\n\nPorque ya cuenta con información de seguimiento ingresada (quincenas, estados o pagos)."),
              ],
            )),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1046C4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Entendido"),
              ),
            ],
          );
        },
      );
      return; // Salimos de la función aquí, la eliminación se cancela automáticamente
    }

    // 👉 3. SI NO TIENE SEGUIMIENTO: Mostramos el diálogo normal de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 28),
              const SizedBox(width: 8),
              const Text("¿Eliminar proyecto?"),
            ],
          ),
          content: Text.rich(TextSpan(
            text: "Estás a punto de eliminar permanentemente el proyecto:\n\n",
            children: [
              TextSpan(text: tituloProyecto, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const TextSpan(text: "\n\nEsta acción no se puede deshacer y borrará todas las actividades asociadas."),
            ],
          )),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Sí, eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminando proyecto...', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1046C4), duration: Duration(milliseconds: 500)));

      final error = await _controller.eliminarProyecto(idProyecto);

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Proyecto eliminado con éxito!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $error', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildProjectCardWeb({required int iconCode, required String empresa, required String id, required String titulo, required String fechaTexto, required double montoPorCobrar, required Map<String, dynamic> datosCompletos}) {
    double progress = _controller.calcularProgreso(datosCompletos); // 👉 Se le pide al cerebro
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)), child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: const Color(0xFF1046C4), size: 32)),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)), child: Text(empresa.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1046C4)))),
                    const SizedBox(width: 12),
                    Text(id, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    InkWell(onTap: () => widget.onEditarProyecto(datosCompletos), borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.edit, size: 16, color: Colors.grey.shade400))),
                    const SizedBox(width: 4),
                    InkWell(onTap: () => _confirmarEliminacion(datosCompletos), borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Text("Por cobrar: \$${montoPorCobrar.toStringAsFixed(2)}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(fechaTexto, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Progreso General", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: const Color(0xFF1046C4), minHeight: 8)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: () {
              if (widget.esModoSeguimiento) {
                widget.onIngresarSeguimiento(datosCompletos);
              } else {
                widget.onIngresarActividades(datosCompletos);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.esModoSeguimiento ? const Color(0xFF1046C4) : const Color(0xFFEEF2FF), foregroundColor: widget.esModoSeguimiento ? Colors.white : const Color(0xFF1046C4)),
            child: Text(widget.esModoSeguimiento ? "Ingresar Seguimiento" : "Ingresar Actividades", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCardMobile({required int iconCode, required String empresa, required String id, required String titulo, required String fechaTexto, required double montoPorCobrar, required Map<String, dynamic> datosCompletos}) {
    double progress = _controller.calcularProgreso(datosCompletos); // 👉 Se le pide al cerebro
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(16)), child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: const Color(0xFF1046C4), size: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)), child: Text(empresa.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1046C4)), overflow: TextOverflow.ellipsis))),
                        const SizedBox(width: 8),
                        Text(id, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                        InkWell(onTap: () => widget.onEditarProyecto(datosCompletos), borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Icon(Icons.edit, size: 16, color: Colors.grey.shade400))),
                        InkWell(onTap: () => _confirmarEliminacion(datosCompletos), borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Text("Por cobrar: \$${montoPorCobrar.toStringAsFixed(2)}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(fechaTexto, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progreso", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: const Color(0xFF1046C4), minHeight: 8)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.esModoSeguimiento) {
                  widget.onIngresarSeguimiento(datosCompletos);
                } else {
                  widget.onIngresarActividades(datosCompletos);
                }
              },
              icon: Icon(widget.esModoSeguimiento ? Icons.analytics : Icons.add_task, size: 20),
              label: Text(widget.esModoSeguimiento ? "Ingresar Seguimiento" : "Ingresar Actividades", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}