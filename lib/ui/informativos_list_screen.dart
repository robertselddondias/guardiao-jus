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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(theme, controller),
      body: Column(
        children: [
          _buildFilterSection(controller, theme),
          Expanded(
            child: _buildInformativosList(controller, theme),
          ),
        ],
      ),
    );
  }

  /// AppBar moderna e limpa
  PreferredSizeWidget _buildModernAppBar(ThemeData theme, InformativoController controller) {
    return AppBar(
      title: const Text(
        'Informativos',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
          onPressed: () => controller.atualizarDados(),
          tooltip: 'Atualizar',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Seção de filtros moderna
  Widget _buildFilterSection(InformativoController controller, ThemeData theme) {
    final categorias = ['TODOS', 'PMDF', 'CBMDF', 'PCDF', 'PF', 'GERAL'];

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por categoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
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
                    margin: EdgeInsets.only(right: index == categorias.length - 1 ? 0 : 12),
                    child: FilterChip(
                      label: Text(categoria),
                      selected: isSelected,
                      onSelected: (selected) {
                        final categoriaFiltro = categoria == 'TODOS' ? null : categoria;
                        controller.filtrarPorCategoria(categoriaFiltro ?? 'GERAL');
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.transparent,
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  /// Lista de informativos moderna
  Widget _buildInformativosList(InformativoController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(theme);
      }

      if (controller.informativos.isEmpty) {
        return _buildEmptyState(theme, controller);
      }

      return RefreshIndicator(
        onRefresh: () => controller.atualizarDados(),
        color: theme.colorScheme.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.informativos.length,
          itemBuilder: (context, index) {
            final informativo = controller.informativos[index];
            return _buildModernInformativoCard(informativo, controller, theme);
          },
        ),
      );
    });
  }

  /// Card moderno do informativo
  Widget _buildModernInformativoCard(
      InformativoModel informativo,
      InformativoController controller,
      ThemeData theme,
      ) {
    final hasImage = informativo.imagemUrl != null && informativo.imagemUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleInformativoTap(informativo, controller),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem (se houver)
              if (hasImage) _buildImageSection(informativo, controller, theme),

              // Conteúdo do card
              Padding(
                padding: EdgeInsets.all(hasImage ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com categoria e data
                    _buildCardHeader(informativo, controller, theme),

                    const SizedBox(height: 12),

                    // Título
                    _buildTitle(informativo, theme),

                    const SizedBox(height: 8),

                    // Conteúdo
                    _buildContent(informativo, theme),

                    const SizedBox(height: 16),

                    // Footer com informações extras
                    _buildCardFooter(informativo, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seção da imagem
  Widget _buildImageSection(InformativoModel informativo, InformativoController controller, ThemeData theme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem
            Image.network(
              informativo.imagemUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        controller.getCorCategoria(informativo.categoria),
                        controller.getCorCategoria(informativo.categoria).withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Imagem não disponível',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            // Badge de categoria no canto superior
            Positioned(
              top: 12,
              right: 12,
              child: _buildCategoryBadge(informativo, controller),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge de categoria
  Widget _buildCategoryBadge(InformativoModel informativo, InformativoController controller) {
    final isUrgent = informativo.categoria.toUpperCase() == 'URGENTE';
    final color = controller.getCorCategoria(informativo.categoria);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red : color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? Colors.red : color).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUrgent) ...[
            const Icon(
              Icons.priority_high,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            informativo.categoria.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Header do card
  Widget _buildCardHeader(InformativoModel informativo, InformativoController controller, ThemeData theme) {
    final hasImage = informativo.imagemUrl != null && informativo.imagemUrl!.isNotEmpty;

    return Row(
      children: [
        // Badge de categoria (só mostra se não há imagem)
        if (!hasImage) _buildCategoryBadge(informativo, controller),

        const Spacer(),

        // Data
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _formatarData(informativo.dataPublicacao),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Título do informativo
  Widget _buildTitle(InformativoModel informativo, ThemeData theme) {
    return Text(
      informativo.titulo,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Conteúdo do informativo
  Widget _buildContent(InformativoModel informativo, ThemeData theme) {
    return Text(
      informativo.conteudo,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Footer do card
  Widget _buildCardFooter(InformativoModel informativo, ThemeData theme) {
    return Row(
      children: [
        // Tags (se existirem)
        if (informativo.tags != null && informativo.tags!.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: informativo.tags!.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ] else ...[
          const Spacer(),
        ],

        // Ícone de link externo
        if (informativo.linkExterno != null && informativo.linkExterno!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Link externo',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Estado de loading
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carregando informativos...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState(ThemeData theme, InformativoController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum informativo encontrado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Não há informativos disponíveis para a categoria selecionada no momento.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => controller.atualizarDados(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Tentar novamente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lidar com toque no informativo
  void _handleInformativoTap(InformativoModel informativo, InformativoController controller) {
    if (informativo.linkExterno != null && informativo.linkExterno!.isNotEmpty) {
      // Se tem link externo, abre o link
      controller.abrirLinkExterno(informativo.linkExterno!);
    } else {
      // Se não tem link externo, vai para detalhes
      _navegarParaDetalhes(informativo);
    }
  }

  /// Navegar para detalhes
  void _navegarParaDetalhes(InformativoModel informativo) {
    Get.to(
          () => InformativoDetailScreen(informativo: informativo),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Formatação de data
  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays == 0) {
      return 'Hoje';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return DateUtilsCustom.formatDateToBrazil(data);
    }
  }
}