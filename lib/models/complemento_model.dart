class ComplementoModel {

  final int valor;
  final String nome;
  final String descricao;

  ComplementoModel({
    required this.valor,
    required this.nome,
    required this.descricao,
  });

  factory ComplementoModel.fromJson(Map<String, dynamic> json) {
    return ComplementoModel(
      valor: json['valor'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }
}