import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';

class ProcessoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = "processos";

  /// **🔹 Criar um novo processo**
  Future<void> createProcesso(ProcessoModel processo) async {
    try {

      final docRef = _firestore.collection(_collectionName).doc();
      processo.id = docRef.id;
      await docRef.set(processo.toJson());
    } catch (e) {
      throw Exception("Erro ao criar processo: $e");
    }
  }

  /// **🔹 Buscar processo por ID**
  Future<ProcessoModel?> getProcessoById(String processoId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(processoId).get();
      if (doc.exists) {
        return ProcessoModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar processo: $e");
    }
  }

  /// **🔹 Buscar todos os processos do usuário logado (com ou sem companyId)**
  Stream<List<ProcessoModel>> getProcessosByUser() {
    try {
      String userId = Preferences.getString('userId');
      String companyId = Preferences.getString('companyId');

      return _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('companyId', isEqualTo: companyId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ProcessoModel.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Erro ao buscar processos: $e");
    }
  }

  /// **🔹 Atualizar processo**
  Future<void> updateProcesso(String processoId, ProcessoModel processo) async {
    try {
      await _firestore.collection(_collectionName).doc(processoId).update(processo.toJson());
    } catch (e) {
      throw Exception("Erro ao atualizar processo: $e");
    }
  }

  /// **🔹 Excluir processo**
  Future<void> deleteProcesso(String processoId) async {
    try {
      await _firestore.collection(_collectionName).doc(processoId).delete();
    } catch (e) {
      throw Exception("Erro ao excluir processo: $e");
    }
  }

  /// **🔹 Buscar processo por número**
  Future<ProcessoModel?> getProcessoByNumero(String numeroProcesso) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_collectionName)
          .where('numeroProcesso', isEqualTo: numeroProcesso)
          .where('userId', isEqualTo: Preferences.getString('userId'))
          .get();
      if (query.docs.isNotEmpty) {
        return ProcessoModel.fromJson(query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar processo por número: $e");
    }
  }
}