import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/informativo_controller.dart';
import 'package:guardiao_cliente/models/informativo_model.dart';

class BannerInformativos extends StatefulWidget {
  const BannerInformativos({super.key});

  @override
  State<BannerInformativos> createState() => _BannerInformativosState();
}

class _BannerInformativosState extends State<BannerInformativos> {
  PageController? _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final controller = Get.isRegistered<InformativoController>()
          ? Get.find<InformativoController>()
          : null;

      if (controller != null &&
          controller.informativosDestaque.isNotEmpty &&
          _pageController != null &&
          _pageController!.hasClients &&
          mounted) {
        final nextPage = (_currentPage + 1) % controller.informativosDestaque.length;
        _pageController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _currentPage = nextPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o controller já existe, se não, cria um novo
    final InformativoController controller = Get.isRegistered<InformativoController>()
        ? Get.find<InformativoController>()
        : Get.put(InformativoController());
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoadingDestaque.value) {
        return _buildLoadingBanner(theme);
      }

      if (!controller.temInformativosDestaque) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 0, bottom: 16),
        child: Column(
          children: [
            // Container principal com gradiente sutil
            Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cabeçalho elegante
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informativos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Últimas atualizações',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botão "Ver todos" elegante
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.navegarParaListaCompleta(),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ver todos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Banner de informativos
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: controller.informativosDestaque.length,
                      itemBuilder: (context, index) {
                        final informativo = controller.informativosDestaque[index];
                        return _buildBannerCard(context, informativo, controller, theme);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

Widget _buildBannerCard(
    BuildContext context,
    InformativoModel informativo,
    InformativoController controller,
    ThemeData theme,
    ) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background da imagem ou cor padrão
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: informativo.imagemUrl != null
                  ? null
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  controller.getCorCategoria(informativo.categoria),
                  controller.getCorCategoria(informativo.categoria).withOpacity(0.8),
                ],
              ),
            ),
            child: informativo.imagemUrl != null
                ? Image.network(
              informativo.imagemUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
                : null,
          ),

          // Overlay gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Badge de categoria
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getCorCategoria(informativo.categoria),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                informativo.categoria,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Badge de prioridade (se alta prioridade)
          if (informativo.prioridade == 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'URGENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Conteúdo do banner
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    informativo.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    informativo.conteudo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatarData(informativo.dataPublicacao),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      if (informativo.linkExterno != null)
                        Icon(
                          Icons.open_in_new,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Overlay clicável
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.abrirInformativo(informativo),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLoadingBanner(ThemeData theme) {
  return Container(
    margin: const EdgeInsets.only(top: 16, bottom: 16),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            theme.colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: Colors.grey[500],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Carregando informativos...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
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
    return '${diferenca.inDays} dias atrás';
  } else {
    return '${data.day}/${data.month}/${data.year}';
  }
}