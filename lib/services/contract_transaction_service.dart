
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/payment_gateway_transaction_model.dart';
import 'package:guardiao_cliente/repositories/payment_gateway_transactions_repository.dart';

class ContractTransactionService {
  final PaymentGatewayTransactionsRepository _gatewayTransactionsRepository = PaymentGatewayTransactionsRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTransaction(String idTransactional, PaymentGatewayTransactionModel paymentGatewayTransactionModel) async {
    await _gatewayTransactionsRepository.updateTransaction(idTransactional, paymentGatewayTransactionModel);
    await _firestore.collection('users').doc(paymentGatewayTransactionModel.userId).set({
      'companyId': paymentGatewayTransactionModel.companyId,
      'contractId': paymentGatewayTransactionModel.contractId,
      'isPlanoAtivo': true
    }, SetOptions(merge: true));

  }


}