import 'package:flutter/material.dart';
import '../widgets/action_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 40 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isWeb),
          const SizedBox(height: 30),

          // CARDS DE ACCESO RÁPIDO
          if (isWeb)
            Row(
              children: const [
                Expanded(child: ActionCard(title: "Cargar Trabajo", desc: "Inicie el registro de nuevas tesis...", icon: Icons.upload_file, isPrimary: true, buttonText: "EMPEZAR AHORA")),
                SizedBox(width: 20),
                Expanded(child: ActionCard(title: "Seguimiento", desc: "Revise el estado actual de los proyectos...", icon: Icons.track_changes, buttonText: "VER PROYECTOS")),
                SizedBox(width: 20),
                Expanded(child: ActionCard(title: "Estadísticas", desc: "Analice el impacto académico y citas...", icon: Icons.auto_graph, buttonText: "VER REPORTES")),
              ],
            )
          else
            Column(
              children: const [
                ActionCard(title: "Cargar Trabajo", desc: "Sube nuevos documentos y tesis.", icon: Icons.upload_file, isPrimary: true, buttonText: "Empezar Ahora"),
                SizedBox(height: 15),
                ActionCard(title: "Seguimiento", desc: "Revisa el estado de tus envíos.", icon: Icons.track_changes, buttonText: "Ver Proyectos"),
                SizedBox(height: 15),
                ActionCard(title: "Estadísticas", desc: "Revisa el avance de tus proyecto.", icon: Icons.auto_graph_rounded, buttonText: "Estadísticas"),
              ],
            ),

          const SizedBox(height: 40),
          const Text("Proyectos Activos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildProjectItem("Optimización de Redes Neuronales", "75%", 0.75, Colors.blue),
          _buildProjectItem("Análisis de Ciclo de Vida", "40%", 0.40, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //SizedBox(height: 20),
        const Text("Hola, Dr. Jimbo", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(isWeb ? "Aquí tiene un resumen del progreso académico de hoy." : "Bienvenido de nuevo a su centro de investigación.", style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildProjectItem(String t, String p, double v, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: c.withOpacity(0.1), child: Icon(Icons.folder_open, color: c)),
          const SizedBox(width: 16),
          Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(p, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}