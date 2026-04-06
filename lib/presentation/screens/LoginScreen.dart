import 'package:flutter/material.dart';
import '../../infrastructure/services/AuthService.dart';
import '../layouts/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- VARIABLES DE ESTADO Y FIREBASE ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // --- LÓGICA DE INICIO DE SESIÓN ---
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String? error = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        // ÉXITO
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        // ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- LÓGICA DE GOOGLE ---
  Future<void> _continuarConGoogle() async {
    setState(() => _isLoading = true);

    final String? error = await _authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        // ÉXITO: Navegamos al Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else if (error != 'Inicio de sesión cancelado') {
        // ERROR: Mostramos SnackBar (solo si no fue una cancelación manual)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- CONSTRUCCIÓN PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho es mayor a 800, mostramos diseño Web, si no, Móvil
          if (constraints.maxWidth > 800) {
            return _buildWebLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
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
            // Banner Azul Izquierdo (Mantenido intacto)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1046C4),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      bottomLeft: Radius.circular(40)
                  ),
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
                    Text("Centralice su producción científica con precisión editorial y rigor analítico.", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),

            // Formulario Derecho
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FD), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.menu_book_rounded, color: Color(0xFF1046C4), size: 30),
              ),
              const SizedBox(height: 30),
              const Text("Seguimiento de investigaciones", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 15),
              const Text("Bienvenido de nuevo. Acceda a su panel de gestión académica.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 50),
              _buildLoginForm(isWeb: false), //
              const SizedBox(height: 40),
              const Text("© 2024 SISTEMA DE SEGUIMIENTO DE INVESTIGACIONES", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  // --- FORMULARIO COMÚN (AHORA CON LÓGICA) ---
  Widget _buildLoginForm({required bool isWeb}) {
    // Envolvemos tu Column en un Form para la validación
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: isWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (isWeb) ...[
            const Text("Bienvenido", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Ingrese sus credenciales de investigador.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
          ],

          _label("EMAIL INSTITUCIONAL"),
          _inputField(Icons.email_outlined, "usuario@institucion.edu", _emailController, false),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label("CONTRASEÑA"),
              if (!isWeb) TextButton(onPressed: () {}, child: const Text("¿Olvidó su contraseña?", style: TextStyle(fontSize: 12))),
            ],
          ),

          _inputField(Icons.lock_outline, "••••••••", _passwordController, true),

          if (isWeb) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("¿Olvidó su contraseña?"))),
          const SizedBox(height: 30),

          // BOTÓN INICIAR SESIÓN ACTUALIZADO
          ElevatedButton(
            onPressed: _isLoading ? null : _iniciarSesion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1046C4),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
              disabledBackgroundColor: const Color(0xFF1046C4).withOpacity(0.6),
            ),
            child: _isLoading
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

          OutlinedButton.icon(
            // Si está cargando, desactivamos el botón
            onPressed: _isLoading ? null : _continuarConGoogle,
            icon: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Image.network(
                'https://tinyurl.com/google-logo-png-web',
                height: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red)
            ),
            label: Text(
                _isLoading ? "Cargando..." : "Continuar con Google",
                style: const TextStyle(color: Colors.black87)
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

  // Hemos combinado tu inputField y passwordField en uno solo que usa TextFormField
  Widget _inputField(IconData icon, String hint, TextEditingController controller, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, size: 20), onPressed: () => setState(() => _isObscure = !_isObscure))
            : null,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FF), //
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}