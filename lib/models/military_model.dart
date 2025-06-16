

class MilitaryModel {

  String? registrationNumber;
  String? rank;
  String? militaryUf;
  String? entity;

  MilitaryModel({
    this.registrationNumber,
    this.rank,
    this.militaryUf,
    this.entity,
  });

  // Converte de Map para MilitaryModel
  factory MilitaryModel.fromMap(Map<String, dynamic> map) {
    return MilitaryModel(
      registrationNumber: map['registrationNumber'],
      rank: map['rank'],
      militaryUf: map['militaryUf'],
      entity: map['entity'],
    );
  }

  // Converte MilitaryModel para Map
  Map<String, dynamic> toMap() {
    return {
      'registrationNumber': registrationNumber,
      'rank': rank,
      'militaryUf': militaryUf,
      'entity': entity
    };
  }

}