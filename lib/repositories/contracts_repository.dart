import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/contract_transaction_model.dart';

class ContractsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coleção padrão
  CollectionReference get _collection => _firestore.collection('contracts');

  /// Adiciona um novo contrato no Firestore e retorna o ID gerado.
  Future<String> addContract(ContractTransactionModel contract) async {
    final docRef = _collection.doc();
    contract.id = docRef.id;
    await docRef.set(contract.toMap());
    return docRef.id;
  }

  /// Obtém um contrato pelo seu ID de documento
  Future<ContractTransactionModel?> getContractById(String docId) async {
    final doc = await _collection.doc(docId).get();
    if (doc.exists) {
      return ContractTransactionModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Retorna todos os contratos de um determinado usuário (userId)
  Future<List<ContractTransactionModel>> getContractsByUserId(String userId) async {
    final query = await _collection.where('userId', isEqualTo: userId).get();
    return query.docs.map((doc) {
      return ContractTransactionModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Retorna todos os contratos de uma determinada empresa (companyId)
  Future<List<ContractTransactionModel>> getContractsByCompanyId(String companyId) async {
    final query = await _collection.where('companyId', isEqualTo: companyId).get();
    return query.docs.map((doc) {
      return ContractTransactionModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Atualiza um contrato existente
  Future<void> updateContract(String docId, ContractTransactionModel contract) async {
    await _collection.doc(docId).update(contract.toMap());
  }

  /// Deleta um contrato pelo ID
  Future<void> deleteContract(String docId) async {
    await _collection.doc(docId).delete();
  }
}
