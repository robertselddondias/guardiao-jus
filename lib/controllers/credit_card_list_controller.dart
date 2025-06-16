import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/credit_card_model.dart';
import 'package:guardiao_cliente/services/pagarme_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class CreditCardListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de cartões observável
  RxList<CreditCardUserModel> creditCards = <CreditCardUserModel>[].obs;

  // Estado de carregamento
  var isLoading = false.obs;

  // ID do cartão ou método padrão ("pix" caso PIX seja o padrão)
  RxString defaultCardId = ''.obs;

  @override
  void onInit() {
    fetchCreditCards();
    super.onInit();
  }

  // Método para buscar os cartões do Firestore
  Future<void> fetchCreditCards() async {
    try {
      isLoading.value = true;

      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('credit_cards')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<CreditCardUserModel> cards = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final card = CreditCardUserModel.fromJson(data);
        card.id = doc.id; // Seta o ID do documento no model
        return card;
      }).toList();

      creditCards.value = cards;

      // Atualiza o defaultCardId se houver um cartão padrão
      final defaultCard = cards.firstWhereOrNull((c) => c.isDefault == true);
      defaultCardId.value = defaultCard?.id ?? '';
    } catch (e) {
      SnackbarCustom.showError('Erro ao buscar cartões: $e');
      print('ERRO: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para remover um cartão
  Future<void> removeCreditCard(CreditCardUserModel card) async {
    try {
      isLoading.value = true;

      PagarMeService pagarService = PagarMeService();
      await pagarService.deleteCard(card);

      pagarService.deleteCard(card);

      await _firestore.collection('credit_cards').doc(card.id).delete();
      creditCards.removeWhere((c) => c.id == card.id);

      // Caso o cartão removido fosse o padrão, limpa o defaultCardId
      if (defaultCardId.value == card.id) {
        defaultCardId.value = '';
      }

      SnackbarCustom.showSuccess('Cartão removido com sucesso!');
      fetchCreditCards();
    } catch (e) {
      SnackbarCustom.showError('Erro ao remover cartão: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para definir um cartão como padrão
  Future<void> setDefaultCard(String cardId) async {
    try {
      isLoading.value = true;

      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      // Atualiza todos os cartões do usuário: o selecionado recebe isDefault = true, os outros false
      WriteBatch batch = _firestore.batch();

      final QuerySnapshot snapshot = await _firestore
          .collection('credit_cards')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        bool isSelected = doc.id == cardId;
        batch.update(doc.reference, {'isDefault': isSelected});
      }

      await batch.commit();

      // Atualiza o estado local
      defaultCardId.value = cardId;
      for (var c in creditCards) {
        c.isDefault = (c.id == cardId);
      }
      creditCards.refresh();

      SnackbarCustom.showSuccess('Cartão definido como padrão!');
    } catch (e) {
      SnackbarCustom.showError('Erro ao definir cartão padrão: $e');
      print('ERRO: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para definir o PIX como padrão
  void setDefaultPix() {
    try {
      isLoading.value = true;
      // Desmarca todos os cartões
      for (var c in creditCards) {
        c.isDefault = false;
      }
      creditCards.refresh();

      // Define 'pix' como método padrão
      defaultCardId.value = 'pix';

      SnackbarCustom.showSuccess('PIX definido como método padrão!');
    } catch (e) {
      SnackbarCustom.showError('Erro ao definir PIX como padrão: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
