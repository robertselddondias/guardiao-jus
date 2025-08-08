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
    final screenSize = MediaQuery.of(context).size;
    final TextEditingController searchController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Minhas Solicitações'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: theme.colorScheme.primary,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary),
                onPressed: () => _showFilterDialog(context, controller),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(theme, controller),
                    const SizedBox(height: 16),
                    _buildSearchField(context, theme, controller, searchController),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: Obx(() {
                  if (controller.isLoading.value) {
                    return const SliverToBoxAdapter(child: LoadingIndicator());
                  }

                  // Usa a lista filtrada em vez da lista original
                  final processesToShow = controller.filteredProcessos;

                  if (processesToShow.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(theme, screenSize, controller.searchQuery.value.isNotEmpty),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final ProcessoModel process = processesToShow[index];
                        return _buildModernProcessCard(context, process, controller, theme);
                      },
                      childCount: processesToShow.length,
                    ),
                  );
                }),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        floatingActionButton: _buildModernFAB(context, controller, theme),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ProcessListController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suas Solicitações Jurídicas",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getResultsText(controller),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  String _getResultsText(ProcessListController controller) {
    final isSearching = controller.searchQuery.value.isNotEmpty;
    final filteredCount = controller.filteredProcessos.length;
    final totalCount = controller.processos.length;

    if (isSearching) {
      return "$filteredCount de $totalCount ${totalCount == 1 ? 'solicitação encontrada' : 'solicitações encontradas'}";
    } else {
      return "$totalCount ${totalCount == 1 ? 'solicitação encontrada' : 'solicitações encontradas'}";
    }
  }

  Widget _buildSearchField(BuildContext context, ThemeData theme, ProcessListController controller, TextEditingController searchController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.search,
          onChanged: (value) => controller.filterProcesses(value),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'Buscar por título, número do processo...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  searchController.clear();
                  controller.clearSearch();
                  FocusScope.of(context).unfocus();
                },
              ),
            )
                : const SizedBox.shrink()
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernProcessCard(BuildContext context, ProcessoModel process,
      ProcessListController controller, ThemeData theme) {
    final statusInfo = _getProcessTypeInfo(process);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(process.id!),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(theme),
        confirmDismiss: (direction) async {
          return await _confirmDelete(context, controller, process.id!);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToProcess(process),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusInfo['color'].withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildProcessIcon(statusInfo),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                process.isNew
                                    ? process.title!
                                    : process.numeroProcesso!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusInfo['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusInfo['label'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusInfo['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildProcessInfo(process, theme),
                    const SizedBox(height: 12),

                    _buildProcessStatus(process, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getProcessTypeInfo(ProcessoModel process) {
    if (process.isNew && process.type == PedidoType.PROCEDIMENTO_ADMINISTRATIVO) {
      return {
        'icon': Icons.policy_rounded,
        'color': Colors.blue[600],
        'label': 'Procedimento Administrativo',
        'bgColor': Colors.blue[50],
      };
    } else if (process.isNew && process.type == PedidoType.PROCESSO) {
      return {
        'icon': Icons.gavel_rounded,
        'color': Colors.green[600],
        'label': 'Novo Processo Judicial',
        'bgColor': Colors.green[50],
      };
    } else {
      return {
        'icon': Icons.account_balance_rounded,
        'color': Colors.orange[600],
        'label': 'Processo Existente',
        'bgColor': Colors.orange[50],
      };
    }
  }

  Widget _buildProcessIcon(Map<String, dynamic> statusInfo) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: statusInfo['bgColor'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        statusInfo['icon'],
        color: statusInfo['color'],
        size: 28,
      ),
    );
  }

  Widget _buildProcessInfo(ProcessoModel process, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Criado em: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            process.createAt.isNotEmpty
                ? DateUtilsCustom.formatDate(process.createAt)
                : 'Data não informada',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStatus(ProcessoModel process, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            process.status.color.withOpacity(0.1),
            process.status.color.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: process.status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: process.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              process.status.icon ?? Icons.help_outline_rounded,
              size: 16,
              color: process.status.color,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: process.status.color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                process.status.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: process.status.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Excluir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Size screenSize, bool isSearching) {
    return Container(
      height: screenSize.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching
                ? 'Nenhuma solicitação encontrada'
                : 'Nenhuma solicitação cadastrada',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Tente ajustar os termos da sua busca\nou limpe o filtro para ver todas as solicitações'
                : 'Crie sua primeira solicitação jurídica\ntocando no botão +',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!isSearching)
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const ProcessCreateScreen())?.then((_) =>
                  Get.find<ProcessListController>().fetchProcessos()),
              icon: Icon(Icons.add_rounded, size: 20),
              label: Text('Nova Solicitação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context, ProcessListController controller, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ProcessCreateScreen())?.then((_) =>
            controller.fetchProcessos()),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Nova Solicitação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
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

  void _showFilterDialog(BuildContext context, ProcessListController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Filtros de Busca',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Filtros Disponíveis',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A busca já filtra automaticamente por:\n• Título da solicitação\n• Número do processo\n• Tipo de processo\n• Status do processo\n• Nome do usuário\n• Descrição',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estatísticas',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total: ${controller.processos.length} | Exibindo: ${controller.filteredProcessos.length}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context,
      ProcessListController controller, String processId) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      size: 40,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Excluir Solicitação",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tem certeza de que deseja excluir esta solicitação? Esta ação não pode ser desfeita.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.deleteProcess(processId);
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Excluir",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }
}