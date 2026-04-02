import 'package:flutter/material.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWeb ? 40 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isWeb),
                  const SizedBox(height: 32),

                  // Layout Principal
                  if (isWeb) ...[
                    // Versión Web: Tarjetas lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildWebCompletenessCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _buildComparisonCard(isWeb: true)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildWebActivitiesSection(),
                  ] else ...[
                    // Versión Móvil: Elementos apilados
                    _buildMobileSummaryCard(),
                    const SizedBox(height: 32),
                    const Text("Comparativa de Proyectos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildComparisonCard(isWeb: false),
                    const SizedBox(height: 32),
                    _buildMobileActivitiesHeader(),
                    const SizedBox(height: 16),
                    _buildMobileActivitiesList(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- CABECERA ---

  Widget _buildHeader(bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isWeb) ...[

                const SizedBox(height: 24),
              ],
              Text(
                  isWeb ? "Resumen de Avance\nInvestigativo" : "Resumen de Avance",
                  style: TextStyle(fontSize: isWeb ? 32 : 24, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 8),
              Text(
                isWeb ? "Análisis en tiempo real del progreso investigativo." : "Análisis en tiempo real del progreso investigativo",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        if (isWeb)
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1046C4)),
                label: const Text("Últimos 30 días", style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1046C4),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Descargar Reporte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
      ],
    );
  }

  // --- TARJETAS RESUMEN (MÓVIL Y WEB) ---

  Widget _buildMobileSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCircularProgress(100, 0.75, "75%", "META"),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatNumber("12", "PROYECTOS ACTIVOS"),
                    const SizedBox(height: 16),
                    _buildStatNumber("28", "ETAPAS FINALIZADAS"),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Meta Anual 2024", style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.trending_up, color: Color(0xFF1046C4), size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWebCompletenessCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text("COMPLETITUD GLOBAL", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 32),
          _buildCircularProgress(200, 0.75, "75%", "Objetivo Anual", fontSize: 48),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatNumber("12 Proyectos", "ACTIVOS", isWeb: true),
              _buildStatNumber("28 Etapas", "FINALIZADOS", isWeb: true),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatNumber(String value, String label, {bool isWeb = false}) {
    return Column(
      crossAxisAlignment: isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (isWeb) Text(label, style: const TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        if (isWeb) const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isWeb ? 20 : 24, fontWeight: FontWeight.bold)),
        if (!isWeb) Text(label, style: const TextStyle(color: Colors.black54, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildCircularProgress(double size, double value, String percent, String label, {double fontSize = 24}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: size * 0.1,
              backgroundColor: const Color(0xFFF0F2F8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1046C4)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(percent, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF1046C4))),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // --- COMPARATIVA DE PROYECTOS ---

  Widget _buildComparisonCard({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 24),
      decoration: BoxDecoration(
        color: isWeb ? Colors.white : const Color(0xFFF4F5F9), // Blanco en web, gris en app
        borderRadius: BorderRadius.circular(isWeb ? 24 : 32),
        boxShadow: isWeb ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWeb) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Comparativa de Proyectos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.more_vert, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 32),
          ],
          _buildLinearProgressItem("Genómica Computacional", 0.88),
          const SizedBox(height: 24),
          _buildLinearProgressItem("IA en Bioinformática", 0.62),
          const SizedBox(height: 24),
          _buildLinearProgressItem("Sostenibilidad Energética", 0.45),
          const SizedBox(height: 24),
          _buildLinearProgressItem("Materiales Avanzados", 0.92),
          const SizedBox(height: 24),
          _buildLinearProgressItem("Psicología Cognitiva", 0.20),
        ],
      ),
    );
  }

  Widget _buildLinearProgressItem(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("${(value * 100).toInt()}%", style: const TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8EAF6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1046C4)),
          ),
        ),
      ],
    );
  }

  // --- ACTIVIDADES RECIENTES (MÓVIL) ---

  Widget _buildMobileActivitiesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(child: Text("Actividades entregadas\nrecientemente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        TextButton(onPressed: () {}, child: const Text("VER\nTODO", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    );
  }

  Widget _buildMobileActivitiesList() {
    return Column(
      children: [
        _buildMobileTimelineItem(
            icon: Icons.check,
            title: "Publicación de Paper: Algoritmos Genómicos",
            desc: "Revisión de pares completada exitosamente.",
            time: "Hace 2h",
            badge: "GENÓMICA",
            isFirst: true
        ),
        _buildMobileTimelineItem(
            icon: Icons.description,
            title: "Dataset de IA Bioinformática",
            desc: "Subida de 4GB de datos procesados al servidor central.",
            time: "Ayer"
        ),
        _buildMobileTimelineItem(
            icon: Icons.people,
            title: "Reunión de Sostenibilidad",
            desc: "Definición de objetivos para el Q3.",
            time: "2 días",
            isLast: true
        ),
      ],
    );
  }

  Widget _buildMobileTimelineItem({required IconData icon, required String title, required String desc, required String time, String? badge, bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 12, backgroundColor: const Color(0xFF1046C4), child: Icon(icon, color: Colors.white, size: 14)),
              if (!isLast) Expanded(child: Container(width: 1, color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    if (badge != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                        child: Text(badge, style: const TextStyle(color: Color(0xFF1046C4), fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- ACTIVIDADES RECIENTES (WEB) ---

  Widget _buildWebActivitiesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Actividades entregadas recientemente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildWebTimelineItem("COMPLETADO", "Envío de Manuscrito: Genoma del Arroz", "Sometido a 'Nature Genetics' por el equipo del Dr. Velez.", "Hace 2 días • Laboratorio de Biotecnología", true),
          _buildWebTimelineItem("EN PROCESO", "Recolección de Datos: Eficiencia Fotovoltaica", "Finalización de la fase 2 de experimentación de campo.", "Programado para mañana • Estación de Energía Solar", false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildWebTimelineItem(String badge, String title, String desc, String meta, bool isCompleted, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: isCompleted ? const Color(0xFF1046C4) : Colors.grey.shade400, shape: BoxShape.circle),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isCompleted ? const Color(0xFFEEF2FF) : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: Text(badge, style: TextStyle(color: isCompleted ? const Color(0xFF1046C4) : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCompleted ? Colors.black87 : Colors.black54)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: isCompleted ? Colors.black54 : Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(meta, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}