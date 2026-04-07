import 'package:flutter/material.dart';
import '../widgets/action_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. El Container de fondo llega hasta arriba (detrás de la cámara)
    return Container(
      color: const Color(0xFFF8F9FD),
      // 2. SafeArea "empuja" y recorta todo lo que esté adentro para que no toque la barra de estado
      child: SafeArea(
        bottom: false, // Ignoramos el de abajo porque ya tienes la barra de navegación
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 900;

            // 3. El ScrollView ahora empieza estrictamente debajo de la zona segura
            return SingleChildScrollView(
              // Regresamos al padding uniforme (SIN forzar el top: 40)
              padding: EdgeInsets.all(isWeb ? 40.0 : 24.0),
              child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // DISEÑO WEB
  // ==========================================
  Widget _buildWebLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isWeb: true),
        const SizedBox(height: 32),

        // Accesos Rápidos
        Row(
          children: [
            Expanded(child: _buildQuickAccessCardWeb(Icons.list_alt_rounded, "Listado de\nInvestigaciones", "Acceda y gestione el listado completo de sus tesis, artículos y proyectos.", "EMPEZAR AHORA", const Color(0xFF1046C4))),
            const SizedBox(width: 24),
            Expanded(child: _buildQuickAccessCardWeb(Icons.track_changes_rounded, "Seguimiento", "Monitoree el progreso detallado de sus proyectos y reciba notificaciones.", "VER PROYECTOS", Colors.grey.shade600)),
            const SizedBox(width: 24),
            Expanded(child: _buildQuickAccessCardWeb(Icons.analytics_outlined, "Estadísticas", "Analice el impacto y rendimiento de sus investigaciones con reportes.", "VER REPORTES", Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 40),

        // Contenido Principal (Columnas)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proyectos Activos (Izquierda)
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Proyectos Activos", actionText: "Ver todos"),
                  const SizedBox(height: 16),
                  _buildProjectCardWeb("Inteligencia Artificial", "#4429", "Optimización de Redes Neuronales en Dispositivos de Bajo Consumo", 4, 0.75, const Color(0xFFE8EEFF), const Color(0xFF1046C4)),
                  const SizedBox(height: 16),
                  _buildProjectCardWeb("Sostenibilidad", "#3911", "Análisis de Ciclo de Vida de Baterías de Estado Sólido", 2, 0.30, const Color(0xFFFFEDE6), const Color(0xFFD95A3B)),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // Actividad e Insights (Derecha)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Actividad Reciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Column(
                      children: [
                        _buildActivityItem(Icons.check_circle, Colors.blue.shade700, "Carga de Documento", "Has subido 'Metodología_v2.pdf' al proyecto #4429", "HACE 2 HORAS"),
                        _buildActivityDivider(),
                        _buildActivityItem(Icons.chat_bubble_outline, Colors.grey.shade600, "Revisión Pendiente", "El Dr. Martínez ha comentado tu última publicación.", "AYER, 4:30 PM"),
                        _buildActivityDivider(),
                        _buildActivityItem(Icons.error_outline, Colors.red.shade700, "Próximo Vencimiento", "Entrega del reporte trimestral en 3 días.", "12 OCTUBRE, 2023", isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPremiumInsightCard(),
                ],
              ),
            )
          ],
        )
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
        _buildHeader(isWeb: false),
        const SizedBox(height: 32),

        const Text("Accesos Rápidos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 16),
        _buildQuickAccessCardMobile(Icons.upload_file_rounded, "Listado de Investigaciones", "Sube nuevos documentos y tesis.", "Empezar Ahora", true),
        const SizedBox(height: 16),
        _buildQuickAccessCardMobile(Icons.track_changes_rounded, "Seguimiento", "Revisa el estado de tus envíos.", "Ver Proyectos", false),
        const SizedBox(height: 16),
        _buildQuickAccessCardMobile(Icons.analytics_outlined, "Estadísticas", "Analiza el impacto de tus publicaciones.", "Ver Reportes", false),

        const SizedBox(height: 32),
        _buildPremiumInsightCard(),

        const SizedBox(height: 32),
        _buildSectionTitle("Proyectos Activos", actionText: "Ver Todo"),
        const SizedBox(height: 16),

        // 👉 AQUÍ APLICAMOS LA NUEVA TARJETA MÓVIL IDÉNTICA A TU FOTO
        _buildProjectCardMobile("Inteligencia Artificial", "#4429", "Optimización de Redes Neuronales en Dispositivos de Bajo Consumo", 4, 0.75, const Color(0xFFE8EEFF), const Color(0xFF1046C4)),
        const SizedBox(height: 16),
        _buildProjectCardMobile("Sostenibilidad", "#3911", "Análisis de Ciclo de Vida de Baterías de Estado Sólido", 2, 0.30, const Color(0xFFFFEDE6), const Color(0xFFD95A3B)),

        const SizedBox(height: 32),
        const Text("Actividad Reciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 16),
        _buildActivityItem(Icons.upload, Colors.blue.shade700, "Carga de Documento", "'Metodología Experimental' subido correctamente.", "HACE 2 HORAS"),
        const SizedBox(height: 16),
        _buildActivityItem(Icons.remove_red_eye_outlined, Colors.blue.shade700, "Revisión Pendiente", "El Dr. Méndez ha solicitado cambios en el Capítulo 3.", "AYER, 18:45"),
        const SizedBox(height: 16),
        _buildActivityItem(Icons.error_outline, Colors.red.shade700, "Próximo Vencimiento", "Entrega de borrador final: 3 días restantes.", "PRÓXIMAMENTE", isLast: true),
      ],
    );
  }

  // ==========================================
  // COMPONENTES REUTILIZABLES
  // ==========================================

  Widget _buildHeader({required bool isWeb}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //if (!isWeb) const Text("PANEL PRINCIPAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1046C4), letterSpacing: 1)),
              Text("Hola, Dr. Jimbo", style: TextStyle(fontSize: isWeb ? 32 : 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              Text("Bienvenido a la plataforma para el seguimiento de sus investigaciones.", style: TextStyle(fontSize: isWeb ? 16 : 14, color: Colors.grey.shade600)),
              if (!isWeb) const SizedBox(height: 16),
              if (!isWeb) _buildDateBadge(),
            ],
          ),
        ),
        if (isWeb) _buildDateBadge(),
      ],
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.indigo.shade900),
          const SizedBox(width: 8),
          Text("14 OCTUBRE, 2023", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required String actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        TextButton(onPressed: () {}, child: Text(actionText, style: const TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildQuickAccessCardWeb(IconData icon, String title, String description, String buttonText, Color iconColor) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2)),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
            ],
          ),
          Row(
            children: [
              Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF1046C4)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickAccessCardMobile(IconData icon, String title, String subtitle, String buttonText, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF1046C4))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? const Color(0xFF1046C4) : const Color(0xFFEEF2FF),
                foregroundColor: isPrimary ? Colors.white : const Color(0xFF1046C4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
    );
  }

  // 👉 NUEVA TARJETA DE PROYECTO PARA MÓVIL (Acorde a la foto)
  Widget _buildProjectCardMobile(String category, String id, String title, int investigators, double progress, Color badgeBg, Color badgeText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FE), // Un ligero tono azul-grisáceo como en la foto
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila Superior (Avatar + Etiquetas + Título)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade800,
                child: const Icon(Icons.science, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(category.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeText)),
                        ),
                        const SizedBox(width: 8),
                        Text("ID: $id", style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Fila Media (Investigadores y Porcentaje)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_alt, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text("$investigators Investigadores", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ],
              ),
              Text("${(progress * 100).toInt()}% COMPLETADO", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
            ],
          ),
          const SizedBox(height: 12),

          // Fila Inferior (Barra de progreso de ancho completo)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF1046C4),
              minHeight: 8,
            ),
          )
        ],
      ),
    );
  }

  // Tarjeta de Proyecto para WEB
  Widget _buildProjectCardWeb(String category, String id, String title, int investigators, double progress, Color badgeBg, Color badgeText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF6F8FE), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          CircleAvatar(radius: 35, backgroundColor: Colors.grey.shade800, child: const Icon(Icons.science, size: 30, color: Colors.white)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(category.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeText)),
                    ),
                    const SizedBox(width: 12),
                    Text("ID: $id", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people_alt, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text("$investigators Investigadores", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(width: 24),
                    Text("${(progress * 100).toInt()}% COMPLETADO", style: const TextStyle(fontSize: 13, color: Color(0xFF1046C4), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF1046C4),
                          minHeight: 8,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1046C4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text("PREMIUM INSIGHT", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Su productividad ha aumentado un 12% hasta la fecha.", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 12),
          const Text("Basado en el número de hitos completados y horas de investigación registradas.", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1046C4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text("DESCARGAR REPORTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, Color iconColor, String title, String subtitle, String time, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: iconColor, width: 1.5)),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            if (!isLast) Container(width: 1.5, height: 40, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(vertical: 4)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActivityDivider() {
    return const SizedBox.shrink();
  }
}