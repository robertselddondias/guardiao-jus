import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/rap_model.dart';

class RapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "raps";

  /// Listar todas as Raps para um usuário específico
  Future<List<RapModel>> fetchRapByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RapModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar Raps: $e");
    }
  }

  /// Buscar Rap por ID
  Future<RapModel> fetchById(String featureId) async {
    try {
      final docSnapshot = await _firestore
          .collection(collectionName)
          .doc(featureId)
          .get();
      return RapModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Erro ao buscar Rap por ID: $e");
    }
  }

  /// Criar nova Rap
  Future<void> createRap(RapModel feature) async {
    try {
      final docRef = _firestore.collection(collectionName).doc();
      feature.id = docRef.id;
      await docRef.set(feature.toMap());
    } catch (e) {
      throw Exception("Erro ao criar Rap: $e");
    }
  }

  /// Atualizar Rap existente
  Future<void> updateRap(String featureId, RapModel feature) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(featureId)
          .update(feature.toMap());
    } catch (e) {
      throw Exception("Erro ao atualizar Rap: $e");
    }
  }

  /// Deletar Rap
  Future<void> deleteRap(String featureId) async {
    try {
      await _firestore.collection(collectionName).doc(featureId).delete();
    } catch (e) {
      throw Exception("Erro ao deletar Rap: $e");
    }
  }

  /// Filtrar Raps por título
  Future<List<RapModel>> fetchRapByTitle(String userId, String title) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .get();

      return querySnapshot.docs
          .map((doc) => RapModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar Raps por título: $e");
    }
  }

  /// Filtrar Raps por data de ocorrência
  Future<List<RapModel>> fetchRapByOccurrenceDate(
      String userId, DateTime occurrenceDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('dtOcorrencia', isEqualTo: Timestamp.fromDate(occurrenceDate))
          .get();

      return querySnapshot.docs
          .map((doc) => RapModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar Raps por data de ocorrência: $e");
    }
  }
}