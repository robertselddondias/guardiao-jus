import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/informativo_model.dart';

class InformativoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = "informativo_noticias";

  // Buscar informativos ativos ordenados por prioridade e data
  Future<List<InformativoModel>> fetchInformativos({
    String? categoria,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(collectionName)
          .where('ativo', isEqualTo: true)
          .orderBy('prioridade', descending: false) // Prioridade 1 primeiro
          .orderBy('dataPublicacao', descending: true);

      // Filtrar por categoria se especificado
      if (categoria != null && categoria != 'GERAL') {
        query = query.where('categoria', isEqualTo: categoria);
      }

      final querySnapshot = await query.limit(limit).get();

      return querySnapshot.docs
          .map((doc) => InformativoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((informativo) => informativo.isValido) // Filtrar expirados
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar informativos: $e");
    }
  }

  // Buscar informativo por ID
  Future<InformativoModel?> fetchInformativoById(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();

      if (doc.exists) {
        return InformativoModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar informativo: $e");
    }
  }

  // Buscar informativos por categoria específica
  Future<List<InformativoModel>> fetchInformativosByCategoria(String categoria) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('categoria', isEqualTo: categoria)
          .where('ativo', isEqualTo: true)
          .orderBy('prioridade', descending: false)
          .orderBy('dataPublicacao', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InformativoModel.fromMap(doc.data(), doc.id))
          .where((informativo) => informativo.isValido)
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar informativos por categoria: $e");
    }
  }

  // Buscar informativos de alta prioridade para banner
  Future<List<InformativoModel>> fetchInformativosDestaque({int limit = 3}) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('ativo', isEqualTo: true)
          .where('prioridade', isEqualTo: 1) // Apenas alta prioridade
          .orderBy('dataPublicacao', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => InformativoModel.fromMap(doc.data(), doc.id))
          .where((informativo) => informativo.isValido)
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar informativos de destaque: $e");
    }
  }

  // Buscar informativos recentes (últimos 7 dias)
  Future<List<InformativoModel>> fetchInformativosRecentes() async {
    try {
      final setesDiasAtras = DateTime.now().subtract(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('ativo', isEqualTo: true)
          .where('dataPublicacao', isGreaterThanOrEqualTo: setesDiasAtras.toIso8601String())
          .orderBy('dataPublicacao', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InformativoModel.fromMap(doc.data(), doc.id))
          .where((informativo) => informativo.isValido)
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar informativos recentes: $e");
    }
  }

  // Adicionar informativo (para admin)
  Future<String> adicionarInformativo(InformativoModel informativo) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(informativo.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception("Erro ao adicionar informativo: $e");
    }
  }

  // Atualizar informativo (para admin)
  Future<void> atualizarInformativo(InformativoModel informativo) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(informativo.id)
          .update(informativo.toMap());
    } catch (e) {
      throw Exception("Erro ao atualizar informativo: $e");
    }
  }

  // Deletar informativo (para admin)
  Future<void> deletarInformativo(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      throw Exception("Erro ao deletar informativo: $e");
    }
  }

  // Stream para atualizações em tempo real
  Stream<List<InformativoModel>> streamInformativos({String? categoria}) {
    Query query = _firestore
        .collection(collectionName)
        .where('ativo', isEqualTo: true)
        .orderBy('prioridade', descending: false)
        .orderBy('dataPublicacao', descending: true);

    if (categoria != null && categoria != 'GERAL') {
      query = query.where('categoria', isEqualTo: categoria);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InformativoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((informativo) => informativo.isValido)
          .toList();
    });
  }
}