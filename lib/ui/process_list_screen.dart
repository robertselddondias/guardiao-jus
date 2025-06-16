import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/process_list_controller.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/enums/pedido_type.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/ui/proc_administrativo_screen.dart';
import 'package:guardiao_cliente/ui/process_create_screen.dart';
import 'package:guardiao_cliente/ui/process_detail_screen.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class ProcessListScreen extends StatelessWidget {
  const ProcessListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProcessListController controller = Get.put(ProcessListController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Minhas Solicitações',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchProcessos();
          },
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingIndicator();
            }

            if (controller.processos.isEmpty) {
              return _buildEmptyState(theme);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.processos.length,
              itemBuilder: (context, index) {
                final ProcessoModel process = controller.processos[index];
                return _buildProcessCard(context, process, controller, theme);
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Get.to(() => const ProcessCreateScreen())?.then((_) =>
                controller.fetchProcessos()),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// **🔹 Construção do Card de Processo**
  Widget _buildProcessCard(BuildContext context, ProcessoModel process,
      ProcessListController controller, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (process.type == PedidoType.PROCESSO && !process.isNew) {
          Get.to(() => const ProcessDetailScreen(),
              arguments: {'processoId': process.id});
        } else {
          Get.to(() => const ProcAdministrativoScreen(),
              arguments: {'processoId': process.id});
        }
      },
      child: Dismissible(
        key: Key(process.id!),
        direction: DismissDirection.endToStart,
        background: Container(
          color: theme.colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: theme.colorScheme.onError, size: 28),
        ),
        confirmDismiss: (direction) async {
          return await _confirmDelete(context, controller, process.id!);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildProcessIcon(process, theme), // ✅ Ícone dinâmico
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **Número do Processo ou Título**
                    Text(
                      process.isNew
                          ? process.title!
                          : process.numeroProcesso!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // **Tipo de Processo**
                    Text(
                      process.isNew &&
                          process.type == PedidoType.PROCEDIMENTO_ADMINISTRATIVO
                          ? 'Procedimento Administrativo'
                          : process.isNew && process.type == PedidoType.PROCESSO
                          ? 'Novo Processo'
                          : 'Processo já Existente',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 4),

                    // **Data de Criação**
                    Text(
                      process.createAt.isNotEmpty
                          ? 'Data: ${DateUtilsCustom.formatDate(process.createAt)}'
                          : 'Data não informada',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 6),

                    // **Status do Processo**
                    _buildProcessStatus(process, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **🔹 Ícone Dinâmico do Processo com Cores Modernas**
  Widget _buildProcessIcon(ProcessoModel process, ThemeData theme) {
    // **Define o Ícone e a Cor baseados no tipo de processo**
    IconData iconData;
    Color iconColor;

    if (process.isNew && process.type == PedidoType.PROCEDIMENTO_ADMINISTRATIVO) {
      iconData = Icons.policy_outlined;
      iconColor = Colors.blue.shade700; // Azul vibrante e moderno
    } else if (process.isNew && process.type == PedidoType.PROCESSO) {
      iconData = Icons.account_balance_outlined;
      iconColor = Colors.teal.shade600; // Verde moderno e nítido
    } else {
      iconData = Icons.balance_outlined;
      iconColor = Colors.deepOrange.shade600; // Laranja forte e elegante
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: iconColor.withOpacity(0.15), // Fundo sutil e elegante
      child: Icon(
        iconData,
        color: iconColor, // Cor intensa e bem definida
        size: 30,
      ),
    );
  }

  /// **🔹 Exibição do Status do Processo**
  Widget _buildProcessStatus(ProcessoModel process, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: process.status.color.withOpacity(0.1) ??
            theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            process.status.icon ?? Icons.help_outline,
            size: 16,
            color: process.status.color ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            process.status.label,
            style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: process.status.color ?? theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  /// **🔹 Estado vazio (quando não há processos cadastrados)**
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'Nenhum processo encontrado',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// **🔹 Confirmação antes de excluir um processo**
  Future<bool> _confirmDelete(BuildContext context,
      ProcessListController controller, String processId) async {
    final theme = Theme.of(context);
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Excluir Processo", style: theme.textTheme.titleMedium),
          content: const Text(
              "Tem certeza de que deseja excluir este processo?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancelar",
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                controller.deleteProcess(processId);
                Get.back(result: true);
              },
              child: Text(
                  "Excluir", style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        );
      },
    ) ?? false;
  }
}