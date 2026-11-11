enum StockStatus {
  normal, // Зеленый (Норма >50%)
  low, // Желтый (Мало 20-50%)
  critical, // Красный (Критический дефицит <20%)
}

class Product {
  final String id;
  final String name;
  final String category; // "Ткани", "Нитки", "Фурнитура"
  final String unit; // "метры", "рулоны", "штуки", "кг"
  double currentStock;
  final double minThreshold; // Минимальный порог безопасности
  final double dailyBurnRate; // Средний дневной расход
  final double pricePerUnitKgs; // Цена в сомах (KGS)
  final String defaultSupplierPhone;
  final String defaultSupplierName;
  final String qrCode;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minThreshold,
    required this.dailyBurnRate,
    required this.pricePerUnitKgs,
    this.defaultSupplierPhone = '+996555123456',
    this.defaultSupplierName = 'Оптовик Дордой (Асан)',
    String? qrCode,
  }) : qrCode = qrCode ?? 'SMSK-${id.toUpperCase()}';

  // Расчет дней до полного истощения запаса
  int get daysRemaining {
    if (dailyBurnRate <= 0) return 999;
    return (currentStock / dailyBurnRate).floor();
  }

  // Относительный уровень заполненности остатка от 0.0 до 1.0
  double get fillRatio {
    final maxCapacity = minThreshold * 3.0;
    if (maxCapacity <= 0) return 1.0;
    return (currentStock / maxCapacity).clamp(0.0, 1.0);
  }

  // Определение статуса запаса
  StockStatus get status {
    if (currentStock <= minThreshold) {
      return StockStatus.critical;
    } else if (currentStock <= minThreshold * 1.5) {
      return StockStatus.low;
    }
    return StockStatus.normal;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'unit': unit,
        'currentStock': currentStock,
        'minThreshold': minThreshold,
        'dailyBurnRate': dailyBurnRate,
        'pricePerUnitKgs': pricePerUnitKgs,
        'defaultSupplierPhone': defaultSupplierPhone,
        'defaultSupplierName': defaultSupplierName,
        'qrCode': qrCode,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        unit: json['unit'],
        currentStock: (json['currentStock'] as num).toDouble(),
        minThreshold: (json['minThreshold'] as num).toDouble(),
        dailyBurnRate: (json['dailyBurnRate'] as num).toDouble(),
        pricePerUnitKgs: (json['pricePerUnitKgs'] as num).toDouble(),
        defaultSupplierPhone: json['defaultSupplierPhone'] ?? '',
        defaultSupplierName: json['defaultSupplierName'] ?? '',
        qrCode: json['qrCode'] ?? 'SMSK-${json['id']}',
      );
}
