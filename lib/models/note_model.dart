class NoteModel {

  String title;
  String description;
  String createdAt;

  String? userId;
  String? companyId;

  String? rapId;
  String? advogadoId;

  String? processoId;

  NoteModel({
    required this.title,
    required this.description,
    required this.createdAt,
    this.companyId,
    this.userId,
    this.rapId,
    this.advogadoId,
    this.processoId
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'companyId': companyId,
      'userId': userId,
      'rapId': rapId,
      'advogadoId': advogadoId,
      'processoId': processoId
    };
  }

  static NoteModel fromMap(Map<String, dynamic> map) {
    return NoteModel(
        title: map['title'],
        description: map['description'],
        createdAt: map['createdAt'],
        companyId: map['companyId'],
        userId: map['userId'],
        advogadoId: map['advogadoId'],
        rapId: map['rapId'],
        processoId: map['processoId']
    );
  }
}
