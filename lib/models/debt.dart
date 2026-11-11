enum DebtType {
  receivable, // Мне должны (Дебиторка)
  payable, // Я должен (Кредиторка)
}

class Debt {
  final String id;
  final String counterpartyName; // ФИО / Название цеха или контейнера
  final String counterpartyPhone; // Номер телефона (+996...)
  final DebtType type;
  final double amountKgs; // Сумма долга в сомах KGS
  final DateTime dueDate; // Дата обещанного платежа
  final String description; // За что (напр. "Ткань Рулон Замок 100м")
  bool isPaid;

  Debt({
    required this.id,
    required this.counterpartyName,
    required this.counterpartyPhone,
    required this.type,
    required this.amountKgs,
    required this.dueDate,
    required this.description,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'counterpartyName': counterpartyName,
        'counterpartyPhone': counterpartyPhone,
        'type': type.index,
        'amountKgs': amountKgs,
        'dueDate': dueDate.toIso8601String(),
        'description': description,
        'isPaid': isPaid,
      };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'],
        counterpartyName: json['counterpartyName'],
        counterpartyPhone: json['counterpartyPhone'],
        type: DebtType.values[json['type'] ?? 0],
        amountKgs: (json['amountKgs'] as num).toDouble(),
        dueDate: DateTime.parse(json['dueDate']),
        description: json['description'] ?? '',
        isPaid: json['isPaid'] ?? false,
      );
}
