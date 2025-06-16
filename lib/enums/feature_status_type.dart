import 'package:flutter/material.dart';

enum FeatureStatusType {
  ENVIADO_AO_JURIDICO,
  DISTRIBUIDO,
  EM_ANALISE,
  CONCILIACAO_AGUARDANDO,
  CONCILIACAO_REALIZADA,
  SENTENCA_AGUARDANDO,
  SENTENCA_PUBLICADA,
  RECURSO_INTERPOSTO,
  EM_RECURSO,
  EM_EXECUCAO,
  SUSPENSO,
  ARQUIVADO_PROVISORIAMENTE,
  ARQUIVADO_DEFINITIVAMENTE,
  FINALIZADO,
}

extension ProcessoStatusExtension on FeatureStatusType {
  String get label {
    switch (this) {
      case FeatureStatusType.ENVIADO_AO_JURIDICO:
        return 'Enviado ao jurídico';
      case FeatureStatusType.DISTRIBUIDO:
        return 'Distribuído';
      case FeatureStatusType.EM_ANALISE:
        return 'Em Análise';
      case FeatureStatusType.CONCILIACAO_AGUARDANDO:
        return 'Aguardando Conciliação';
      case FeatureStatusType.CONCILIACAO_REALIZADA:
        return 'Conciliação Realizada';
      case FeatureStatusType.SENTENCA_AGUARDANDO:
        return 'Aguardando Sentença';
      case FeatureStatusType.SENTENCA_PUBLICADA:
        return 'Sentença Publicada';
      case FeatureStatusType.RECURSO_INTERPOSTO:
        return 'Recurso Interposto';
      case FeatureStatusType.EM_RECURSO:
        return 'Em Recurso';
      case FeatureStatusType.EM_EXECUCAO:
        return 'Em Execução';
      case FeatureStatusType.SUSPENSO:
        return 'Suspenso';
      case FeatureStatusType.ARQUIVADO_PROVISORIAMENTE:
        return 'Arquivado Provisoriamente';
      case FeatureStatusType.ARQUIVADO_DEFINITIVAMENTE:
        return 'Arquivado Definitivamente';
      case FeatureStatusType.FINALIZADO:
        return 'Finalizado';
    }
  }

  String get description {
    switch (this) {
      case FeatureStatusType.ENVIADO_AO_JURIDICO:
        return 'Processo enviado ao seu convênio jurídico.';
      case FeatureStatusType.DISTRIBUIDO:
        return 'Processo foi distribuído ao tribunal competente.';
      case FeatureStatusType.EM_ANALISE:
        return 'Processo está em análise pelo juiz ou pela parte responsável.';
      case FeatureStatusType.CONCILIACAO_AGUARDANDO:
        return 'Aguardando a realização de audiência de conciliação.';
      case FeatureStatusType.CONCILIACAO_REALIZADA:
        return 'Audiência de conciliação foi realizada.';
      case FeatureStatusType.SENTENCA_AGUARDANDO:
        return 'Aguardando a publicação da sentença.';
      case FeatureStatusType.SENTENCA_PUBLICADA:
        return 'Sentença foi publicada.';
      case FeatureStatusType.RECURSO_INTERPOSTO:
        return 'Recurso foi interposto contra a decisão.';
      case FeatureStatusType.EM_RECURSO:
        return 'Processo está em fase de recurso.';
      case FeatureStatusType.EM_EXECUCAO:
        return 'Processo está em fase de execução de sentença.';
      case FeatureStatusType.SUSPENSO:
        return 'Processo foi suspenso por decisão judicial.';
      case FeatureStatusType.ARQUIVADO_PROVISORIAMENTE:
        return 'Processo arquivado provisoriamente.';
      case FeatureStatusType.ARQUIVADO_DEFINITIVAMENTE:
        return 'Processo arquivado de forma definitiva.';
      case FeatureStatusType.FINALIZADO:
        return 'Processo foi concluído e encerrado.';
    }
  }

  IconData get icon {
    switch (this) {
      case FeatureStatusType.ENVIADO_AO_JURIDICO:
        return Icons.send_and_archive_outlined;
      case FeatureStatusType.DISTRIBUIDO:
        return Icons.assignment_turned_in_outlined;
      case FeatureStatusType.EM_ANALISE:
        return Icons.search;
      case FeatureStatusType.CONCILIACAO_AGUARDANDO:
        return Icons.group_outlined;
      case FeatureStatusType.CONCILIACAO_REALIZADA:
        return Icons.check_circle_outline;
      case FeatureStatusType.SENTENCA_AGUARDANDO:
        return Icons.hourglass_bottom;
      case FeatureStatusType.SENTENCA_PUBLICADA:
        return Icons.description_outlined;
      case FeatureStatusType.RECURSO_INTERPOSTO:
        return Icons.outbox_outlined;
      case FeatureStatusType.EM_RECURSO:
        return Icons.sync;
      case FeatureStatusType.EM_EXECUCAO:
        return Icons.gavel_outlined;
      case FeatureStatusType.SUSPENSO:
        return Icons.pause_circle_outline;
      case FeatureStatusType.ARQUIVADO_PROVISORIAMENTE:
        return Icons.archive_outlined;
      case FeatureStatusType.ARQUIVADO_DEFINITIVAMENTE:
        return Icons.archive_rounded;
      case FeatureStatusType.FINALIZADO:
        return Icons.done_all;
    }
  }

  Color get color {
    switch (this) {
      case FeatureStatusType.ENVIADO_AO_JURIDICO:
        return const Color(0xFF1565C0); // Azul forte (azul real)
      case FeatureStatusType.DISTRIBUIDO:
        return const Color(0xFF00897B); // Verde água vibrante
      case FeatureStatusType.EM_ANALISE:
        return const Color(0xFFFF9800); // Laranja intenso
      case FeatureStatusType.CONCILIACAO_AGUARDANDO:
        return const Color(0xFFFFC107); // Amarelo vibrante
      case FeatureStatusType.CONCILIACAO_REALIZADA:
        return const Color(0xFF00C853); // Verde esmeralda
      case FeatureStatusType.SENTENCA_AGUARDANDO:
        return const Color(0xFF42A5F5); // Azul médio moderno
      case FeatureStatusType.SENTENCA_PUBLICADA:
        return const Color(0xFF37474F); // Cinza azulado sofisticado
      case FeatureStatusType.RECURSO_INTERPOSTO:
        return const Color(0xFFD84315); // Laranja escuro vibrante
      case FeatureStatusType.EM_RECURSO:
        return const Color(0xFF00ACC1); // Azul turquesa brilhante
      case FeatureStatusType.EM_EXECUCAO:
        return const Color(0xFF7E57C2); // Roxo intenso moderno
      case FeatureStatusType.SUSPENSO:
        return const Color(0xFF9E9E9E); // Cinza neutro elegante
      case FeatureStatusType.ARQUIVADO_PROVISORIAMENTE:
        return const Color(0xFF795548); // Marrom sofisticado
      case FeatureStatusType.ARQUIVADO_DEFINITIVAMENTE:
        return const Color(0xFFD32F2F); // Vermelho vibrante forte
      case FeatureStatusType.FINALIZADO:
        return const Color(0xFF1B5E20); // Verde escuro profundo
    }
  }
}