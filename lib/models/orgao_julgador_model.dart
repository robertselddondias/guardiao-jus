class OrgaoJulgadorModel {
  final int codigo;
  final String nome;

  OrgaoJulgadorModel({required this.codigo, required this.nome});

  /// 🔹 **Factory para criar um objeto a partir de JSON**
  factory OrgaoJulgadorModel.fromJson(Map<String, dynamic> json) {
    return OrgaoJulgadorModel(
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