enum TransactionType {
  stockIn, // Приход (+)
  stockOut, // Списание (-)
}

class StockTransaction {
  final String id;
  final String productId;
  final String productName;
  final TransactionType type;
  final double quantity;
  final String unit;
  final DateTime timestamp;
  final String note;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.timestamp,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'type': type.index,
        'quantity': quantity,
        'unit': unit,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory StockTransaction.fromJson(Map<String, dynamic> json) => StockTransaction(
        id: json['id'],
        productId: json['productId'],
        productName: json['productName'],
        type: TransactionType.values[json['type'] ?? 0],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        timestamp: DateTime.parse(json['timestamp']),
        note: json['note'] ?? '',
      );
}
