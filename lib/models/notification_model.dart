class NotificationModel {
  String? id;
  final String title;
  final String body;
  final String type; // Ex.: "info", "warning", "error", "success"
  Map<String, dynamic>? payload;
  final String? companyId;
  final String? toUserId;
  final String createdAt; // Data/hora de criação da notificação
  bool isRead; // Status de leitura

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.createdAt,
    this.isRead = false,
    this.companyId,
    this.toUserId
  });

  // Converter o modelo para um Map (útil para Firestore ou JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'createdAt': createdAt,
      'isRead': isRead,
      'companyId': companyId,
      'toUserId': toUserId,
    };
  }

  // Criar o modelo a partir de um Map (útil para Firestore ou JSON)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
        id: map['id'],
        title: map['title'],
        body: map['body'],
        type: map['type'],
        payload: map['payload'],
        createdAt: map['createdAt'],
        isRead: map['isRead'] ?? false,
        companyId: map['companyId'],
        toUserId: map['toUserId']
    );
  }
}