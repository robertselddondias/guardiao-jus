import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:guardiao_cliente/models/informativo_model.dart';
import 'package:guardiao_cliente/controllers/informativo_controller.dart';

class InformativoDetailScreen extends StatelessWidget {
  final InformativoModel informativo;

  const InformativoDetailScreen({
    super.key,
    required this.informativo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<InformativoController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, controller, isTablet),
          SliverToBoxAdapter(
            child: _buildContent(theme, controller, context, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, InformativoController controller, bool isTablet) {
    final hasImage = informativo.imagemUrl != null;

    return SliverAppBar(
      expandedHeight: hasImage ? (isTablet ? 300 : 220) : (isTablet ? 140 : 100),
      floating: false,
      pinned: true,
      backgroundColor: controller.getCorCategoria(informativo.categoria),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (informativo.linkExterno != null)
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white, size: 22),
            onPressed: () => controller.abrirLinkExterno(informativo.linkExterno!),
            tooltip: 'Abrir link externo',
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background da imagem ou gradiente
            if (hasImage)
              Image.network(
                informativo.imagemUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
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
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.8),
                        strokeWidth: 2,
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
                  );
                },
              )
            else
              Container(
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
              ),

            // Overlay gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(hasImage ? 0.4 : 0.1),
                  ],
                ),
              ),
            ),

            // Badge de prioridade
            if (informativo.prioridade == 1)
              Positioned(
                top: isTablet ? 80 : 60,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 8 : 6
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'URGENTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 12,
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

  Widget _buildContent(ThemeData theme, InformativoController controller, BuildContext context, bool isTablet) {
    final horizontalPadding = isTablet ? 32.0 : 20.0;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 32 : 24),

            // Título principal
            Text(
              informativo.titulo,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                height: 1.3,
                fontSize: isTablet ? 28 : 24,
              ),
            ),

            SizedBox(height: isTablet ? 20 : 16),

            // Informações do cabeçalho
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  text: DateUtilsCustom.formatDateToBrazil(informativo.dataPublicacao),
                  isTablet: isTablet,
                ),
                _buildInfoChip(
                  icon: Icons.access_time,
                  text: _getTempoDecorrido(informativo.dataPublicacao),
                  isTablet: isTablet,
                ),
              ],
            ),

            // Data de expiração se existir
            if (informativo.dataExpiracao != null) ...[
              SizedBox(height: isTablet ? 16 : 12),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 12 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isTablet ? 18 : 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Válido até: ${DateUtilsCustom.formatDateToBrazil(informativo.dataExpiracao!)}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: isTablet ? 32 : 24),

            // Conteúdo principal
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 28 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                informativo.conteudo,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.grey[800],
                ),
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Tags se existirem
            if (informativo.tags != null && informativo.tags!.isNotEmpty) ...[
              Text(
                'Palavras-chave:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Wrap(
                spacing: isTablet ? 12 : 8,
                runSpacing: isTablet ? 12 : 8,
                children: informativo.tags!.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6
                    ),
                    decoration: BoxDecoration(
                      color: controller.getCorCategoria(informativo.categoria).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.getCorCategoria(informativo.categoria).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: controller.getCorCategoria(informativo.categoria),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: isTablet ? 24 : 20),
            ],

            // Botões de ação
            _buildActionButtons(controller, isTablet),

            SizedBox(height: isTablet ? 60 : 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 10,
          vertical: isTablet ? 8 : 6
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? 16 : 14,
            color: Colors.grey[600],
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(InformativoController controller, bool isTablet) {
    return Column(
      children: [
        // Botão de link externo se houver
        if (informativo.linkExterno != null)
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton.icon(
              onPressed: () => controller.abrirLinkExterno(informativo.linkExterno!),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.getCorCategoria(informativo.categoria),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: Text(
                'Ver mais detalhes',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        if (informativo.linkExterno != null) SizedBox(height: isTablet ? 16 : 12),

        // Botão de compartilhar
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 48,
          child: OutlinedButton.icon(
            onPressed: () => _compartilhar(),
            style: OutlinedButton.styleFrom(
              foregroundColor: controller.getCorCategoria(informativo.categoria),
              side: BorderSide(
                color: controller.getCorCategoria(informativo.categoria),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.share),
            label: Text(
              'Compartilhar informativo',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTempoDecorrido(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 60) {
      return '${diferenca.inMinutes}min atrás';
    } else if (diferenca.inHours < 24) {
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return '${(diferenca.inDays / 7).floor()}sem atrás';
    }
  }

  void _compartilhar() {
    try {
      final texto = '''
📢 ${informativo.titulo}

${informativo.conteudo}

${informativo.linkExterno != null ? '\n🔗 ${informativo.linkExterno}' : ''}

📅 ${DateUtilsCustom.formatDateToBrazil(informativo.dataPublicacao)}

Compartilhado via Guardião Jus
      '''.trim();

      Share.share(
        texto,
        subject: informativo.titulo,
      );

      // Feedback háptico
      HapticFeedback.lightImpact();

    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível compartilhar o informativo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}