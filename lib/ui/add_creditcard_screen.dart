import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/credit_card_controller.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class CreditCardCreateScreen extends StatelessWidget {
  const CreditCardCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditCardController controller = Get.put(CreditCardController());
    final theme = Theme.of(context);
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // 🔹 Fecha o teclado ao tocar fora
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Adicionar Cartão',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.colorScheme.primary,
            centerTitle: true,
            elevation: 4,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Texto informativo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Insira as informações do cartão para usá-lo em seus pagamentos.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // 🔹 Cartão Virtual
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.22,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.holderNameController.text.isEmpty
                                ? "NOME DO TITULAR"
                                : controller.holderNameController.text
                                .toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            controller.cardNumberController.text.isEmpty
                                ? "**** **** **** ****"
                                : controller.cardNumberController.text,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "VENC: ${controller.expirationDateController
                                    .text.isEmpty ? "MM/AA" : controller
                                    .expirationDateController.text}",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                "CVV: ***",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Campos do formulário
                    Material(
                      color: theme.cardColor,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome do Titular
                            CustomWidgets.buildTextField(
                              context: context,
                              label: 'Nome do Titular',
                              controller: controller.holderNameController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),

                            // Número do Cartão
                            CustomWidgets.buildTextFieldMask(
                              mask: controller.numCardMask,
                              context: context,
                              label: 'Número do Cartão',
                              controller: controller.cardNumberController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Data de Validade e Código de Segurança
                            Row(
                              children: [
                                Expanded(
                                  child: CustomWidgets.buildTextFieldMask(
                                    context: context,
                                    label: 'Validade (MM/AA)',
                                    controller: controller
                                        .expirationDateController,
                                    keyboardType: TextInputType.number,
                                    mask: controller.dataMask,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomWidgets.buildTextField(
                                    context: context,
                                    label: 'CVV',
                                    obscureText: true,
                                    controller: controller.cvvController,
                                    keyboardType: TextInputType.number,
                                    textCapitalization: TextCapitalization.none,
                                    maxLenght: 3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Nome para o Cartão
                            CustomWidgets.buildTextField(
                              context: context,
                              label: 'Apelido do Cartão',
                              controller: controller.aliasController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 16),
            // 🔹 Move o botão para cima
            width: double.infinity,
            // 🔹 Ocupa toda a largura da tela
            color: theme.colorScheme.surface,
            child: ElevatedButton(
              onPressed: () async {
                await controller.saveCreditCard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Salvar Cartão",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}