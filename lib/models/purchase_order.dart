enum OrderStatus {
  draft,
  sent,
  confirmed,
  completed,
}

class PurchaseOrderItem {
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnitKgs;

  PurchaseOrderItem({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnitKgs,
  });

  double get totalPriceKgs => quantity * pricePerUnitKgs;

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnitKgs': pricePerUnitKgs,
      };

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
        productName: json['productName'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        pricePerUnitKgs: (json['pricePerUnitKgs'] as num).toDouble(),
      );
}

class PurchaseOrder {
  final String id;
  final String supplierName;
  final String supplierPhone;
  final List<PurchaseOrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  PurchaseOrder({
    required this.id,
    required this.supplierName,
    required this.supplierPhone,
    required this.items,
    this.status = OrderStatus.draft,
    required this.createdAt,
  });

  double get totalAmountKgs {
    return items.fold(0, (sum, item) => sum + item.totalPriceKgs);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplierName': supplierName,
        'supplierPhone': supplierPhone,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        id: json['id'],
        supplierName: json['supplierName'],
        supplierPhone: json['supplierPhone'],
        items: (json['items'] as List).map((i) => PurchaseOrderItem.fromJson(i)).toList(),
        status: OrderStatus.values[json['status'] ?? 0],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
