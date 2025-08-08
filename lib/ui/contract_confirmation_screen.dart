import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/contract_confirmation_controller.dart';
import 'package:guardiao_cliente/ui/add_creditcard_screen.dart';
import 'package:guardiao_cliente/utils/PagarMeValueUtils.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class ContractConfirmationScreen extends StatelessWidget {
  final ContractConfirmationController controller = Get.put(ContractConfirmationController());

  ContractConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.06;
    final verticalPadding = screenSize.height * 0.02;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Confirmação de Pagamento',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aguardando pagamento...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Processando sua transação',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final company = controller.company.value;
            final paymentMethodName = controller.paymentMethodName.value;

            if (company == null) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                      SizedBox(height: verticalPadding),
                      Text(
                        'Carregando dados...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final companyName = company.name ?? 'Convênio';
            final logoUrl = company.logoUrl ?? '';
            final monthlyValue = controller.monthlyValue.value;
            final chargeDate = controller.chargeDate.value;
            final monthlyValueFormatted = PagarMeValueUtils.centavosToDisplay(monthlyValue);

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding * 2,
                  ),
                  child: Column(
                    children: [
                      // Card principal modernizado
                      Container(
                        margin: EdgeInsets.only(top: verticalPadding),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header do card com logo
                            Container(
                              padding: EdgeInsets.all(screenSize.width * 0.06),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.03),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Logo da empresa com design mais moderno
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: logoUrl.isNotEmpty
                                        ? ClipOval(
                                      child: Image(
                                        image: ProgressiveImage(logoUrl),
                                        width: screenSize.width * 0.18,
                                        height: screenSize.width * 0.18,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : CircleAvatar(
                                      radius: screenSize.width * 0.09,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      child: Icon(
                                        Icons.business_outlined,
                                        size: screenSize.width * 0.08,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: verticalPadding),
                                  Text(
                                    companyName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Detalhes do pagamento
                            Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.06),
                              child: Column(
                                children: [
                                  _buildModernReceiptRow(
                                    theme,
                                    'Valor Mensal',
                                    monthlyValueFormatted,
                                    Icons.attach_money_outlined,
                                    highlight: true,
                                  ),
                                  SizedBox(height: verticalPadding),
                                  _buildModernReceiptRow(
                                    theme,
                                    'Data de Cobrança',
                                    chargeDate,
                                    Icons.calendar_today_outlined,
                                  ),
                                  SizedBox(height: verticalPadding),
                                  GestureDetector(
                                    onTap: () => controller.showPaymentSheet.value = true,
                                    child: _buildModernReceiptRow(
                                      theme,
                                      'Método de Pagamento',
                                      paymentMethodName == '---' ? 'Selecionar' : paymentMethodName,
                                      Icons.payment_outlined,
                                      highlight: paymentMethodName != '---',
                                      interactive: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // QR Code PIX modernizado
                      if (paymentMethodName == 'PIX')
                        Container(
                          margin: EdgeInsets.only(top: verticalPadding * 2),
                          padding: EdgeInsets.all(screenSize.width * 0.06),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pix,
                                    color: theme.colorScheme.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Código PIX',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: verticalPadding),

                              // QR Code com loading mais elegante
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: screenSize.width * 0.5,
                                      height: screenSize.width * 0.5,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary.withOpacity(0.3),
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    Image.network(
                                      controller.urlQrCode.value,
                                      width: screenSize.width * 0.5,
                                      height: screenSize.width * 0.5,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: screenSize.width * 0.5,
                                          height: screenSize.width * 0.5,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.error_outline,
                                            color: theme.colorScheme.error,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: verticalPadding),

                              // Código PIX com botão de copiar moderno
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.pixCode.value,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'monospace',
                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          controller.copyPixRequested.value = true;
                                        },
                                        icon: const Icon(
                                          Icons.copy_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: verticalPadding * 3),
                    ],
                  ),
                ),

                // Bottom sheet modernizado
                if (controller.showPaymentSheet.value)
                  GestureDetector(
                    onTap: () => controller.showPaymentSheet.value = false,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.45,
                        maxChildSize: 0.9,
                        minChildSize: 0.45,
                        builder: (context, scrollController) =>
                            _buildModernPaymentMethodSheet(context, theme, controller, scrollController),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildModernReceiptRow(
      ThemeData theme,
      String label,
      String value,
      IconData icon, {
        bool highlight = false,
        bool interactive = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                    color: highlight
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (interactive)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildModernPaymentMethodSheet(
      BuildContext context,
      ThemeData theme,
      ContractConfirmationController controller,
      ScrollController scrollController,
      ) {
    return Obx(() {
      final cards = controller.creditCards;

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle do bottom sheet
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Método de Pagamento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.showPaymentSheet.value = false,
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de métodos de pagamento
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // PIX sempre aparece primeiro
                  _buildModernPixOption(theme, controller, context),

                  if (cards.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Cartões Salvos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...cards.map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildModernCreditCardItem(card, theme, controller, context),
                    )),
                  ],

                  // Botão adicionar cartão
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Get.to(() => CreditCardCreateScreen())
                          ?.then((_) => controller.loadCreditCards()),
                      icon: Icon(
                        Icons.add_card_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Adicionar Novo Cartão',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildModernCreditCardItem(
      dynamic cardData,
      ThemeData theme,
      ContractConfirmationController controller,
      BuildContext context,
      ) {
    final brandType = cardData.brandType ?? 'Cartão';
    final lastDigits = cardData.lastFourDigits ?? '0000';
    final aliasCard = cardData.cardAliasName ?? '----';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: brandType == 'Visa'
              ? Image.asset(
            'assets/images/visa.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          )
              : Image.asset(
            'assets/images/mastercard.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          aliasCard,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '•••• •••• •••• $lastDigits',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          controller.setPaymentMethod(brandType);
          controller.cardSelection.value = cardData;
          controller.createCreditTransaction(context);
        },
      ),
    );
  }

  Widget _buildModernPixOption(
      ThemeData theme,
      ContractConfirmationController controller,
      BuildContext context,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pix,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          'PIX',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Pagamento instantâneo',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
        onTap: () async {
          controller.setPaymentMethod('PIX');
          await controller.createPixTransaction(context);
        },
      ),
    );
  }
}