import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/payment_list_controller.dart';
import 'package:guardiao_cliente/models/payment_gateway_transaction_model.dart';
import 'package:intl/intl.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentListController controller = Get.put(PaymentListController());
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Define valores responsivos
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;
    final verticalSpacing = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Pagamentos',
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
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
          child: Column(
            children: [
              // Lista de Pagamentos
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.colorScheme.primary),
                    );
                  }

                  if (controller.payments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: screenWidth > 600 ? 100 : 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pagamento encontrado',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.payments.length,
                    itemBuilder: (context, index) {
                      PaymentGatewayTransactionModel payment = controller.payments[index];
                      final statusColor = payment.status == 'paid'
                          ? Colors.green
                          : theme.colorScheme.error;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 600 ? 24 : 16,
                            vertical: screenWidth > 600 ? 16 : 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Icon(Icons.payment, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            'Pagamento Mensalidade',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Data: ${DateFormat("dd/MM/yyyy").format(payment.createdAt!)}\nStatus: ${payment.status == 'paid' ? 'Pago' : 'Atrasado'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: Icon(Icons.circle, color: statusColor, size: 16),
                          // onTap: () {
                          //   Get.snackbar(
                          //     'Detalhes do Pagamento',
                          //     'Título: ${payment['title']}\nStatus: ${payment['status']}\nValor: R\$ ${payment['amount']}',
                          //     snackPosition: SnackPosition.BOTTOM,
                          //     backgroundColor: theme.colorScheme.surface,
                          //     colorText: theme.colorScheme.onSurface,
                          //   );
                          // },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
