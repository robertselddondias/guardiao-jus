import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/payment_gateway_transaction_model.dart';

class PaymentListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;
  RxList<PaymentGatewayTransactionModel> payments = <PaymentGatewayTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;

      final userId = FirebaseAuth.instance.currentUser!.uid; // Substitua pelo ID do usuário autenticado.
      final querySnapshot = await _firestore
          .collection('payment_gateway_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      payments.value = querySnapshot.docs.map((doc) => PaymentGatewayTransactionModel.fromMap(doc.data())).toList();
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar os pagamentos: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
