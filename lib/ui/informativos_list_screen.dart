import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/informativo_controller.dart';
import 'package:guardiao_cliente/models/informativo_model.dart';
import 'package:guardiao_cliente/ui/informativo_detail_screen.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';

class InformativosListScreen extends StatelessWidget {
  const InformativosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InformativoController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(theme, controller, isTablet),
      body: Column(
        children: [
          _buildFilterSection(controller, theme, isTablet),
          Expanded(
            child: _buildInformativosList(controller, theme, isTablet),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, InformativoController controller, bool isTablet) {
    return AppBar(
      title: const Text(
        'Informativos',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.atualizarDados(),
          tooltip: 'Atualizar',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterSection(InformativoController controller, ThemeData theme, bool isTablet) {
    final categorias = ['TODOS', 'PMDF', 'CBMDF', 'PCDF', 'PF', 'GERAL'];

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por categoria:',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          SizedBox(
            height: isTablet ? 45 : 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return Obx(() {
                  final isSelected = categoria == 'TODOS'
                      ? controller.categoriaAtual.value == 'GERAL'
                      : controller.categoriaAtual.value == categoria;

                  return Container(
                    margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                    child: FilterChip(
                      label: Text(
                        categoria,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          final filtro = categoria == 'TODOS' ? 'GERAL' : categoria;
                          controller.filtrarPorCategoria(filtro);
                        }
                      },
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: Colors.grey[200],
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 4,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformativosList(InformativoController controller, ThemeData theme, bool isTablet) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(theme, isTablet);
      }

      if (controller.informativos.isEmpty) {
        return _buildEmptyState(theme, isTablet);
      }

      return RefreshIndicator(
        onRefresh: () => controller.atualizarDados(),
        child: ListView.builder(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          itemCount: controller.informativos.length,
          itemBuilder: (context, index) {
            final informativo = controller.informativos[index];
            return _buildInformativoCard(informativo, controller, theme, isTablet);
          },
        ),
      );
    });
  }

  Widget _buildInformativoCard(
      InformativoModel informativo,
      InformativoController controller,
      ThemeData theme,
      bool isTablet,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navegarParaDetalhes(informativo),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com categoria e prioridade
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: controller.getCorCategoria(informativo.categoria).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        informativo.categoria,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          color: controller.getCorCategoria(informativo.categoria),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (informativo.prioridade == 1)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 4 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'URGENTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 10 : 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (informativo.linkExterno != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.open_in_new,
                          size: isTablet ? 18 : 16,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),

                SizedBox(height: isTablet ? 12 : 10),

                // Título
                Text(
                  informativo.titulo,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isTablet ? 10 : 8),

                // Conteúdo resumido
                Text(
                  informativo.conteudo,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Rodapé com informações
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isTablet ? 16 : 14,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      DateUtilsCustom.formatDateToBrazil(informativo.dataPublicacao),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (informativo.dataExpiracao != null) ...[
                      Icon(
                        Icons.schedule,
                        size: isTablet ? 16 : 14,
                        color: Colors.orange[600],
                      ),
                      SizedBox(width: isTablet ? 4 : 2),
                      Text(
                        'Até ${DateUtilsCustom.formatDateToBrazil(informativo.dataExpiracao!)}',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                // Tags se existirem
                if (informativo.tags != null && informativo.tags!.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 12 : 8),
                  Wrap(
                    spacing: isTablet ? 8 : 6,
                    runSpacing: isTablet ? 6 : 4,
                    children: informativo.tags!.take(3).map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Carregando informativos...',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              'Nenhum informativo encontrado',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Não há informativos disponíveis para a categoria selecionada no momento.',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),
            ElevatedButton.icon(
              onPressed: () => Get.find<InformativoController>().atualizarDados(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'Tentar novamente',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarParaDetalhes(InformativoModel informativo) {
    Get.to(
          () => InformativoDetailScreen(informativo: informativo),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }
}