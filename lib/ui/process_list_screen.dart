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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await controller.fetchProcessos(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }

          if (controller.processos.isEmpty) {
            return _buildEmptyState(theme, size);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.processos.length,
            itemBuilder: (context, index) {
              final process = controller.processos[index];
              return _buildProcessCard(context, process, controller, theme, size);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ProcessCreateScreen())
            ?.then((_) => controller.fetchProcessos()),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProcessCard(BuildContext context, ProcessoModel process,
      ProcessListController controller, ThemeData theme, Size size) {

    final statusColor = process.status.color ?? theme.colorScheme.primary;
    final processIcon = _getProcessIcon(process);
    final processType = _getProcessTypeLabel(process);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(process.id!),
        direction: DismissDirection.endToStart,
        background: _buildDeleteBackground(theme),
        confirmDismiss: (direction) async {
          return await _confirmDelete(context, controller, process.id!);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToProcess(process),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Ícone do processo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        processIcon,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Informações do processo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título/Número do processo
                          Text(
                            process.isNew
                                ? (process.title ?? 'Processo sem título')
                                : (process.numeroProcesso ?? 'Número não informado'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Tipo do processo
                          Text(
                            processType,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Data de criação
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                process.createAt.isNotEmpty
                                    ? 'Criado em: ${DateUtilsCustom.formatDate(process.createAt)}'
                                    : 'Data não informada',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Status se houver
                          ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              process.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        ],
                      ),
                    ),

                    // Seta de navegação
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para criar uma nova solicitação',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Excluir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProcessIcon(ProcessoModel process) {
    if (process.isNew && process.type == PedidoType.PROCEDIMENTO_ADMINISTRATIVO) {
      return Icons.admin_panel_settings;
    } else if (process.isNew && process.type == PedidoType.PROCESSO) {
      return Icons.gavel;
    } else {
      return Icons.description;
    }
  }

  String _getProcessTypeLabel(ProcessoModel process) {
    if (process.isNew && process.type == PedidoType.PROCEDIMENTO_ADMINISTRATIVO) {
      return 'Procedimento Administrativo';
    } else if (process.isNew && process.type == PedidoType.PROCESSO) {
      return 'Novo Processo';
    } else {
      return 'Processo Existente';
    }
  }

  void _navigateToProcess(ProcessoModel process) {
    if (process.type == PedidoType.PROCESSO && !process.isNew) {
      Get.to(() => const ProcessDetailScreen(),
          arguments: {'processoId': process.id});
    } else {
      Get.to(() => const ProcAdministrativoScreen(),
          arguments: {'processoId': process.id});
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, ProcessListController controller, String processId) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Excluir Solicitação',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          content: Text(
            'Tem certeza de que deseja excluir esta solicitação?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                controller.deleteProcess(processId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
