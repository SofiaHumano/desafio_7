import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres.';
        case 'email-already-in-use':
          return 'Este email ya está registrado.';
        case 'invalid-email':
          return 'El formato del email no es válido.';
        case 'network-request-failed':
          return 'No hay conexión a internet.';
        default:
          return 'Error al registrarse: ${e.message}';
      }
    }
  }

  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email o contraseña incorrectos.';
        case 'invalid-email':
          return 'El formato del email no es válido.';
        case 'user-disabled':
          return 'Esta cuenta fue deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos. Probá de nuevo en unos minutos.';
        case 'network-request-failed':
          return 'No hay conexión a internet.';
        default:
          return 'Error al iniciar sesión.';
      }
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}