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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
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
          child: RefreshIndicator(
            onRefresh: () async => await controller.fetchProcessos(),
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
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
                          final process = processesToShow[index];
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
        ),
        floatingActionButton: _buildModernFAB(context, controller, theme),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ProcessListController controller) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
              theme.colorScheme.primaryContainer.withOpacity(0.3),
              theme.colorScheme.primary.withOpacity(0.1),
            ]
                : [
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
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                color: theme.colorScheme.onPrimary,
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: TextField(
          controller: searchController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.search,
          onChanged: (value) => controller.filterProcesses(value),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar por título, número do processo...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  searchController.clear();
                  controller.filterProcesses('');
                  FocusScope.of(context).unfocus();
                },
              ),
            )
                : const SizedBox.shrink()),
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
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernProcessCard(BuildContext context, ProcessoModel process, ProcessListController controller, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = process.status.color;
    final statusIcon = process.status.icon ?? Icons.help_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(process.id!),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(theme),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context, process, theme);
        },
        onDismissed: (direction) => controller.deleteProcess(process.id!),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToProcess(process),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.08),
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
                        _buildProcessIcon(statusColor, statusIcon, theme),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                process.title ?? 'Solicitação sem título',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(process.type, theme).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getTypeColor(process.type, theme).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getTypeLabel(process.type),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _getTypeColor(process.type, theme),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          size: 16,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Informações do processo
                    _buildProcessInfo(process, theme),

                    const SizedBox(height: 12),

                    // Status
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

  Widget _buildProcessIcon(Color statusColor, IconData statusIcon, ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        statusIcon,
        color: statusColor,
        size: 26,
      ),
    );
  }

  Widget _buildProcessInfo(ProcessoModel process, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (process.numeroProcesso?.isNotEmpty == true) ...[
            Row(
              children: [
                Icon(
                  Icons.numbers_rounded,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Processo: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    process.numeroProcesso!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Criado em: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                process.createAt == null
                    ? 'Data não informada'
                    : DateUtilsCustom.formatDate(process.createAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStatus(ProcessoModel process, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: process.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: process.status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: process.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
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
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.error.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
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
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Tente ajustar os termos da sua busca\nou limpe o filtro para ver todas as solicitações'
                : 'Crie sua primeira solicitação jurídica\ntocando no botão +',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!isSearching)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const ProcessCreateScreen())?.then((_) =>
                    Get.find<ProcessListController>().fetchProcessos()),
                icon: Icon(Icons.add_rounded, size: 20),
                label: Text('Nova Solicitação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
        foregroundColor: theme.colorScheme.onPrimary,
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

  Future<bool?> _showDeleteConfirmation(BuildContext context, ProcessoModel process, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(isDark ? 0.5 : 0.15),
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
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.error.withOpacity(0.2),
                          theme.colorScheme.error.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      size: 40,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Excluir Solicitação",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tem certeza de que deseja excluir a solicitação "${process.title}"? Esta ação não pode ser desfeita.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
                            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.error,
                                theme.colorScheme.error.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Excluir",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(isDark ? 0.5 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
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
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Filtros de Busca',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Filtros Disponíveis',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A busca já filtra automaticamente por:\n• Título da solicitação\n• Número do processo\n• Tipo de processo\n• Status do processo\n• Nome do usuário\n• Descrição',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
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
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Total de ${controller.processos.length} solicitações encontradas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  // Função para obter a cor do tipo de processo
  Color _getTypeColor(PedidoType type, ThemeData theme) {
    switch (type) {
      case PedidoType.PROCESSO:
        return theme.colorScheme.tertiary;
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  // Função para obter o label do tipo de processo
  String _getTypeLabel(PedidoType type) {
    switch (type) {
      case PedidoType.PROCESSO:
        return 'Processo Judicial';
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return 'Proc. Administrativo';
      default:
        return 'Solicitação';
    }
  }
}