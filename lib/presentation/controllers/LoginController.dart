import 'package:flutter/material.dart';
import '../../infrastructure/services/AuthService.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Controladores de texto y estado del formulario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables de estado
  bool isObscure = true;
  bool isLoading = false;

  // Alternar la visibilidad de la contraseña
  void toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  // Lógica de inicio de sesión con correo y contraseña
  Future<String?> iniciarSesion() async {
    if (!formKey.currentState!.validate()) return "Formulario inválido";

    isLoading = true;
    notifyListeners(); // Avisamos a la UI que muestre el "Cargando..."

    final String? error = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    isLoading = false;
    notifyListeners(); // Avisamos a la UI que ya terminó de cargar

    return error; // Retorna null si fue un éxito, o el texto del error si falló
  }

  // Lógica de inicio de sesión con Google
  Future<String?> continuarConGoogle() async {
    isLoading = true;
    notifyListeners();

    final String? error = await _authService.signInWithGoogle();

    isLoading = false;
    notifyListeners();

    return error;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}