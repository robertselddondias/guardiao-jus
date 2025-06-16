import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/enums/pedido_type.dart';
import 'package:guardiao_cliente/models/processo_juridico_model.dart';

class ProcessoModel {
  late String? id;
  String? title;
  String? description;
  String? numeroProcesso;
  String userId;
  String userName;
  String companyId;
  ProcessoJuridicoModel? processoJuridico;
  FeatureStatusType status;
  bool isNew;
  String createAt;
  PedidoType type;
  List<String>? urlFiles;

  ProcessoModel({
    this.id,
    this.title,
    this.description,
    this.numeroProcesso,
    required this.userId,
    required this.companyId,
    required this.isNew,
    required this.status,
    required this.createAt,
    required this.type,
    this.processoJuridico,
    this.urlFiles,
    required this.userName
  });

  /// **Factory para criar um objeto a partir de JSON**
  factory ProcessoModel.fromJson(Map<String, dynamic> json) {
    return ProcessoModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        userId: json['userId'] ?? '',
        companyId: json['companyId'] ?? '',
        numeroProcesso: json['numeroProcesso'] ?? '',

        // 🔥 Converte a string do JSON para o ENUM correto
        status: FeatureStatusType.values.firstWhere(
                (e) => e.name == json['status']
        ),

        type: PedidoType.values.firstWhere(
                (e) => e.name == json['type']
        ),

        isNew: json['isNew'] ?? false,
        createAt: json['createAt'] ?? '',
        urlFiles: json['urlFiles'] != null
            ? List<String>.from(json['urlFiles'])
            : [],
        processoJuridico: json['processoJuridico'] != null
            ? ProcessoJuridicoModel.fromJson(json['processoJuridico'])
            : null,
        userName: json['userName'] ?? '',

    );
  }

  /// **Converte o objeto para JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'companyId': companyId,
      'numeroProcesso': numeroProcesso,
      'status': status.name, // 🔥 Salva como STRING para facilitar a leitura no banco
      'isNew': isNew,
      'createAt': createAt,
      'processoJuridico': processoJuridico?.toJson(),
      'type': type.name,
      'urlFiles': urlFiles,
      'userName': userName
    };
  }
}