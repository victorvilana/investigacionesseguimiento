import 'package:flutter/material.dart';
import '../controllers/DashboardController.dart';

class DashboardScreen extends StatefulWidget {
  // 👉 Ahora recibimos 3 funciones de navegación
  final VoidCallback onIrAListado;
  final VoidCallback onIrASeguimiento;
  final VoidCallback onIrAEstadisticas;

  const DashboardScreen({
    super.key,
    required this.onIrAListado,
    required this.onIrASeguimiento,
    required this.onIrAEstadisticas,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isWebGlobal = MediaQuery.of(context).size.width > 800;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1046C4)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),

                // KPIs Financieros
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWeb = constraints.maxWidth > 800;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildKPICard(titulo: "Proyectos Activos", valor: _controller.totalProyectos.toString(), icono: Icons.folder_copy_outlined, color: const Color(0xFF1046C4), isWeb: isWeb),
                        _buildKPICard(titulo: "Presupuesto Total", valor: "\$${_controller.montoTotalPresupuestado.toStringAsFixed(2)}", icono: Icons.account_balance_wallet_outlined, color: Colors.blueGrey, isWeb: isWeb),
                        _buildKPICard(titulo: "Monto Recaudado", valor: "\$${_controller.montoTotalCobrado.toStringAsFixed(2)}", icono: Icons.check_circle_outline, color: const Color(0xFF2E7D32), isWeb: isWeb),
                        _buildKPICard(titulo: "Por Cobrar", valor: "\$${_controller.montoTotalPendiente.toStringAsFixed(2)}", icono: Icons.pending_actions, color: Colors.orange.shade700, isWeb: isWeb),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 60),

                // 👉 NUEVA SECCIÓN DE ACCESOS RÁPIDOS
                const Text(
                  "Accesos Rápidos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWeb = constraints.maxWidth > 900;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildActionCard(
                          titulo: "Listado de\nInvestigaciones",
                          descripcion: "Acceda y gestione el listado completo de sus tesis, artículos y proyectos de investigación registrados.",
                          actionText: "EMPEZAR AHORA",
                          icono: Icons.view_list_rounded,
                          iconColor: Colors.white,
                          iconBgColor: const Color(0xFF1046C4),
                          onTap: widget.onIrAListado,
                          isWeb: isWeb,
                        ),
                        _buildActionCard(
                          titulo: "Seguimiento\nde Proyectos",
                          descripcion: "Monitoree el progreso detallado de sus proyectos y reciba notificaciones sobre hitos alcanzados.",
                          actionText: "VER PROYECTOS",
                          icono: Icons.insert_chart_rounded,
                          iconColor: const Color(0xFF5C6BC0),
                          iconBgColor: const Color(0xFFE8EAF6),
                          onTap: widget.onIrASeguimiento,
                          isWeb: isWeb,
                        ),
                        _buildActionCard(
                          titulo: "Estadísticas\ny Reportes",
                          descripcion: "Analice el impacto y rendimiento de sus investigaciones con reportes detallados y métricas clave.",
                          actionText: "VER REPORTES",
                          icono: Icons.trending_up_rounded,
                          iconColor: const Color(0xFF5C6BC0),
                          iconBgColor: const Color(0xFFE8EAF6),
                          onTap: widget.onIrAEstadisticas,
                          isWeb: isWeb,
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Panel Principal", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text("Resumen general de las investigaciones y estado financiero.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildKPICard({required String titulo, required String valor, required IconData icono, required Color color, required bool isWeb}) {
    double cardWidth = isWeb ? 280 : double.infinity;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icono, color: color, size: 32)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 👉 NUEVA TARJETA DE ACCESO RÁPIDO CALCADA DE TU IMAGEN
  Widget _buildActionCard({
    required String titulo,
    required String descripcion,
    required String actionText,
    required IconData icono,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    required bool isWeb,
  }) {
    double cardWidth = isWeb ? 320 : double.infinity;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        hoverColor: const Color(0xFFF4F6FC),
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Detalle circular en la esquina superior derecha
                const Positioned(
                  top: -40,
                  right: -40,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Color(0xFFF4F6FC), // Color celeste muy sutil
                  ),
                ),
                // Contenido de la tarjeta
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícono con fondo
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icono, color: iconColor, size: 28),
                      ),
                      const SizedBox(height: 24),
                      // Título
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      // Botón de acción con flecha
                      Row(
                        children: [
                          Text(
                            actionText,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1046C4)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1046C4)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}