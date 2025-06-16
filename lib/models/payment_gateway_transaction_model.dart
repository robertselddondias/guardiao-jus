class PaymentGatewayTransactionModel {
  String? id;
  String? userId;
  String? companyId;
  String? creditCardId;
  String? contractId;
  String? customerId;
  String? transactionId;
  int? amount; // Valor em centavos (padrão do Pagar.me) ou use double para reais
  bool? paid;
  String? status; // "paid", "pending", "refused", etc.
  String? paymentMethod; // "credit_card", "pix", "boleto", etc.
  DateTime? createdAt;

  // Campos opcionais que podem ser úteis:
  String? cardBrand;
  String? cardLastFourDigits;
  String? pixQrCodeUrl; // se método for PIX, pode armazenar a URL do QR Code
  String? pixEmv; // Código EMV do pix

  PaymentGatewayTransactionModel({
    this.userId,
    this.companyId,
    this.customerId,
    this.transactionId,
    this.amount,
    this.paid,
    this.status,
    this.paymentMethod,
    this.createdAt,
    this.cardBrand,
    this.cardLastFourDigits,
    this.pixQrCodeUrl,
    this.pixEmv,
    this.id,
    this.creditCardId,
    this.contractId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'customerId': customerId,
      'transactionId': transactionId,
      'amount': amount,
      'paid': paid,
      'status': status,
      'paymentMethod': paymentMethod,
      'creditCardId': creditCardId,
      'createdAt': DateTime.now().toIso8601String(),
      'contractId': contractId,
      if (cardBrand != null) 'cardBrand': cardBrand,
      if (cardLastFourDigits != null) 'cardLastFourDigits': cardLastFourDigits,
      if (pixQrCodeUrl != null) 'pixQrCodeUrl': pixQrCodeUrl,
      if (pixEmv != null) 'pixEmv': pixEmv,
    };
  }

  factory PaymentGatewayTransactionModel.fromMap(Map<String, dynamic> map) {
    return PaymentGatewayTransactionModel(
        id: map['id'] as String?,
        userId: map['userId'] as String?,
        companyId: map['companyId'] as String?,
        customerId: map['customerId'] as String?,
        transactionId: map['transactionId'] as String?,
        amount: (map['amount'] as num).toInt(),
        paid: map['paid'] as bool?,
        status: map['status'] as String?,
        paymentMethod: map['paymentMethod'] as String?,
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
        cardBrand: map['cardBrand'] as String?,
        cardLastFourDigits: map['cardLastFourDigits'] as String?,
        pixQrCodeUrl: map['pixQrCodeUrl'] as String?,
        pixEmv: map['pixEmv'] as String?,
        creditCardId: map['creditCardId'] as String?,
        contractId: map['contractId'] as String?
    );
  }
}
