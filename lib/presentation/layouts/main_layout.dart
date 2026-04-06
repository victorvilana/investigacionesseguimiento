import 'package:flutter/material.dart';
import 'package:investigacionesseguimiento/presentation/screens/CargarTrabajoScreen.dart';
import '../../infrastructure/services/AuthService.dart';


import '../screens/DashboardScreen.dart';
import '../screens/LoginScreen.dart';
import '../screens/EstadisticasScreen.dart';
import '../screens/SeguimientoScreen.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;


  // 1. Instanciamos el servicio
  final AuthService _authService = AuthService();

  // 2. Creamos la función de cierre de sesión
  Future<void> _cerrarSesion() async {
    // Cerramos la sesión en Firebase
    await _authService.logout();

    // Si el widget sigue activo en pantalla, navegamos al Login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }


  final List<Widget> _pages = [
    const DashboardScreen(),
    const CargarTrabajoScreen(),
    const SeguimientoScreen(),
    const EstadisticasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      bottomNavigationBar: isWeb ? null : _buildBottomNav(),
      body: SafeArea(
        // 👇 AQUÍ ESTÁ LA MAGIA 👇
        child: SelectionArea(
          child: Row(
            children: [
              if (isWeb) _buildWebSidebar(),
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Container(
      width: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Investigación", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1046C4))),
          const SizedBox(height: 40),
          _sidebarItem(0, Icons.grid_view_rounded, "Panel Principal"),
          _sidebarItem(1, Icons.upload_file_rounded, "Cargar Trabajo"),
          _sidebarItem(2, Icons.track_changes_rounded, "Seguimiento"),
          _sidebarItem(3, Icons.auto_graph_rounded, "Estadísticas"),
          const Spacer(),
          _sidebarItem(-1, Icons.settings_outlined, "Ajustes"),
          _sidebarItem(-1, Icons.logout_rounded, "Cerrar Sesión", isExit: true),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, {bool isExit = false}) {
    bool active = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (isExit) {
          // Si es el botón de salir, llamamos a Firebase
          _cerrarSesion();
        } else if (index != -1) {
          // Si es otro botón, cambiamos de pantalla
          setState(() => _currentIndex = index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isExit ? Colors.red : (active ? const Color(0xFF1046C4) : Colors.grey)),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isExit ? Colors.red : (active ? const Color(0xFF1046C4) : Colors.grey), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: const Color(0xFF1046C4),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Cargar"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Seguimiento"),
        BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: "Estadísticas"),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Salir"),

      ],
    );
  }
}