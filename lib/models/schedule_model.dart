import 'package:guardiao_cliente/enums/schedule_type.dart';

class ScheduleModel {
  String? id;
  String title;
  String description;
  String time;
  String date;
  String? rapId;
  String? processoId;
  String? companyId;
  String? userAdvId;
  String? userId;
  String? nomeCliente;
  String? nomeSolicitacao;
  String? createAt;
  ScheduleType scheduleType;
  bool notified;

  ScheduleModel({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    this.rapId,
    this.companyId,
    this.userAdvId,
    this.userId,
    this.nomeCliente,
    this.nomeSolicitacao,
    this.createAt,
    this.processoId,
    required this.notified,
    required this.scheduleType, // Campo obrigatório
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'date': date,
      'rapId': rapId,
      'companyId': companyId,
      'userAdvId': userAdvId,
      'userId': userId,
      'nomeCliente': nomeCliente,
      'nomeRap': nomeSolicitacao,
      'createAt': createAt,
      'processoId': processoId,
      'scheduleType': scheduleType.name,
      'notified': notified
    };
  }

  static ScheduleModel fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        time: map['time'],
        date: map['date'],
        rapId: map['rapId'],
        companyId: map['companyId'],
        userAdvId: map['userAdvId'],
        userId: map['userId'],
        nomeCliente: map['nomeCliente'],
        nomeSolicitacao: map['nomeRap'],
        createAt: map['createAt'],
        scheduleType: ScheduleType.values.firstWhere(
              (e) => e.name == map['scheduleType'],
          orElse: () => ScheduleType.INDIVIDUAL, // Define um padrão caso não encontre
        ),
        processoId: map['processoId'],
        notified: map['notified']
    );
  }
}