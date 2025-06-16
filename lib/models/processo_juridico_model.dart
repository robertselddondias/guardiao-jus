

import 'package:guardiao_cliente/models/assunto_model.dart';
import 'package:guardiao_cliente/models/movimento_model.dart';
import 'package:guardiao_cliente/models/orgao_julgador_model.dart';

class ProcessoJuridicoModel {
  final String numeroProcesso;
  final String classeNome;
  final String formatoNome;
  final String tribunal;
  final String dataHoraUltimaAtualizacao;
  final String grau;
  final String dataAjuizamento;
  final List<MovimentoModel> movimentos;
  final String id;
  final int nivelSigilo;
  final OrgaoJulgadorModel orgaoJulgador;
  final List<AssuntoModel> assuntos;

  ProcessoJuridicoModel({
    required this.numeroProcesso,
    required this.classeNome,
    required this.formatoNome,
    required this.tribunal,
    required this.dataHoraUltimaAtualizacao,
    required this.grau,
    required this.dataAjuizamento,
    required this.movimentos,
    required this.id,
    required this.nivelSigilo,
    required this.orgaoJulgador,
    required this.assuntos,
  });

  /// 🔹 **Factory para criar um objeto a partir de JSON**
  factory ProcessoJuridicoModel.fromJson(Map<String, dynamic> json) {
    return ProcessoJuridicoModel(
      numeroProcesso: json['numeroProcesso'] ?? '',
      classeNome: json['classe']['nome'] ?? '',
      formatoNome: json['formato']['nome'] ?? '',
      tribunal: json['tribunal'] ?? '',
      dataHoraUltimaAtualizacao: json['dataHoraUltimaAtualizacao'] ?? '',
      grau: json['grau'] ?? '',
      dataAjuizamento: json['dataAjuizamento'] ?? '',
      movimentos: (json['movimentos'] as List? ?? [])
          .map((mov) => MovimentoModel.fromJson(mov))
          .toList(),
      id: json['id'] ?? '',
      nivelSigilo: json['nivelSigilo'] ?? 0,
      orgaoJulgador: OrgaoJulgadorModel.fromJson(json['orgaoJulgador'] ?? {}),
      assuntos: (json['assuntos'] as List? ?? [])
          .map((assunto) => AssuntoModel.fromJson(assunto))
          .toList(),
    );
  }

  /// 🔹 **Converte o objeto para JSON**
  Map<String, dynamic> toJson() {
    return {
      'numeroProcesso': numeroProcesso,
      'classe': {'nome': classeNome},
      'formato': {'nome': formatoNome},
      'tribunal': tribunal,
      'dataHoraUltimaAtualizacao': dataHoraUltimaAtualizacao,
      'grau': grau,
      'dataAjuizamento': dataAjuizamento,
      'movimentos': movimentos.map((mov) => mov.toJson()).toList(),
      'id': id,
      'nivelSigilo': nivelSigilo,
      'orgaoJulgador': orgaoJulgador.toJson(),
      'assuntos': assuntos.map((assunto) => assunto.toJson()).toList(),
    };
  }
}