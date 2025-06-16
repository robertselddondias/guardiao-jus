import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiao_cliente/models/address_model.dart';
import 'package:guardiao_cliente/models/military_model.dart';

class UserModel {
  // Dados básicos
  String? uid;
  String? name;
  String? email;
  String? phone;
  String? photoUrl;
  DateTime? createdAt;
  String? countryCode;
  String? customerId;

  String? contractId;
  String? companyId;
  bool? isPlanoAtivo;

  // Dados Pessoais
  String? cpf;
  DateTime? birthDate;

  // Endereço
  AddressModel? address;

  // Dados Militares
  MilitaryModel? militarData;


  String? fcmToken;

  bool? isPersonalInfoComplete = false;
  bool? isAdressInfoComplete = false;
  bool? isMilitaryInfoComplete = false;

  bool? isFirstAccess = false;

  UserModel({
    // Dados básicos
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.createdAt,
    this.countryCode,
    this.customerId,

    // Dados Pessoais
    this.cpf,
    this.birthDate,

    // Endereço
    this.address,

    // Dados Militares
    this.militarData,

    this.fcmToken,

    this.isAdressInfoComplete,
    this.isMilitaryInfoComplete,
    this.isPersonalInfoComplete,
    this.isFirstAccess,
    this.contractId,
    this.companyId,
    this.isPlanoAtivo
  });

  // Converte um Firebase User para UserModel
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime
      // Dados adicionais serão preenchidos posteriormente
    );
  }

  // Converte de Map para UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      cpf: map['cpf'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      address: map['address'] != null ? AddressModel.fromMap(map['address']) : null,
      militarData: map['militarData'] != null ? MilitaryModel.fromMap(map['militarData']) : null,
      fcmToken: map['fcmToken'],
      countryCode: map['countryCode'],
      customerId: map['customerId'],

      isMilitaryInfoComplete: map['isMilitaryInfoComplete'],
      isPersonalInfoComplete: map['isPersonalInfoComplete'],
      isAdressInfoComplete: map['isAdressInfoComplete'],
      isFirstAccess: map['isFirstAccess'],
      companyId: map['companyId'],
      contractId: map['contractId'],
      isPlanoAtivo: map['isPlanoAtivo'],
    );
  }

  // Converte UserModel para Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'cpf': cpf,
      'birthDate': birthDate?.toIso8601String(),
      'address': address?.toMap() ,
      'militarData': militarData?.toMap(),
      'fcmToken': fcmToken,
      'countryCode': countryCode,
      'customerId': customerId,


      'isPersonalInfoComplete': isPersonalInfoComplete,
      'isAdressInfoComplete': isAdressInfoComplete,
      'isMilitaryInfoComplete': isMilitaryInfoComplete,
      'isFirstAccess': isFirstAccess,
      'isPlanoAtivo': isPlanoAtivo,
      'companyId': companyId,
      'contractId': contractId,
    };
  }
}
