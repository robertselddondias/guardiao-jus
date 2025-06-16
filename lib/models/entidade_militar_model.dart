
class EntidadeMilitarModel {
  String? description;
  String? sigla;
  String? estado;
  String? name;

  EntidadeMilitarModel({
    this.description,
    this.sigla,
    this.estado,
    this.name
  });

  // Converte o modelo para um Map (útil para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'sigla': sigla,
      'estado': estado,
      'name': name
    };
  }

  // Constrói o modelo a partir de um Map (útil para recuperar do Firestore)
  factory EntidadeMilitarModel.fromMap(Map<String, dynamic> map) {
    return EntidadeMilitarModel(
      description: map['description'] ?? '',
      sigla: map['sigla'],
      estado: map['estado'] as String?,
      name: map['name'] as String?
    );
  }
}