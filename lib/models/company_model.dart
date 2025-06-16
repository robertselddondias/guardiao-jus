import 'package:guardiao_cliente/models/address_model.dart';

class CompanyModel {
  String? id;
  String? name;
  String? logoUrl;
  String? cnpj;
  String? email;
  String? phone;
  String? description;
  String? urlContract;
  String? oab;
  String? phoneEmergencia;
  String? whatsapp;
  int? monthlyValue;
  AddressModel? address;
  bool? isEmergency;
  String? phoneEmergency;
  List<dynamic>? beneficios;

  CompanyModel({
    this.id,
    this.name,
    this.logoUrl,
    this.cnpj,
    this.email,
    this.phone,
    this.description,
    this.address,
    this.monthlyValue,
    this.urlContract,
    this.beneficios,
    this.oab,
    this.phoneEmergencia,
    this.whatsapp,
    this.isEmergency,
    this.phoneEmergency
  });

  // Converte o modelo para um Map (útil para salvar no Firestore ou APIs)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'cnpj': cnpj,
      'email': email,
      'phone': phone,
      'description': description,
      'monthlyValue': monthlyValue,
      'urlContract': urlContract,
      'address': address?.toMap(),
      'beneficios': beneficios,
      'oab': oab,
      'phoneEmergencia': phoneEmergencia,
      'whatsapp': whatsapp,
      'isEmergency': isEmergency,
      'phoneEmergency': phoneEmergency
    };
  }

  // Constrói o modelo a partir de um Map (útil para recuperar do Firestore ou APIs)
  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
        id: map['id'],
        name: map['name'],
        logoUrl: map['logoUrl'],
        cnpj: map['cnpj'],
        email: map['email'],
        phone: map['phone'],
        description: map['description'],
        urlContract: map['urlContract'],
        monthlyValue: map['monthlyValue'],
        address: map['address'] != null ? AddressModel.fromMap(map['address']) : null,
        beneficios: map['beneficios'],
        oab: map['oab'],
        phoneEmergencia: map['phoneEmergencia'],
        whatsapp: map['whatsapp'],
        isEmergency: map['isEmergency'],
        phoneEmergency: map['phoneEmergency']

    );
  }
}
