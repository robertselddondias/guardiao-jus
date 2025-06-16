class AssuntoModel {
  final int codigo;
  final String nome;

  AssuntoModel({
    required this.codigo,
    required this.nome,
  });

  /// 🔹 **Factory para criar um objeto a partir de JSON**
  factory AssuntoModel.fromJson(Map<String, dynamic> json) {
    return AssuntoModel(
      codigo: json['codigo'] ?? 0,
      nome: json['nome'] ?? '',
    );
  }

  /// 🔹 **Converte o objeto para JSON**
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
    };
  }
}