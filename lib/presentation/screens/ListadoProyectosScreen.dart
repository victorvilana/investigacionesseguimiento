import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../infrastructure/services/InvestigacionService.dart';

class ListadoProyectosScreen extends StatefulWidget {
  final VoidCallback onNuevoProyecto;
  final Function(Map<String, dynamic>) onEditarProyecto; // 👉 Recibimos la nueva función

  const ListadoProyectosScreen({
    super.key,
    required this.onNuevoProyecto,
    required this.onEditarProyecto,
  });

  @override
  State<ListadoProyectosScreen> createState() => _ListadoProyectosScreenState();
}

class _ListadoProyectosScreenState extends State<ListadoProyectosScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _buildContenidoDinamico(bool isWeb) {
    final investigacionService = InvestigacionService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildSearchAndFilters(isWeb: isWeb),
        const SizedBox(height: 32),

        StreamBuilder<QuerySnapshot>(
          stream: investigacionService.obtenerInvestigacionesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF1046C4)));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEstadoVacio(mensaje: "No hay proyectos guardados en el sistema.");

            final todasLasInvestigaciones = snapshot.data!.docs;
            final investigacionesFiltradas = todasLasInvestigaciones.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final idDoc = doc.id.toLowerCase();
              final titulo = (data['titulo'] ?? '').toString().toLowerCase();
              final busqueda = _searchQuery.toLowerCase();
              return idDoc.contains(busqueda) || titulo.contains(busqueda);
            }).toList();

            if (investigacionesFiltradas.isEmpty) return _buildEstadoVacio(mensaje: 'No se encontraron resultados para "$_searchQuery".', icono: Icons.search_off_rounded);

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: investigacionesFiltradas.length,
              itemBuilder: (context, index) {
                final doc = investigacionesFiltradas[index];
                final data = doc.data() as Map<String, dynamic>;

                // Preparamos los datos completos para enviarlos si el usuario quiere editar
                final datosCompletos = Map<String, dynamic>.from(data);
                datosCompletos['id'] = doc.id; // Agregamos el ID al mapa

                final String idDoc = doc.id;
                final String titulo = data['titulo'] ?? 'Sin título';
                final String empresa = data['empresacontratante'] ?? 'Sin Empresa';
                final int iconoCode = data['icono'] ?? Icons.science.codePoint;

                String fechaFormateada = "Sin fecha";
                if (data['fechaRegistro'] != null) {
                  DateTime fecha = (data['fechaRegistro'] as Timestamp).toDate();
                  fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
                }

                if (isWeb) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProjectCardWeb(
                      iconCode: iconoCode, empresa: empresa, id: idDoc, titulo: titulo, fechaTexto: fechaFormateada, investigators: 0, progress: 0.0,
                      datosCompletos: datosCompletos, // 👉 Lo pasamos a la tarjeta
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProjectCardMobile(
                      iconCode: iconoCode, empresa: empresa, id: idDoc, titulo: titulo, fechaTexto: fechaFormateada, investigators: 0, progress: 0.0,
                      datosCompletos: datosCompletos, // 👉 Lo pasamos a la tarjeta
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEstadoVacio({required String mensaje, IconData icono = Icons.folder_open}) {
    // ... (igual a tu código actual)
    return Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFD6DDF0))), child: Column(children: [Icon(icono, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), const Text("No hay resultados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(mensaje, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center)]));
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Listado de Proyectos", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))), const SizedBox(height: 8), Text("Gestione y supervise todas las investigaciones activas.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600))]);
  }

  Widget _buildSearchAndFilters({required bool isWeb}) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Flex(direction: isWeb ? Axis.horizontal : Axis.vertical, children: [Flexible(flex: isWeb ? 1 : 0, child: TextField(onChanged: (valor) => setState(() => _searchQuery = valor), decoration: InputDecoration(hintText: "Buscar por código o título...", hintStyle: TextStyle(color: Colors.grey.shade400), prefixIcon: Icon(Icons.search, color: Colors.grey.shade400), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)))), if (isWeb) Container(height: 30, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 8)), if (!isWeb) const Divider(height: 1, color: Color(0xFFEEEEEE)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Color(0xFF1046C4)), label: const Text("Filtros Avanzados", style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)))]));
  }

  // ==========================================
  // TARJETAS (Ahora con el botón de editar)
  // ==========================================
  Widget _buildProjectCardWeb({
    required int iconCode, required String empresa, required String id, required String titulo, required String fechaTexto, required int investigators, required double progress,
    required Map<String, dynamic> datosCompletos, // Recibimos los datos
  }) {
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
                    // 👉 BOTÓN DE EDITAR
                    InkWell(
                      onTap: () => widget.onEditarProyecto(datosCompletos),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_alt, size: 16, color: Colors.grey.shade500), const SizedBox(width: 6), Text("$investigators Investigadores", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)), const SizedBox(width: 16), Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500), const SizedBox(width: 6), Text(fechaTexto, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Progreso General", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: const Color(0xFF1046C4), minHeight: 8))])),
          const SizedBox(width: 32),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEEF2FF), foregroundColor: const Color(0xFF1046C4), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Ingresar Actividades", style: TextStyle(fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  Widget _buildProjectCardMobile({
    required int iconCode, required String empresa, required String id, required String titulo, required String fechaTexto, required int investigators, required double progress,
    required Map<String, dynamic> datosCompletos, // Recibimos los datos
  }) {
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
                        // 👉 BOTÓN DE EDITAR
                        InkWell(
                          onTap: () => widget.onEditarProyecto(datosCompletos),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [Icon(Icons.people_alt, size: 16, color: Colors.grey.shade600), const SizedBox(width: 6), Text("$investigators Investigadores", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)), const SizedBox(width: 16), Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6), Text(fechaTexto, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500))]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Progreso", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1046C4)))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: const Color(0xFF1046C4), minHeight: 8)), const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1046C4), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.add_task, size: 20), label: const Text("Ingresar Actividades", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))))
        ],
      ),
    );
  }
}