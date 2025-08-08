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
    final TextEditingController searchController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: _buildModernAppBar(theme, controller),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(theme, controller),
                    const SizedBox(height: 16),
                    _buildSearchField(context, theme, searchController),
                    const SizedBox(height: 16),
                    _buildFilterSection(controller, theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildInformativosList(controller, theme),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme, InformativoController controller) {
    return AppBar(
      title: const Text('Informativos'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: theme.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
            onPressed: () => controller.atualizarDados(),
            tooltip: 'Atualizar',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, InformativoController controller) {
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
                Icons.campaign_rounded,
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
                    "Informativos Jurídicos",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.informativos.length} ${controller.informativos.length == 1 ? 'informativo disponível' : 'informativos disponíveis'}",
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

  Widget _buildSearchField(BuildContext context, ThemeData theme, TextEditingController searchController) {
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
          onChanged: (value) {
            // Implementar filtro de busca se necessário
          },
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'Buscar informativos...',
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
            suffixIcon: searchController.text.isNotEmpty
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
                  FocusScope.of(context).unfocus();
                },
              ),
            )
                : const SizedBox.shrink(),
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

  Widget _buildFilterSection(InformativoController controller, ThemeData theme) {
    final categorias = ['TODOS', 'PMDF', 'CBMDF', 'PCDF', 'PF', 'GERAL'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: Colors.orange[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Filtrar por categoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final categoriaFiltro = categoria == 'TODOS' ? null : categoria;
                          controller.filtrarPorCategoria(categoriaFiltro ?? 'GERAL');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            categoria,
                            style: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
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

  Widget _buildInformativosList(InformativoController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(child: _buildLoadingState(theme));
      }

      if (controller.informativos.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState(theme, controller));
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final informativo = controller.informativos[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildModernInformativoCard(informativo, controller, theme),
                  ),
                );
              },
            );
          },
          childCount: controller.informativos.length,
        ),
      );
    });
  }

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _handleInformativoTap(informativo, controller),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) _buildImageSection(informativo, controller, theme),
              Padding(
                padding: EdgeInsets.all(hasImage ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardHeader(informativo, controller, theme, hasImage),
                    const SizedBox(height: 16),
                    _buildTitle(informativo, theme),
                    const SizedBox(height: 12),
                    _buildContent(informativo, theme),
                    const SizedBox(height: 16),
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

  Widget _buildImageSection(InformativoModel informativo, InformativoController controller, ThemeData theme) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              informativo.imagemUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[200]!, Colors.grey[100]!],
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
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
                        controller.getCorCategoria(informativo.categoria).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Imagem não disponível',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildCategoryBadge(informativo, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(InformativoModel informativo, InformativoController controller) {
    final isUrgent = informativo.categoria.toUpperCase() == 'URGENTE';
    final color = controller.getCorCategoria(informativo.categoria);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [Colors.red[400]!, Colors.red[600]!]
              : [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? Colors.red : color).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUrgent) ...[
            const Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            informativo.categoria.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(InformativoModel informativo, InformativoController controller, ThemeData theme, bool hasImage) {
    return Row(
      children: [
        if (!hasImage) _buildCategoryBadge(informativo, controller),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatarData(informativo.dataPublicacao),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(InformativoModel informativo, ThemeData theme) {
    return Text(
      informativo.titulo,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContent(InformativoModel informativo, ThemeData theme) {
    return Text(
      informativo.conteudo,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCardFooter(InformativoModel informativo, ThemeData theme) {
    return Row(
      children: [
        if (informativo.tags != null && informativo.tags!.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: informativo.tags!.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ] else ...[
          const Spacer(),
        ],
        if (informativo.linkExterno != null && informativo.linkExterno!.isNotEmpty) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Link externo',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando informativos...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde enquanto buscamos as informações mais recentes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, InformativoController controller) {
    return Container(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum informativo encontrado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Não há informativos disponíveis para\na categoria selecionada no momento.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => controller.atualizarDados(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Tentar novamente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleInformativoTap(InformativoModel informativo, InformativoController controller) {
    if (informativo.linkExterno != null && informativo.linkExterno!.isNotEmpty) {
      controller.abrirLinkExterno(informativo.linkExterno!);
    } else {
      _navegarParaDetalhes(informativo);
    }
  }

  void _navegarParaDetalhes(InformativoModel informativo) {
    Get.to(
          () => InformativoDetailScreen(informativo: informativo),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

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