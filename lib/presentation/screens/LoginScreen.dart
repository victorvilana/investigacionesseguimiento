import 'package:flutter/material.dart';
import '../layouts/MainLayout.dart';
import '../controllers/LoginController.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 👉 1. Instanciamos el Controlador (El Cerebro)
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE NAVEGACIÓN Y ALERTAS ---
  Future<void> _ejecutarLogin() async {
    final error = await _controller.iniciarSesion();
    _procesarResultado(error);
  }

  Future<void> _ejecutarGoogleLogin() async {
    final error = await _controller.continuarConGoogle();
    if (error == 'Inicio de sesión cancelado') return; // Ignoramos si el usuario canceló
    _procesarResultado(error);
  }

  void _procesarResultado(String? error) {
    if (!mounted) return;

    if (error == null) {
      // ÉXITO: Navegamos al layout principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else if (error != "Formulario inválido") {
      // ERROR: Mostramos SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- CONSTRUCCIÓN PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    // 👉 2. Envolvemos la pantalla en un ListenableBuilder para que escuche al controlador
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F9),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWebLayout(constraints);
              } else {
                return _buildMobileLayout(constraints);
              }
            },
          ),
        );
      },
    );
  }

  // --- DISEÑO VERSIÓN WEB ---
  Widget _buildWebLayout(BoxConstraints constraints) {
    return Center(
      child: Container(
        width: 1050,
        height: 680,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1046C4),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), bottomLeft: Radius.circular(40)),
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=2070'),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(60),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 40),
                    SizedBox(height: 20),
                    Text("Seguimiento de investigaciones", style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, height: 1.1)),
                    SizedBox(height: 20),
                    Text("Centralice la gestión de las investigaciones en un solo lugar.", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(40), bottomRight: Radius.circular(40)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildLoginForm(isWeb: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DISEÑO VERSIÓN MÓVIL ---
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8F9FD), Colors.white]),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE8EAF6), child: Icon(Icons.menu_book_rounded, color: Color(0xFF1046C4), size: 30)),
              const SizedBox(height: 30),
              const Text("Seguimiento de investigaciones", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 15),
              const Text("Bienvenido de nuevo. Acceda a su panel de gestión académica.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 50),
              _buildLoginForm(isWeb: false),
              const SizedBox(height: 40),
              const Text("© 2024 SISTEMA DE SEGUIMIENTO DE INVESTIGACIONES", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  // --- FORMULARIO COMÚN ---
  Widget _buildLoginForm({required bool isWeb}) {
    return Form(
      key: _controller.formKey, // 👉 Conectado al controlador
      child: Column(
        crossAxisAlignment: isWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (isWeb) ...[
            const Text("Bienvenido", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Ingrese sus credenciales de investigador.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
          ],

          _label("EMAIL INSTITUCIONAL"),
          _inputField(Icons.email_outlined, "usuario@institucion.edu", _controller.emailController, false),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label("CONTRASEÑA"),
              if (!isWeb) TextButton(onPressed: () {}, child: const Text("¿Olvidó su contraseña?", style: TextStyle(fontSize: 12))),
            ],
          ),

          _inputField(Icons.lock_outline, "••••••••", _controller.passwordController, true),

          if (isWeb) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("¿Olvidó su contraseña?"))),
          const SizedBox(height: 30),

          // 👉 BOTÓN INICIAR SESIÓN CONECTADO AL CONTROLADOR
          ElevatedButton(
            onPressed: _controller.isLoading ? null : _ejecutarLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1046C4),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
              disabledBackgroundColor: const Color(0xFF1046C4).withOpacity(0.6),
            ),
            child: _controller.isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text("Iniciar Sesión", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 25),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("O CONTINUAR CON", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 25),

          // 👉 BOTÓN DE GOOGLE CONECTADO AL CONTROLADOR
          OutlinedButton.icon(
            onPressed: _controller.isLoading ? null : _ejecutarGoogleLogin,
            icon: _controller.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Image.network(
              'https://tinyurl.com/google-logo-png-web',
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red),
            ),
            label: Text(
              _controller.isLoading ? "Cargando..." : "Continuar con Google",
              style: const TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              shape: const StadiumBorder(),
              backgroundColor: isWeb ? Colors.transparent : const Color(0xFFF1F3F9),
              side: isWeb ? const BorderSide(color: Colors.black12) : BorderSide.none,
            ),
          ),
          const SizedBox(height: 30),

          Center(
            child: Text.rich(TextSpan(
              text: "¿Es nuevo en el sistema? ",
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(text: "Cree una cuenta académica", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1)));

  Widget _inputField(IconData icon, String hint, TextEditingController controller, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _controller.isObscure : false, // 👉 Conectado al controlador
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_controller.isObscure ? Icons.visibility : Icons.visibility_off, size: 20),
          onPressed: _controller.toggleObscure, // 👉 Llama a la función del controlador
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}