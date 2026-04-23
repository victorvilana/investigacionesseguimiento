import 'package:cloud_firestore/cloud_firestore.dart';

class InvestigacionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método exclusivo para guardar en la colección 'investigaciones'
  Future<void> guardarInvestigacion({
    required String codigo,
    required String titulo,
    required String detalle,
    required String empresa,
    required String universidad,
    required String nivelEducativo,
    required int icono,
    required double valor,
  }) async {
    try {
      DateTime ahora = DateTime.now();
      DateTime soloFecha = DateTime(ahora.year, ahora.month, ahora.day);

      // Toda la lógica de Firestore vive y muere aquí
      await _db.collection('investigaciones').doc(codigo).set({
        'titulo': titulo,
        'detalle': detalle,
        'empresacontratante': empresa,
        'universidad': universidad,
        'niveleducativo': nivelEducativo,
        'icono': icono,
        'valor': valor,
        'fechaRegistro': soloFecha,
      });
    } catch (e) {
      // Si hay error, lo lanzamos para que la pantalla lo atrape y muestre el mensaje
      throw Exception('No se pudo guardar la investigación: $e');
    }
  }

  // MÉTODO: Obtener lista en tiempo real
  Stream<QuerySnapshot> obtenerInvestigacionesStream() {
    return _db
        .collection('investigaciones')
        .orderBy('fechaRegistro', descending: true) // Los más recientes primero
        .snapshots();
  }

  // MÉTODO: Actualizar una investigación existente
  Future<void> actualizarInvestigacion({
    required String codigo,
    required String titulo,
    required String detalle,
    required String empresa,
    required String universidad,
    required String nivelEducativo,
    required int icono,
    required double valor,
  }) async {
    try {
      // Usamos .update() para no sobreescribir la fechaRegistro original
      await _db.collection('investigaciones').doc(codigo).update({
        'titulo': titulo,
        'detalle': detalle,
        'empresacontratante': empresa,
        'universidad': universidad,
        'niveleducativo': nivelEducativo,
        'icono': icono,
        'valor': valor,
      });
    } catch (e) {
      throw Exception('No se pudo actualizar la investigación: $e');
    }
  }

  // 👉 MÉTODO: Actualizar actividades
  Future<void> actualizarActividadesProyecto(String id, List<Map<String, dynamic>> actividades) async {
    try {
      await _db.collection('investigaciones').doc(id).update({
        'actividades': actividades,
        'ultimaModificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error en el servicio de datos: $e");
    }
  }

  // 👉 MÉTODO: Eliminar un proyecto por su ID
  Future<void> eliminarInvestigacion(String id) async {
    try {
      await _db.collection('investigaciones').doc(id).delete();
    } catch (e) {
      throw Exception("Error al eliminar desde Firebase: $e");
    }
  }

}


