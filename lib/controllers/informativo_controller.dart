import 'dart:ui';

import 'package:get/get.dart';
import 'package:guardiao_cliente/models/informativo_model.dart';
import 'package:guardiao_cliente/repositories/informativo_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/informativo_detail_screen.dart';
import 'package:guardiao_cliente/ui/informativos_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class InformativoController extends GetxController {
  final InformativoRepository _repository = InformativoRepository();

  // Observáveis
  RxList<InformativoModel> informativos = <InformativoModel>[].obs;
  RxList<InformativoModel> informativosDestaque = <InformativoModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingDestaque = false.obs;
  RxString categoriaAtual = 'GERAL'.obs;

  @override
  void onInit() {
    super.onInit();
    carregarInformativos();
    carregarInformativosDestaque();
  }

  // Carregar informativos gerais
  Future<void> carregarInformativos({String? categoria}) async {
    try {
      isLoading.value = true;

      final result = await _repository.fetchInformativos(
        categoria: categoria,
        limit: 20,
      );

      informativos.value = result;
      if (categoria != null) {
        categoriaAtual.value = categoria;
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar informativos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Carregar informativos de destaque para o banner
  Future<void> carregarInformativosDestaque() async {
    try {
      isLoadingDestaque.value = true;

      final result = await _repository.fetchInformativosDestaque(limit: 5);
      informativosDestaque.value = result;
    } catch (e) {
      print('Erro ao carregar informativos de destaque: $e');
      // Não mostra erro para o usuário pois é um componente secundário
    } finally {
      isLoadingDestaque.value = false;
    }
  }

  // Filtrar por categoria
  Future<void> filtrarPorCategoria(String categoria) async {
    await carregarInformativos(categoria: categoria);
  }

  // Abrir informativo completo
  void abrirInformativo(InformativoModel informativo) {
    if (informativo.linkExterno != null && informativo.linkExterno!.isNotEmpty) {
      abrirLinkExterno(informativo.linkExterno!);
    } else {
      // Navegar para tela de detalhes
      Get.to(() => InformativoDetailScreen(informativo: informativo));
    }
  }

  // Abrir link externo
  Future<void> abrirLinkExterno(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarCustom.showError('Não foi possível abrir o link');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao abrir link: $e');
    }
  }

  // Atualizar dados
  Future<void> atualizarDados() async {
    await Future.wait([
      carregarInformativos(categoria: categoriaAtual.value != 'GERAL' ? categoriaAtual.value : null),
      carregarInformativosDestaque(),
    ]);
  }

  // Verificar se há informativos de destaque
  bool get temInformativosDestaque => informativosDestaque.isNotEmpty;

  // Formatar data para exibição
  String formatarData(DateTime data) {
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

  // Obter cor da categoria
  Color getCorCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'PMDF':
        return const Color(0xFF1976D2);
      case 'CBMDF':
        return const Color(0xFFD32F2F);
      case 'PCDF':
        return const Color(0xFF388E3C);
      case 'PF':
        return const Color(0xFF7B1FA2);
      case 'URGENTE':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF757575);
    }
  }

  // Navegar para tela de listagem completa
  void navegarParaListaCompleta() {
    Get.to(
          () => const InformativosListScreen(),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }
}