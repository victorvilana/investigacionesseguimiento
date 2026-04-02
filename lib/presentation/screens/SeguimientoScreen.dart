import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  // Lista simulada de actividades para generar la UI dinámicamente
  final List<Map<String, dynamic>> _actividades = [
    {
      "titulo": "Recolección de datos primarios",
      "subtitulo": "Finalizado el 12 Oct 2023",
      "precio": "\$450.00",
      "estado": "COMPLETADA",
      "solicitudPago": true,
      "pagado": true,
    },
    {
      "titulo": "Limpieza de Base de Datos", // En web dice Codificación...
      "subtitulo": "Asignado a Dr. Martínez • Vence en 3 días",
      "precio": "\$280.00",
      "estado": "EN PROCESO",
      "solicitudPago": false,
      "pagado": false,
    },
    {
      "titulo": "Validación por Expertos",
      "subtitulo": "Pendiente de inicio",
      "precio": "\$600.00",
      "estado": "PENDIENTE",
      "solicitudPago": false,
      "pagado": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      floatingActionButton: MediaQuery.of(context).size.width > 900
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1046C4),
        child: const Icon(Icons.add_task, color: Colors.white),
      )
          : null,
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
                  const SizedBox(height: 24),

                  // Selector de Proyecto y Tarjeta de Progreso
                  if (isWeb) ...[
                    _buildWebProjectSelector(),
                    const SizedBox(height: 30),
                    _buildWebProgressCard(),
                  ] else ...[
                    _buildMobileProjectSelector(),
                    const SizedBox(height: 20),
                    _buildMobileProgressCard(),
                  ],

                  const SizedBox(height: 32),

                  // Sección de Actividades
                  _buildActivitiesHeader(isWeb),
                  const SizedBox(height: 20),

                  // Lista de Actividades Responsiva
                  ..._actividades.map((actividad) {
                    return isWeb
                        ? _buildWebActivityItem(actividad)
                        : _buildMobileActivityItem(actividad);
                  }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- CABECERAS Y SELECTORES ---

  Widget _buildHeader(bool isWeb) {
    if (isWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 12),
          const Text("Módulo de Seguimiento", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 24),
          const Text("Módulo de Seguimiento", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
          //Text(isWeb ? "Cargar Nuevo Trabajo" : "Cargar Nuevo Trabajo", style: TextStyle(fontSize: isWeb ? 32 : 28, fontWeight: FontWeight.bold, height: 1.2)),

          //const SizedBox(height: 4),
          //const Text("Gestión y control de hitos de investigación", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      );
    }
  }

  Widget _buildMobileProjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SELECCIONE EL PROYECTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.folder, color: Color(0xFF1046C4)),
              SizedBox(width: 12),
              Expanded(child: Text("Análisis de Redes Neuronales 2024", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Icon(Icons.unfold_more, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebProjectSelector() {
    return Row(
      children: [
        const Text("PROYECTO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Text("Análisis de Redes Neuronales 2024", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
              SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF1046C4), size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // --- TARJETAS DE PROGRESO ---

  Widget _buildMobileProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Azul oscuro
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Avance General", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text("Q3 2024", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("64%", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: 0.64, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), borderRadius: BorderRadius.circular(10), minHeight: 8),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMobileProgressMetric(Icons.check_circle_outline, "12/18", "TAREAS")),
              const SizedBox(width: 12),
              Expanded(child: _buildMobileProgressMetric(Icons.schedule, "45", "DÍAS")),
              const SizedBox(width: 12),
              Expanded(child: _buildMobileProgressMetric(Icons.flag_outlined, "4/6", "HITOS")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProgressMetric(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildWebProgressCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Avance General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("64%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: 0.64, backgroundColor: const Color(0xFFE8EAF6), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1046C4)), borderRadius: BorderRadius.circular(10), minHeight: 10),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildWebProgressMetric("TAREAS", "12/18")),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(child: _buildWebProgressMetric("DÍAS RESTANTES", "45")),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(child: _buildWebProgressMetric("HITOS", "4/6")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebProgressMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- SECCIÓN DE ACTIVIDADES ---

  Widget _buildActivitiesHeader(bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Actividades Pendientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (isWeb)
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Color(0xFF1046C4), size: 18),
            label: const Text("Nueva Actividad", style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold)),
          )
        else
          TextButton(
            onPressed: () {},
            child: const Text("VER TODAS", style: TextStyle(color: Color(0xFF1046C4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          )
      ],
    );
  }

  // Elemento de lista Móvil
  Widget _buildMobileActivityItem(Map<String, dynamic> actividad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(actividad['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              _buildBadge(actividad['estado']),
            ],
          ),
          const SizedBox(height: 8),
          Text(actividad['precio'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMobileToggleBox("SOLICITUD PAGO", actividad['solicitudPago'])),
              const SizedBox(width: 12),
              Expanded(child: _buildMobileToggleBox("PAGADO", actividad['pagado'])),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMobileToggleBox(String label, bool value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF4F5F9), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: (val) {},
              activeColor: const Color(0xFF1046C4),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // Elemento de lista Web
  Widget _buildWebActivityItem(Map<String, dynamic> actividad) {
    // Determinar estilo del icono lateral según el estado
    Color iconBg;
    Color iconColor;
    IconData iconData;

    if (actividad['estado'] == 'COMPLETADA') {
      iconBg = const Color(0xFFE6F4EA);
      iconColor = const Color(0xFF137333);
      iconData = Icons.check;
    } else if (actividad['estado'] == 'EN PROCESO') {
      iconBg = const Color(0xFFE8F0FE);
      iconColor = const Color(0xFF1046C4);
      iconData = Icons.more_horiz;
    } else {
      iconBg = const Color(0xFFF1F3F4);
      iconColor = Colors.grey.shade700;
      iconData = Icons.schedule;
    }

    // Estilo del borde izquierdo si está en proceso
    BoxBorder? border = actividad['estado'] == 'EN PROCESO'
        ? const Border(left: BorderSide(color: Color(0xFF1046C4), width: 4))
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: actividad['estado'] == 'COMPLETADA' ? Colors.white : const Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconBg, radius: 18, child: Icon(iconData, color: iconColor, size: 18)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(actividad['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(actividad['precio'], style: const TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(actividad['subtitulo'], style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          _buildWebCheckIndicator("SOLICITUD DE PAGO", actividad['solicitudPago']),
          const SizedBox(width: 24),
          _buildWebCheckIndicator("PAGADO", actividad['pagado']),
          const SizedBox(width: 24),
          Container(width: 100, alignment: Alignment.centerRight, child: _buildBadge(actividad['estado'])),
        ],
      ),
    );
  }

  Widget _buildWebCheckIndicator(String label, bool isChecked) {
    return Row(
      children: [
        Icon(isChecked ? Icons.check_circle : Icons.radio_button_unchecked, color: isChecked ? const Color(0xFF1046C4) : Colors.grey.shade300, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- WIDGETS COMPARTIDOS ---

  Widget _buildBadge(String status) {
    Color bg;
    Color text;

    if (status == 'COMPLETADA') {
      bg = const Color(0xFFE6F4EA);
      text = const Color(0xFF137333);
    } else if (status == 'EN PROCESO') {
      bg = const Color(0xFFE8F0FE);
      text = const Color(0xFF1046C4);
    } else {
      bg = const Color(0xFFF1F3F4);
      text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: text, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}