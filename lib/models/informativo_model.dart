class InformativoModel {
  String? id;
  String titulo;
  String conteudo;
  String? imagemUrl;
  String categoria; // ex: "PMDF", "CBMDF", "GERAL", etc.
  DateTime dataPublicacao;
  DateTime? dataExpiracao;
  bool ativo;
  String? linkExterno;
  int prioridade; // 1 = alta, 2 = média, 3 = baixa
  List<String>? tags;

  InformativoModel({
    this.id,
    required this.titulo,
    required this.conteudo,
    this.imagemUrl,
    required this.categoria,
    required this.dataPublicacao,
    this.dataExpiracao,
    this.ativo = true,
    this.linkExterno,
    this.prioridade = 2,
    this.tags,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'conteudo': conteudo,
      'imagemUrl': imagemUrl,
      'categoria': categoria,
      'dataPublicacao': dataPublicacao.toIso8601String(),
      'dataExpiracao': dataExpiracao?.toIso8601String(),
      'ativo': ativo,
      'linkExterno': linkExterno,
      'prioridade': prioridade,
      'tags': tags,
    };
  }

  // Converter de Map (para ler do Firestore)
  factory InformativoModel.fromMap(Map<String, dynamic> map, String docId) {
    return InformativoModel(
      id: docId,
      titulo: map['titulo'] ?? '',
      conteudo: map['conteudo'] ?? '',
      imagemUrl: map['imagemUrl'],
      categoria: map['categoria'] ?? 'GERAL',
      dataPublicacao: DateTime.parse(map['dataPublicacao']),
      dataExpiracao: map['dataExpiracao'] != null
          ? DateTime.parse(map['dataExpiracao'])
          : null,
      ativo: map['ativo'] ?? true,
      linkExterno: map['linkExterno'],
      prioridade: map['prioridade'] ?? 2,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Verificar se o informativo ainda está válido
  bool get isValido {
    if (!ativo) return false;
    if (dataExpiracao != null && DateTime.now().isAfter(dataExpiracao!)) {
      return false;
    }
    return true;
  }

  // Copy with para facilitar edições
  InformativoModel copyWith({
    String? id,
    String? titulo,
    String? conteudo,
    String? imagemUrl,
    String? categoria,
    DateTime? dataPublicacao,
    DateTime? dataExpiracao,
    bool? ativo,
    String? linkExterno,
    int? prioridade,
    List<String>? tags,
  }) {
    return InformativoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      categoria: categoria ?? this.categoria,
      dataPublicacao: dataPublicacao ?? this.dataPublicacao,
      dataExpiracao: dataExpiracao ?? this.dataExpiracao,
      ativo: ativo ?? this.ativo,
      linkExterno: linkExterno ?? this.linkExterno,
      prioridade: prioridade ?? this.prioridade,
      tags: tags ?? this.tags,
    );
  }
}