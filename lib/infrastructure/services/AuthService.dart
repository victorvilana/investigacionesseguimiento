import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instancias de Firebase y Google Sign-In
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: '184596603012-8eolkkjrdu5envhk8vhvkffhsd92du06.apps.googleusercontent.com',
  );

  // ------------------------------------------------------------------
  // 1. INICIAR SESIÓN CON CORREO Y CONTRASEÑA
  // ------------------------------------------------------------------
  Future<String?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Null significa que no hubo errores (éxito)

    } on FirebaseAuthException catch (e) {
      // Traducimos los errores de Firebase a mensajes amigables
      if (e.code == 'user-not-found') {
        return 'No se encontró un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        return 'La contraseña es incorrecta.';
      } else if (e.code == 'invalid-email') {
        return 'El formato del correo es inválido.';
      } else if (e.code == 'invalid-credential') {
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      }
      return 'Ocurrió un error al iniciar sesión: ${e.message}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // ------------------------------------------------------------------
  // 2. INICIAR SESIÓN CON GOOGLE
  // ------------------------------------------------------------------
  Future<String?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de selección de cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si el usuario cierra la ventana emergente sin elegir cuenta
      if (googleUser == null) return 'Inicio de sesión cancelado';

      // Obtener los tokens de autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear la credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con esa credencial
      await _firebaseAuth.signInWithCredential(credential);

      return null; // Éxito

    } on FirebaseAuthException catch (e) {
      return e.message; // Error específico de Firebase
    } catch (e) {
      return 'Error al conectar con Google: $e'; // Error genérico
    }
  }

  // ------------------------------------------------------------------
  // 3. CERRAR SESIÓN
  // ------------------------------------------------------------------
  Future<void> logout() async {
    // Es una buena práctica cerrar también la sesión de Google
    // para que la próxima vez le vuelva a preguntar qué cuenta usar
    await _googleSignIn.signOut();

    // Cerramos la sesión principal de Firebase
    await _firebaseAuth.signOut();
  }
}