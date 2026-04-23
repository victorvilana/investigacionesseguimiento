import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Método para obtener empresas
  Future<List<String>> obtenerEmpresas() async {
    try {
      final snapshot = await _db.collection('empresas').get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data.containsKey('empresa')) {
          return (data['empresa'] as List<dynamic>).map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error al obtener empresas: $e");
      return [];
    }
  }

  // 👉 2. MÉTODO para obtener niveles educativos
  Future<List<String>> obtenerNivelesEducativos() async {
    try {
      // Apuntamos a la colección 'niveleducativo'
      final snapshot = await _db.collection('niveleducativo').get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        // Buscamos el arreglo que también se llama 'niveleducativo'
        if (data.containsKey('niveleducativo')) {
          return (data['niveleducativo'] as List<dynamic>).map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error al obtener niveles educativos: $e");
      return [];
    }
  }

  // 👉 3. MÉTODO para obtener universidades
  Future<List<String>> obtenerUniversidades() async {
    try {
      final snapshot = await _db.collection('universidades').get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        if (data.containsKey('universidades')) {
          // 1. Extraemos y convertimos la lista a Strings
          List<String> listaUniversidades = (data['universidades'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          // 👉 2. Ordenamos la lista alfabéticamente ignorando mayúsculas/minúsculas
          listaUniversidades.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          // 3. Devolvemos la lista ya ordenada
          return listaUniversidades;
        }
      }
      return [];
    } catch (e) {
      print("Error al obtener universidades: $e");
      return [];
    }
  }

// 👉 4.  MÉTODO: Obtener lista de actividades desde Firebase
  Future<List<String>> obtenerActividades() async {
    try {
      final snapshot = await _db.collection('actividades').get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        // OJO: Usamos 'Actividad' con A mayúscula porque así está en tu base de datos
        if (data.containsKey('Actividad')) {
          List<String> listaActividades = (data['Actividad'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          // Las ordenamos alfabéticamente
          listaActividades.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return listaActividades;
        }
      }
      return [];
    } catch (e) {
      print("Error al obtener actividades: $e");
      return [];
    }
  }

  // 👉 5 MÉTODO: Traer la lista de quincenas
  Future<List<String>> obtenerQuincenas() async {
    try {
      final snapshot = await _db.collection('quincena').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        // Nota: Leemos 'quicena' por cómo está escrito en tu Firebase
        final List<dynamic> lista = data['quicena'] ?? data['quincena'] ?? [];
        return lista.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      print("Error al obtener quincenas: $e");
      return [];
    }
  }

}


