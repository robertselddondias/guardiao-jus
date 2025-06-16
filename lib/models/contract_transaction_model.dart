class ContractTransactionModel {
  String? id;
  final String? userId;
  final String? companyId;
  final String? paymentMethodName;
  final int? monthlyValue;
  final String? chargeDate;
  final DateTime? createdAt;

  ContractTransactionModel({
    this.id,
    this.userId,
    this.companyId,
    this.paymentMethodName,
    this.monthlyValue,
    this.chargeDate,
    this.createdAt,
  });

  // Converte para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'paymentMethodName': paymentMethodName,
      'monthlyValue': monthlyValue,
      'chargeDate': chargeDate,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Cria a partir de um Map (para recuperar do Firestore)
  factory ContractTransactionModel.fromMap(Map<String, dynamic> map) {
    return ContractTransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      companyId: map['companyId'] as String,
      paymentMethodName: map['paymentMethodName'] as String,
      monthlyValue: (map['monthlyValue'] as num).toInt(),
      chargeDate: map['chargeDate'] as String,
      createdAt: map['createAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
