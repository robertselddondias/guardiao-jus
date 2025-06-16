import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/payment_gateway_transaction_model.dart';

class PaymentGatewayTransactionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coleção padrão para as transações do gateway
  CollectionReference get _collection => _firestore.collection('payment_gateway_transactions');

  /// Adiciona uma nova transação de pagamento e retorna o ID do documento gerado.
  Future<String> addTransaction(PaymentGatewayTransactionModel transaction) async {
    final docRef = _collection.doc();
    transaction.id = docRef.id;
    await docRef.set(transaction.toMap());
    return docRef.id;
  }

  /// Obtém uma transação pelo seu 'transactionId' (ID da transação no gateway)
  Future<PaymentGatewayTransactionModel?> getTransactionById(String transactionId) async {
    DocumentSnapshot query = await _collection.doc(transactionId).get();
    if (query.exists) {
      return PaymentGatewayTransactionModel.fromMap(query.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Retorna todas as transações de um determinado usuário (userId)
  Future<List<PaymentGatewayTransactionModel>> getTransactionsByUserId(String userId) async {
    final query = await _collection.where('userId', isEqualTo: userId).get();
    return query.docs.map((doc) {
      return PaymentGatewayTransactionModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Retorna todas as transações de uma determinada empresa (companyId)
  Future<List<PaymentGatewayTransactionModel>> getTransactionsByCompanyId(String companyId) async {
    final query = await _collection.where('companyId', isEqualTo: companyId).get();
    return query.docs.map((doc) {
      return PaymentGatewayTransactionModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Atualiza uma transação existente pelo ID do documento no Firestore.
  /// Geralmente você obterá o docId ao criar a transação ou ao listá-las.
  Future<void> updateTransaction(String docId, PaymentGatewayTransactionModel transaction) async {
    await _collection.doc(docId).update(transaction.toMap());
  }

  /// Deleta uma transação pelo ID do documento no Firestore.
  Future<void> deleteTransaction(String docId) async {
    await _collection.doc(docId).delete();
  }
}
