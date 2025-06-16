import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/contract_confirmation_controller.dart';
import 'package:guardiao_cliente/ui/add_creditcard_screen.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class ContractConfirmationScreen extends StatelessWidget {
  final ContractConfirmationController controller = Get.put(ContractConfirmationController());

  ContractConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;
    final verticalPadding = screenSize.height * 0.02;
    final borderColor = theme.dividerColor.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pagamento',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }
          final company = controller.company.value;
          final paymentMethodName = controller.paymentMethodName.value;

          if (company == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text('Carregando dados...', style: theme.textTheme.bodyMedium),
              ),
            );
          }

          final companyName = company.name ?? 'Convênio';
          final logoUrl = company.logoUrl ?? '';
          final monthlyValue = controller.monthlyValue.value;
          final chargeDate = controller.chargeDate.value;
          final monthlyValueFormatted = 'R\$ ${monthlyValue.toStringAsFixed(2)}';

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenSize.width * 0.05),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (logoUrl.isNotEmpty)
                                    ClipOval(
                                      child: Image(
                                        image: ProgressiveImage(logoUrl),
                                        width: screenSize.width * 0.2,
                                        height: screenSize.width * 0.2,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    CircleAvatar(
                                      radius: screenSize.width * 0.1,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      child: Icon(
                                        Icons.business,
                                        size: screenSize.width * 0.1,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  SizedBox(height: verticalPadding),
                                  Text(
                                    companyName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: verticalPadding),
                                  Divider(color: borderColor),
                                  SizedBox(height: verticalPadding / 2),
                                  _buildReceiptRow(theme, 'Valor Mensal', monthlyValueFormatted, highlight: true),
                                  SizedBox(height: verticalPadding / 2),
                                  _buildReceiptRow(theme, 'Data de Cobrança', chargeDate),
                                  SizedBox(height: verticalPadding / 2),
                                  Divider(color: borderColor),
                                  SizedBox(height: verticalPadding / 2),
                                  GestureDetector(
                                    onTap: () => controller.showPaymentSheet.value = true,
                                    child: _buildReceiptRow(
                                      theme,
                                      'Método de Pagamento',
                                      paymentMethodName == '---' ? 'Selecionar' : paymentMethodName,
                                      highlight: paymentMethodName != '---',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (paymentMethodName == 'PIX')
                              Padding(
                                padding: EdgeInsets.only(top: verticalPadding * 2),
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: screenSize.width * 0.4,
                                          height: screenSize.width * 0.4,
                                          alignment: Alignment.center,
                                          child: const CircularProgressIndicator(),
                                        ),
                                        Image.network(
                                          controller.urlQrCode.value,
                                          width: screenSize.width * 0.4,
                                          height: screenSize.width * 0.4,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return const SizedBox();
                                            }
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: verticalPadding),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            controller.pixCode.value,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            controller.copyPixRequested.value = true;
                                          },
                                          icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.showPaymentSheet.value)
                GestureDetector(
                  onTap: () => controller.showPaymentSheet.value = false,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      maxChildSize: 1.0,
                      minChildSize: 0.4,
                      builder: (context, scrollController) => _buildPaymentMethodSheet(context, theme, controller),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildReceiptRow(ThemeData theme, String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSheet(BuildContext context, ThemeData theme, ContractConfirmationController controller) {
    return Obx(() {
      final cards = controller.creditCards;

      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 **Título**
            Center(
              child: Text(
                'Selecione o Método de Pagamento',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 **Lista de Cartões + PIX**
            Expanded(
              child: ListView.separated(
                itemCount: cards.isEmpty ? 1 : cards.length + 1, // Se não houver cartões, exibe apenas o PIX
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index < cards.length) {
                    return _buildCreditCardItem(cards[index], theme, controller, context);
                  } else {
                    return _buildPixOption(theme, controller, context);
                  }
                },
              ),
            ),

            // 🔹 **Botão "Adicionar Cartão" (Aparece apenas se não houver cartões)**
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => CreditCardCreateScreen())?.then((_) => controller.loadCreditCards()),
                    icon: const Icon(Icons.add_card),
                    label: const Text("Adicionar Cartão"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// **🔹 Constrói um item de cartão de crédito**
  Widget _buildCreditCardItem(dynamic cardData, ThemeData theme, ContractConfirmationController controller, BuildContext context) {
    final brandType = cardData.brandType ?? 'Cartão';
    final lastDigits = cardData.lastFourDigits ?? '0000';
    final aliasCard = cardData.cardAliasName ?? '----';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: brandType == 'Visa'
            ? Image.asset(
          'assets/images/visa.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        )
            : Image.asset(
          'assets/images/master.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        aliasCard,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '**** **** **** $lastDigits',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onTap: () {
        controller.setPaymentMethod('$brandType *$lastDigits');
        controller.cardSelection.value = cardData;
        controller.createCreditTransaction(context);
      },
    );
  }

  /// **🔹 Constrói a opção PIX**
  Widget _buildPixOption(ThemeData theme, ContractConfirmationController controller, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(Icons.pix, color: theme.colorScheme.primary, size: 40),
      title: const Text(
        'PIX',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        controller.setPaymentMethod('PIX');
        await controller.createPixTransaction(context);
      },
    );
  }
}
