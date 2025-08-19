import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/company_details_controller.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/utils/PagarMeValueUtils.dart';
import 'package:open_filex/open_filex.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final CompanyDetailsController controller = Get.put(CompanyDetailsController());

  CompanyDetailsScreen({super.key, required CompanyModel company}) {
    controller.setCompany(company);
  }

  // Função para calcular o tamanho da fonte baseado no comprimento do texto e largura da tela
  double _calculateTitleFontSize(String text, double screenWidth) {
    // Largura disponível para o texto (considerando padding e margens)
    double availableWidth = screenWidth - 100; // 100px para margens e padding

    // Tamanho base da fonte
    double baseFontSize = 16.0;

    // Se o texto for muito longo, reduz a fonte
    if (text.length > 25) {
      baseFontSize = 12.0;
    } else if (text.length > 20) {
      baseFontSize = 13.0;
    } else if (text.length > 15) {
      baseFontSize = 14.0;
    } else if (text.length > 10) {
      baseFontSize = 15.0;
    }

    // Ajusta baseado na largura da tela
    if (screenWidth < 350) {
      baseFontSize = baseFontSize * 0.9;
    }

    return baseFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Obx(() => Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // App Bar moderno com efeito parallax
              SliverAppBar(
                expandedHeight: screenSize.height * 0.25,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.company.value.name ?? 'Detalhes da Empresa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _calculateTitleFontSize(controller.company.value.name ?? 'Detalhes da Empresa', screenSize.width),
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: _buildHeroLogo(theme, screenSize),
                    ),
                  ),
                ),
              ),

              // Conteúdo principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                    vertical: screenSize.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      // Card principal com informações
                      _buildMainInfoCard(theme, screenSize),

                      SizedBox(height: screenSize.height * 0.02),

                      // Card de detalhes
                      _buildDetailsCard(theme, screenSize),

                      // Benefícios se existirem
                      if (controller.company.value.beneficios != null &&
                          controller.company.value.beneficios!.isNotEmpty)
                        ...[
                          SizedBox(height: screenSize.height * 0.02),
                          _buildBenefitsCard(theme, screenSize),
                        ],

                      // Descrição se existir
                      if (controller.company.value.description != null &&
                          controller.company.value.description!.isNotEmpty)
                        ...[
                          SizedBox(height: screenSize.height * 0.02),
                          _buildDescriptionCard(theme, screenSize),
                        ],

                      // Botão de contrato se existir
                      if (controller.company.value.urlContract != null)
                        ...[
                          SizedBox(height: screenSize.height * 0.02),
                          _buildContractCard(context, theme, screenSize),
                        ],

                      // Espaço para o botão flutuante
                      SizedBox(height: screenSize.height * 0.12),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay elegante
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carregando...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      )),

      // Botão flutuante moderno
      floatingActionButton: Container(
        width: screenSize.width * 0.85,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => _showModernConfirmationDialog(context),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Contratar Serviço',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeroLogo(ThemeData theme, Size screenSize) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: screenSize.width * 0.12,
        backgroundColor: Colors.white,
        child: controller.company.value.logoUrl == null
            ? Icon(
          Icons.business_outlined,
          size: screenSize.width * 0.12,
          color: theme.colorScheme.primary,
        )
            : ClipOval(
          child: Image(
            image: ProgressiveImage(controller.company.value.logoUrl!),
            width: screenSize.width * 0.24,
            height: screenSize.width * 0.24,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(ThemeData theme, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícone de destaque
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.payments_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Label elegante
          Text(
            'Investimento Mensal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Valor em destaque
          if (controller.company.value.monthlyValue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Text(
                PagarMeValueUtils.centavosToDisplay(controller.company.value.monthlyValue!),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 32,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Valor a consultar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Informação adicional
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cobrança mensal recorrente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Informações',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildModernInfoRow(
            Icons.business_outlined,
            'CNPJ',
            controller.company.value.cnpj ?? 'Não informado',
            theme,
          ),
          _buildModernInfoRow(
            Icons.email_outlined,
            'E-mail',
            controller.company.value.email ?? 'Não informado',
            theme,
          ),
          _buildModernInfoRow(
            Icons.gavel_outlined,
            'OAB',
            controller.company.value.oab ?? 'Não informado',
            theme,
          ),
          if (controller.company.value.address != null)
            _buildModernInfoRow(
              Icons.location_on_outlined,
              'Endereço',
              controller.company.value.address!.street!,
              theme,
            ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(ThemeData theme, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Benefícios',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...controller.company.value.beneficios!.asMap().entries.map((entry) {
            final index = entry.key;
            final benefit = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: index < controller.company.value.beneficios!.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      benefit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ThemeData theme, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Descrição',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              controller.company.value.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, ThemeData theme, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.file_download_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Contrato',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final filePath = await controller.downloadContract();
                  if (filePath != null) {
                    OpenFilex.open(filePath);
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Baixar Contrato',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showModernConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    bool isChecked = false;

    // Definindo dimensões responsivas
    final dialogMaxWidth = isTablet ? 500.0 : screenSize.width * 0.9;
    final dialogMaxHeight = isLandscape ? screenSize.height * 0.9 : null;

    // Paddings responsivos
    final basePadding = isTablet ? 32.0 : 20.0;
    final smallPadding = isTablet ? 20.0 : 16.0;
    final largePadding = isTablet ? 40.0 : 24.0;

    // Tamanhos de fonte responsivos
    final headlineSize = isTablet ? 26.0 : 22.0;
    final bodySize = isTablet ? 16.0 : 14.0;
    final buttonHeight = isTablet ? 60.0 : 52.0;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: dialogMaxWidth,
                      maxHeight: dialogMaxHeight ?? screenSize.height * 0.95,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 16,
                      vertical: isLandscape ? 20 : 40,
                    ),
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: isTablet ? 40 : 32,
                              offset: Offset(0, isTablet ? 20 : 16),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              blurRadius: isTablet ? 24 : 20,
                              offset: Offset(0, isTablet ? 12 : 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                              spreadRadius: 0,
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🎯 Header responsivo com design glassmorphism
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(
                                      basePadding,
                                      largePadding,
                                      basePadding,
                                      smallPadding
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.08),
                                        theme.colorScheme.primary.withOpacity(0.03),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Ícone responsivo com efeito premium
                                      Container(
                                        padding: EdgeInsets.all(isTablet ? 24 : 18),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.4),
                                              blurRadius: isTablet ? 20 : 16,
                                              offset: Offset(0, isTablet ? 10 : 8),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, -2),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.verified_user_rounded,
                                          color: Colors.white,
                                          size: isTablet ? 40 : 32,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 24 : 20),

                                      // Título responsivo com tipografia refinada
                                      Text(
                                        'Confirmação de Contrato',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                          letterSpacing: -0.5,
                                          height: 1.2,
                                          fontSize: headlineSize,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: isTablet ? 16 : 12),

                                      // Subtítulo elegante
                                      Text(
                                        'Você está prestes a assinar um novo contrato',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                          fontSize: bodySize,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                // 🎯 Conteúdo principal responsivo
                                Padding(
                                  padding: EdgeInsets.all(basePadding),
                                  child: Column(
                                    children: [
                                      // Descrição em card elegante
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(smallPadding),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                          border: Border.all(
                                            color: theme.colorScheme.outline.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: theme.colorScheme.primary.withOpacity(0.8),
                                              size: isTablet ? 24 : 20,
                                            ),
                                            SizedBox(height: isTablet ? 16 : 12),
                                            Text(
                                              'Ao confirmar, você estará assinando o contrato com este escritório e concordando com os termos do aplicativo.',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                height: 1.6,
                                                fontWeight: FontWeight.w500,
                                                fontSize: bodySize,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 32 : 24),

                                      // 🎯 Valor mensal responsivo com design premium
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Primeiro objeto: Título
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: isTablet ? 24 : 20,
                                                vertical: isTablet ? 16 : 12
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.colorScheme.primary.withOpacity(0.08),
                                                  theme.colorScheme.primary.withOpacity(0.03),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                              border: Border.all(
                                                color: theme.colorScheme.primary.withOpacity(0.15),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                                  ),
                                                  child: Icon(
                                                    Icons.payments_rounded,
                                                    color: theme.colorScheme.primary,
                                                    size: isTablet ? 20 : 16,
                                                  ),
                                                ),
                                                SizedBox(width: isTablet ? 16 : 12),
                                                Text(
                                                  'Valor Mensal',
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.primary,
                                                    letterSpacing: 0.5,
                                                    fontSize: isTablet ? 16 : 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: isTablet ? 16 : 12),

                                          // Segundo objeto: Valor
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: isTablet ? 28 : 20,
                                                vertical: isTablet ? 20 : 16
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface,
                                              borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: isTablet ? 20 : 16,
                                                  offset: Offset(0, isTablet ? 8 : 6),
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: theme.colorScheme.outline.withOpacity(0.08),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: isTablet ? 4 : 3,
                                                  height: isTablet ? 32 : 24,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        theme.colorScheme.primary,
                                                        theme.colorScheme.secondary,
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                                SizedBox(width: isTablet ? 20 : 16),
                                                Flexible(
                                                  child: Text(
                                                    PagarMeValueUtils.centavosToDisplay(controller.company.value.monthlyValue!),
                                                    style: theme.textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: theme.colorScheme.primary,
                                                      fontSize: isTablet ? 32 : 24,
                                                      letterSpacing: -0.5,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isTablet ? 36 : 28),

                                      // 🎯 Checkbox responsivo de concordância
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isChecked = !isChecked;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? theme.colorScheme.primary.withOpacity(0.08)
                                                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                            border: Border.all(
                                              color: isChecked
                                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                                  : theme.colorScheme.outline.withOpacity(0.2),
                                              width: isChecked ? 2 : 1,
                                            ),
                                            boxShadow: isChecked ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary.withOpacity(0.15),
                                                blurRadius: isTablet ? 12 : 8,
                                                offset: Offset(0, isTablet ? 6 : 4),
                                              ),
                                            ] : null,
                                          ),
                                          child: Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: isTablet ? 28 : 24,
                                                height: isTablet ? 28 : 24,
                                                decoration: BoxDecoration(
                                                  color: isChecked
                                                      ? theme.colorScheme.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                                                  border: Border.all(
                                                    color: isChecked
                                                        ? theme.colorScheme.primary
                                                        : theme.colorScheme.outline.withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isChecked
                                                    ? Icon(
                                                  Icons.check_rounded,
                                                  size: isTablet ? 18 : 16,
                                                  color: Colors.white,
                                                )
                                                    : null,
                                              ),
                                              SizedBox(width: isTablet ? 20 : 16),
                                              Expanded(
                                                child: Text(
                                                  'Li e concordo com o contrato e os termos do aplicativo.',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.4,
                                                    fontSize: bodySize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🎯 Rodapé responsivo com botões
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(basePadding, 0, basePadding, basePadding),
                                  child: Column(
                                    children: [
                                      // Divider sutil
                                      Container(
                                        height: 1,
                                        margin: EdgeInsets.only(bottom: isTablet ? 32 : 24),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              theme.colorScheme.outline.withOpacity(0.2),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Layout responsivo de botões
                                      isLandscape && !isTablet
                                          ? Row(
                                        children: [
                                          // Botão Cancelar
                                          Expanded(
                                            child: _buildCancelButton(context, theme, buttonHeight, bodySize),
                                          ),
                                          SizedBox(width: isTablet ? 20 : 16),
                                          // Botão Confirmar
                                          Expanded(
                                            flex: 2,
                                            child: _buildConfirmButton(context, theme, isChecked, buttonHeight, bodySize),
                                          ),
                                        ],
                                      )
                                          : Column(
                                        children: [
                                          // Botão Confirmar (principal)
                                          _buildConfirmButton(context, theme, isChecked, buttonHeight, bodySize),
                                          SizedBox(height: isTablet ? 16 : 12),
                                          // Botão Cancelar (secundário)
                                          _buildCancelButton(context, theme, buttonHeight - 8, bodySize),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

// Widget para botão de confirmação
  // 🎯 Botão de confirmação moderno e elegante
  Widget _buildConfirmButton(BuildContext context, ThemeData theme, bool isChecked, double height, double fontSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isChecked
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6), // Azul moderno
            Color(0xFF1D4ED8), // Azul mais escuro
          ],
        )
            : const LinearGradient(
          colors: [
            Color(0xFFF1F5F9), // Cinza claro neutro
            Color(0xFFE2E8F0), // Cinza um pouco mais escuro
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChecked
              ? const Color(0xFF3B82F6).withOpacity(0.3)
              : const Color(0xFFCBD5E1),
          width: isChecked ? 2 : 1,
        ),
        boxShadow: isChecked ? [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
        ] : [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isChecked
              ? () {
            Navigator.pop(context);
            controller.confirmContract();
          }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isChecked ? 8 : 0),
                  decoration: isChecked ? BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ) : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isChecked
                        ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('checked'),
                      color: Colors.white,
                      size: fontSize + 4,
                    )
                        : Icon(
                      Icons.lock_outline_rounded,
                      key: const ValueKey('unchecked'),
                      color: const Color(0xFF94A3B8),
                      size: fontSize + 4,
                    ),
                  ),
                ),

                if (isChecked) const SizedBox(width: 12),

                // Texto principal
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isChecked
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      fontSize: fontSize,
                      height: 1.2,
                    ),
                    child: const Text(
                      'Confirmar Contrato',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Indicador de estado
                if (isChecked) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

// 🚫 Botão de cancelamento moderno e sutil
  Widget _buildCancelButton(BuildContext context, ThemeData theme, double height, double fontSize) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFFF1F5F9),
          highlightColor: const Color(0xFFF8FAFC),
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone sutil
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF64748B),
                    size: fontSize,
                  ),
                ),

                const SizedBox(width: 12),

                // Texto do botão
                Flexible(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      letterSpacing: 0.2,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}