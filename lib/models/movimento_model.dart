class MovimentoModel {
  final int codigo;
  final String nome;
  final String dataHora;

  MovimentoModel({
    required this.codigo,
    required this.nome,
    required this.dataHora,
  });

  /// 🔹 **Factory para criar um objeto a partir de JSON**
  factory MovimentoModel.fromJson(Map<String, dynamic> json) {
    return MovimentoModel(
      codigo: json['codigo'] ?? 0,
      nome: json['nome'] ?? '',
      dataHora: json['dataHora'] ?? '',
    );
  }

  /// 🔹 **Converte o objeto para JSON**
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'dataHora': dataHora,
    };
  }
}