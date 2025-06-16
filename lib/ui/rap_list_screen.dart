import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/rap_list_controller.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/rap_model.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/ui/rap_screen.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class RapListScreen extends StatelessWidget {
  const RapListScreen({super.key});

  void _showFiltersDialog(BuildContext context, RapListController controller) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Filtrar por título',
                  controller: controller.titleFilterController,
                ),
                const SizedBox(height: 12),
                CustomWidgets.buildDateField(
                  context: context,
                  label: 'Filtrar por data',
                  controller: controller.dateFilterController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.cleanFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.filterList();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RapListController controller = Get.put(RapListController());
    final theme = Theme.of(context);



    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
          title: Text(
            'RAPs',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          centerTitle: true,
          elevation: 4
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await controller.fetchRaps(),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingIndicator();
            }

            if (controller.rapList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 100,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum RAP encontrado',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.rapList.length,
              itemBuilder: (context, index) {
                final RapModel rap = controller.rapList[index];

                final rapStatusColor = rap.status?.color ?? theme.colorScheme.primary;
                final rapStatusIcon = rap.status?.icon ?? Icons.description_outlined;

                return Dismissible(
                  key: Key(rap.id!),
                  direction: DismissDirection.endToStart, // 🔹 Apenas para esquerda (Excluir)
                  background: _buildDeleteBackground(theme),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmationDialog(context, controller, rap);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => RapScreen(), arguments: {'rapId': rap.id})?.then((_) => controller.fetchRaps());
                    },
                    child: Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 🔹 Ícone dentro de um fundo suave com cor do status
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: rapStatusColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(rapStatusIcon, color: rapStatusColor, size: 28),
                            ),
                            const SizedBox(width: 16),

                            // 🔹 Informações do RAP
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // **Título do RAP**
                                  Text(
                                    rap.title ?? 'Sem título',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // **Status com Badge estilizado**
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: rap.status?.color.withOpacity(0.1) ?? theme.colorScheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          rap.status?.icon ?? Icons.info_outline,
                                          size: 16,
                                          color: rap.status?.color ?? theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          rap.status?.label ?? 'Não enviado ao jurídico',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: rap.status?.color ?? theme.colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                      const SizedBox(width: 6),
                                      Text(
                                        rap.dtOcorrencia != null
                                            ? 'Ocorrência: ${DateUtilsCustom.formatDate(rap.dtOcorrencia!)}'
                                            : 'Data não informada',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 🔹 Ícone de navegação (seta)
                            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "filter",
            onPressed: () => _showFiltersDialog(context, controller),
            backgroundColor: theme.colorScheme.secondary,
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add",
            onPressed: () =>
                Get.to(() => const RapScreen())?.then((_) {
                  controller.fetchRaps();
                }),
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: theme.colorScheme.error,
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  /// **🔹 Exibe um diálogo de confirmação antes de excluir**
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, RapListController controller, RapModel rap) async {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Excluir RAP',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja excluir o RAP "${rap.title}"?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          actions: [
            // **Botão "Cancelar"**
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            // **Botão "Excluir"**
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                controller.removeRap(rap);
              },
              child: Text(
                'Excluir',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}