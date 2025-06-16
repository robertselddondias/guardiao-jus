import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/credit_card_list_controller.dart';
import 'package:guardiao_cliente/models/credit_card_model.dart';
import 'package:guardiao_cliente/ui/add_creditcard_screen.dart';

class CreditCardListScreen extends StatelessWidget {
  const CreditCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditCardListController controller = Get.put(CreditCardListController());
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Cartões',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchCreditCards();
          },
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            }

            if (controller.creditCards.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.1,
                  ),
                  child: _buildEmptyState(context, screenSize, theme),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              itemCount: controller.creditCards.length,
              itemBuilder: (context, index) {
                CreditCardUserModel card = controller.creditCards[index];
                bool isDefault = (controller.defaultCardId.value == card.id);
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isDefault ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        _buildCardLeading(card, theme),
                      ],
                    ),
                    title: Text(
                      card.cardAliasName ?? 'Cartão sem nome',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '**** ${card.lastFourDigits ?? '0000'} • ${card.brandType ?? 'Cartão'}\nVencimento: ${card.expirationDate ?? '--/--'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      onPressed: () => _showDeleteConfirmationDialog(context, controller, card),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: screenSize.height * 0.02),
        child: FloatingActionButton(
          onPressed: () => Get.to(() => const CreditCardCreateScreen())?.then((_) {
            controller.fetchCreditCards();
          }),
          backgroundColor: theme.colorScheme.primary,
          child: Icon(
            Icons.add,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Size screenSize, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.credit_card_off,
          size: screenSize.width * 0.25,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(height: 20),
        Text(
          'Nenhum cartão cadastrado.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Adicione um cartão para realizar pagamentos.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardLeading(CreditCardUserModel card, ThemeData theme) {
    if (card.brandType != null && card.brandType!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          card.brandType! == 'Visa' ? 'assets/images/visa.png' : 'assets/images/mastercard.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.credit_card, color: theme.colorScheme.primary),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, CreditCardListController controller, CreditCardUserModel creditCard) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Excluir Cartão',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja excluir este cartão de crédito?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.removeCreditCard(creditCard);
              },
              child: Text(
                'Excluir',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
