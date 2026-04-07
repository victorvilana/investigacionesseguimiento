import 'package:flutter/material.dart';
import 'package:investigacionesseguimiento/presentation/screens/CargarTrabajoScreen.dart';
import '../../infrastructure/services/AuthService.dart';

import '../screens/DashboardScreen.dart';
import '../screens/ListadoProyectosScreen.dart';
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
  bool _mostrandoCargarTrabajo = false;
  Map<String, dynamic>? _proyectoAEditar;

  // 1. Instanciamos el servicio
  final AuthService _authService = AuthService();

  // 2. Creamos la función de cierre de sesión
  Future<void> _cerrarSesion() async {
    // Cerramos la sesión en Firebase
    await _authService.logout();

    // Redirigimos al LoginScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  //  Este método  controla qué pantalla se muestra
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen(); // Panel principal
      case 1:
        if (_mostrandoCargarTrabajo) {
          return CargarTrabajoScreen(
            proyectoAEditar: _proyectoAEditar, // 👉 Pasamos los datos al formulario
            onCancelar: () {
              setState(() {
                _mostrandoCargarTrabajo = false;
                _proyectoAEditar = null; // Limpiamos la variable al salir
              });
            },
          );
        } else {
          return ListadoProyectosScreen(
            onNuevoProyecto: () {
              setState(() {
                _proyectoAEditar = null; // Es un proyecto nuevo, pasamos null
                _mostrandoCargarTrabajo = true;
              });
            },
            onEditarProyecto: (proyecto) { // 👉 NUEVA FUNCIÓN
              setState(() {
                _proyectoAEditar = proyecto; // Guardamos los datos del proyecto
                _mostrandoCargarTrabajo = true; // Abrimos el formulario
              });
            },
          );
        }

      case 2:
        return const SeguimientoScreen();
      case 3:
        return const EstadisticasScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      bottomNavigationBar: isWeb ? null : _buildBottomNav(),
      body: SafeArea(
        child: SelectionArea(
          child: Row(
            children: [
              if (isWeb) _buildWebSidebar(),

              // 👇 AQUÍ ESTABA EL ERROR: Reemplazamos la lista _pages por el método
              Expanded(child: _buildCurrentPage()),
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
          const Text(
            "Investigación",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1046C4),
            ),
          ),
          const SizedBox(height: 40),
          _sidebarItem(0, Icons.grid_view_rounded, "Panel Principal"),
          _sidebarItem(1, Icons.upload_file_rounded, "Listado"),
          _sidebarItem(2, Icons.track_changes_rounded, "Seguimiento"),
          _sidebarItem(3, Icons.auto_graph_rounded, "Estadísticas"),
          const Spacer(),
          _sidebarItem(-1, Icons.settings_outlined, "Ajustes"),
          _sidebarItem(-1, Icons.logout_rounded, "Cerrar Sesión", isExit: true),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    int index,
    IconData icon,
    String label, {
    bool isExit = false,
  }) {
    bool active = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (isExit) {
          // Si es el botón de salir, llamamos a Firebase
          _cerrarSesion();
        } else if (index != -1) {
          setState(() {
            _currentIndex = index;
            // Lógica para reiniciar el formulario de Cargar Trabajo
            if (index != 1) {
              _mostrandoCargarTrabajo = false;
            } else if (index == 1 && _mostrandoCargarTrabajo) {
              _mostrandoCargarTrabajo =
                  false; // Permite volver a la lista tocando "Listado" en el menú
            }
          });
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
            Icon(
              icon,
              color: isExit
                  ? Colors.red
                  : (active ? const Color(0xFF1046C4) : Colors.grey),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isExit
                    ? Colors.red
                    : (active ? const Color(0xFF1046C4) : Colors.grey),
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        if (i == 4) {
          // Índice 4 es el botón "Salir"
          _cerrarSesion();
        } else {
          setState(() {
            _currentIndex = i;
            // Lógica para reiniciar el formulario en el menú móvil
            if (i != 1) {
              _mostrandoCargarTrabajo = false;
            } else if (i == 1 && _mostrandoCargarTrabajo) {
              _mostrandoCargarTrabajo = false;
            }
          });
        }
      },
      selectedItemColor: const Color(0xFF1046C4),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Inicio"),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "Listado",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: "Seguimiento",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_graph),
          label: "Estadísticas",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Salir"),
      ],
    );
  }
}
