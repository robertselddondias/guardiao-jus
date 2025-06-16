
class FileModel {

  String? fileName;

  String? extencao;

  String? url;

  FileModel({
    this.url,
    this.extencao,
    this.fileName
  });

  // Converte o modelo para um Map (útil para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'extencao': extencao,
      'fileName': fileName
    };
  }

  // Constrói o modelo a partir de um Map (útil para recuperar do Firestore)
  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      url: map['url'] as String?,
      fileName: map['fileName'] ?? '', // Campo obrigatório
      extencao: map['extencao']
    );
  }
}