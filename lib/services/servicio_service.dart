import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/servicio.dart';

class ServicioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los servicios
  Future<List<Servicio>> getServicios() async {
    try {
      final snapshot = await _firestore.collection('servicios').get();
      return snapshot.docs
          .map((doc) => Servicio.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener servicios: $e');
      return [];
    }
  }

  // Obtener servicios por categoría
  Future<List<Servicio>> getServiciosByCategoria(String categoriaId) async {
    try {
      final snapshot = await _firestore
          .collection('servicios')
          .where('idCategoria', isEqualTo: categoriaId)
          .get();
      return snapshot.docs
          .map((doc) => Servicio.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener servicios por categoría: $e');
      return [];
    }
  }

  // Obtener servicios por proveedor
  Future<List<Servicio>> getServiciosByProveedor(String proveedorId) async {
    try {
      final snapshot = await _firestore
          .collection('servicios')
          .where('idProveedor', isEqualTo: proveedorId)
          .get();
      return snapshot.docs
          .map((doc) => Servicio.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener servicios por proveedor: $e');
      return [];
    }
  }

  // Obtener un servicio por ID
  Future<Servicio?> getServicioById(String servicioId) async {
    try {
      final doc = await _firestore.collection('servicios').doc(servicioId).get();
      if (!doc.exists) {
        return null;
      }
      return Servicio.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error al obtener servicio: $e');
      return null;
    }
  }
}
