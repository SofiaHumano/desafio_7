import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TareasService {
  final CollectionReference<Map<String, dynamic>> _coleccion =
  FirebaseFirestore.instance.collection('tareas');

  Stream<QuerySnapshot<Map<String, dynamic>>> tareasDelUsuario(String uid) {
    return _coleccion.where('userId', isEqualTo: uid).snapshots();
  }

  Future<void> agregar(String titulo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _coleccion.add({
      'titulo': titulo,
      'completada': false,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
  }

  Future<void> actualizar(String docId, bool completada) async {
    await _coleccion.doc(docId).update({'completada': completada});
  }

  Future<void> eliminar(String docId) async {
    await _coleccion.doc(docId).delete();
  }
}