import 'package:guardiao_cliente/enums/feature_status_type.dart';

class RapModel {
  String? id;
  String? title;
  String? createAt;
  String? description;
  String? userId;
  String? userName;
  List<String>? urlFiles;
  String? dtOcorrencia;
  String? companyId;
  FeatureStatusType? status;

  RapModel({
    this.id,
    this.title,
    this.createAt,
    this.description,
    this.urlFiles,
    this.dtOcorrencia,
    this.userId,
    this.companyId,
    this.userName,
    this.status
  });

  // Converte o modelo para um Map (útil para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createAt': createAt,
      'description': description,
      'urlFiles': urlFiles,
      'dtOcorrencia': dtOcorrencia,
      'userId': userId,
      'companyId': companyId,
      'userName': userName,
      'status': status?.name
    };
  }

  // Constrói o modelo a partir de um Map (útil para recuperar do Firestore)
  factory RapModel.fromMap(Map<String, dynamic> map) {
    return RapModel(
      id: map['id'] as String?,
      title: map['title'] ?? '', // Campo obrigatório
      createAt: map['createAt'], // Garante que `createAt` seja uma data válida
      description: map['description'] as String?,
      urlFiles: map['urlFiles'] != null
          ? List<String>.from(map['urlFiles'])
          : [], // Garante que seja uma lista de strings
      dtOcorrencia: map['dtOcorrencia'],
      userId: map['userId'] as String?,
      companyId: map['companyId'] as String?,
      userName: map['userName'] as String?,
      status: map['status'] != null
          ? FeatureStatusType.values.firstWhere(
            (e) => e.name == map['status'], // Converte string para enum
        orElse: () => FeatureStatusType.ENVIADO_AO_JURIDICO,
      ) : null,
    );
  }
}