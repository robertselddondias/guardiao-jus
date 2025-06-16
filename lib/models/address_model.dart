

class AddressModel {

  // Endereço
  String? cep;
  String? uf;
  String? city;
  String? district;
  String? street;
  String? number;
  String? complement;

  AddressModel({
    this.number,
    this.cep,
    this.city,
    this.complement,
    this.district,
    this.street,
    this.uf
  });

  // Converte de Map para MilitaryModel
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      number: map['number'],
      cep: map['cep'],
      city: map['city'],
      complement: map['complement'],
      district: map['district'],
      street: map['street'],
      uf: map['uf'],
    );
  }

  // Converte MilitaryModel para Map
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'cep': cep,
      'city': city,
      'complement': complement,
      'district': district,
      'street': street,
      'uf': uf,
    };
  }
}