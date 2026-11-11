import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../models/debt.dart';
import '../models/purchase_order.dart';
import '../models/user_profile.dart';
import '../models/contact.dart';
import '../models/audit_log.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';

enum AppCurrency { kgs, usd }

class AppStateProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.ru;
  AppCurrency _currency = AppCurrency.kgs;
  double _usdExchangeRate = 89.5; // Курс сома к доллару США
  bool _isOnline = true;

  UserProfile _userProfile = UserProfile(
    id: 'user_001',
    name: 'Азамат (Магазин GadgetZone)',
    phone: '+996555112233',
    role: UserRole.retailer,
    location: 'Бишкек, ЦУМ-2, 3-этаж, отдел 14',
  );

  final List<Contact> _contacts = [
    Contact(
      id: 'c1',
      name: 'Дордой Контейнер 850 (Электроника)',
      phone: '+996700112233',
      role: ContactRole.supplier,
      location: 'Дордой, проход 12',
    ),
    Contact(
      id: 'c2',
      name: 'Карго Поставка из Гуанчжоу (Бакыт)',
      phone: '+996555998877',
      role: ContactRole.supplier,
      location: 'Бишкек, Склад Карго #5',
    ),
  ];

  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Механическая клавиатура RGB (Red Switch)',
      category: 'Клавиатуры',
      unit: 'штуки',
      currentStock: 8.0,
      minThreshold: 15.0,
      dailyBurnRate: 3.0,
      pricePerUnitKgs: 2400.0,
      defaultSupplierName: 'Дордой Контейнер 850 (Электроника)',
      defaultSupplierPhone: '+996700112233',
      qrCode: 'SMSK-KEYBOARD-RGB',
    ),
    Product(
      id: 'p2',
      name: 'Чехол силиконовый Magsafe iPhone 15 Pro',
      category: 'Чехлы',
      unit: 'штуки',
      currentStock: 120.0,
      minThreshold: 50.0,
      dailyBurnRate: 15.0,
      pricePerUnitKgs: 280.0,
      defaultSupplierName: 'Дордой Контейнер 850 (Электроника)',
      defaultSupplierPhone: '+996700112233',
      qrCode: 'SMSK-CASE-IPHONE15',
    ),
    Product(
      id: 'p3',
      name: 'Подставка алюминиевая складная для ноутбука',
      category: 'Подставки',
      unit: 'штуки',
      currentStock: 5.0,
      minThreshold: 20.0,
      dailyBurnRate: 4.0,
      pricePerUnitKgs: 850.0,
      defaultSupplierName: 'Карго Поставка из Гуанчжоу (Бакыт)',
      defaultSupplierPhone: '+996555998877',
      qrCode: 'SMSK-STAND-LAPTOP',
    ),
    Product(
      id: 'p4',
      name: 'Зарядное устройство GaN 65W (2xType-C + USB)',
      category: 'Зарядки и кабели',
      unit: 'штуки',
      currentStock: 45.0,
      minThreshold: 25.0,
      dailyBurnRate: 5.0,
      pricePerUnitKgs: 1100.0,
      defaultSupplierName: 'Дордой Контейнер 850 (Электроника)',
      defaultSupplierPhone: '+996700112233',
      qrCode: 'SMSK-CHARGER-65W',
    ),
    Product(
      id: 'p5',
      name: 'Пауэрбанк 20000 mAh 22.5W Fast Charge',
      category: 'Гаджеты',
      unit: 'штуки',
      currentStock: 18.0,
      minThreshold: 30.0,
      dailyBurnRate: 6.0,
      pricePerUnitKgs: 1650.0,
      defaultSupplierName: 'Карго Поставка из Гуанчжоу (Бакыт)',
      defaultSupplierPhone: '+996555998877',
      qrCode: 'SMSK-POWERBANK-20K',
    ),
  ];

  final List<StockTransaction> _transactions = [];

  final List<Debt> _debts = [
    Debt(
      id: 'd1',
      counterpartyName: 'Магазин "ТехноМаркет" (Улан)',
      counterpartyPhone: '+996550123456',
      type: DebtType.receivable,
      amountKgs: 32000.0,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      description: 'Партия клавиатур и чехлов (150 шт)',
    ),
    Debt(
      id: 'd2',
      counterpartyName: 'Дордой Конт 850 (Асан)',
      counterpartyPhone: '+996700112233',
      type: DebtType.payable,
      amountKgs: 54000.0,
      dueDate: DateTime.now().add(const Duration(days: 6)),
      description: 'Закупка подставок и GaN зарядок из Китая',
    ),
  ];

  final List<PurchaseOrder> _purchaseOrders = [];

  final List<AuditLog> _auditLogs = [
    AuditLog(
      id: 'log_001',
      actionType: AuditActionType.addProduct,
      title: 'Добавлен новый товар: Механическая клавиатура RGB',
      details: 'Начальный остаток: 8.0 шт.',
      userName: 'Азамат',
      userRole: 'Магазин GadgetZone',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  AppStateProvider() {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedProducts = await StorageService.loadProducts();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        _products.clear();
        _products.addAll(cachedProducts);
      }

      final cachedDebts = await StorageService.loadDebts();
      if (cachedDebts != null && cachedDebts.isNotEmpty) {
        _debts.clear();
        _debts.addAll(cachedDebts);
      }

      final cachedContacts = await StorageService.loadContacts();
      if (cachedContacts != null && cachedContacts.isNotEmpty) {
        _contacts.clear();
        _contacts.addAll(cachedContacts);
      }

      final cachedLogs = await StorageService.loadAuditLogs();
      if (cachedLogs != null && cachedLogs.isNotEmpty) {
        _auditLogs.clear();
        _auditLogs.addAll(cachedLogs);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Cache load error: $e');
    }
  }

  Future<void> _saveToCache() async {
    await StorageService.saveProducts(_products);
    await StorageService.saveDebts(_debts);
    await StorageService.saveContacts(_contacts);
    await StorageService.saveAuditLogs(_auditLogs);
  }

  // Getters
  AppLanguage get language => _language;
  AppCurrency get currency => _currency;
  double get usdExchangeRate => _usdExchangeRate;
  bool get isOnline => _isOnline;
  UserProfile get userProfile => _userProfile;
  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Product> get products => List.unmodifiable(_products);
  List<StockTransaction> get transactions => List.unmodifiable(_transactions);
  List<Debt> get debts => List.unmodifiable(_debts);
  List<PurchaseOrder> get purchaseOrders => List.unmodifiable(_purchaseOrders);
  List<AuditLog> get auditLogs => List.unmodifiable(_auditLogs);

  List<Debt> get receivables => _debts.where((d) => d.type == DebtType.receivable && !d.isPaid).toList();
  List<Debt> get payables => _debts.where((d) => d.type == DebtType.payable && !d.isPaid).toList();

  double get totalReceivablesKgs => receivables.fold(0, (sum, d) => sum + d.amountKgs);
  double get totalPayablesKgs => payables.fold(0, (sum, d) => sum + d.amountKgs);

  List<Product> get criticalProducts => _products.where((p) => p.status == StockStatus.critical || p.status == StockStatus.low).toList();

  String tr(String key, {Map<String, String>? args}) {
    return LocalizationService.tr(_language, key, args: args);
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.ru ? AppLanguage.ky : AppLanguage.ru;
    notifyListeners();
  }

  void toggleCurrency() {
    _currency = _currency == AppCurrency.kgs ? AppCurrency.usd : AppCurrency.kgs;
    notifyListeners();
  }

  void setUsdRate(double rate) {
    if (rate > 0) {
      _usdExchangeRate = rate;
      notifyListeners();
    }
  }

  String formatCurrency(double amountInKgs) {
    if (_currency == AppCurrency.usd) {
      final amountUsd = amountInKgs / _usdExchangeRate;
      return '\$${amountUsd.toStringAsFixed(2)}';
    }
    return '${amountInKgs.toStringAsFixed(0)} KGS';
  }

  void toggleNetworkMode() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void toggleUserRole() {
    final newRole = _userProfile.role == UserRole.retailer ? UserRole.wholesaler : UserRole.retailer;
    _userProfile = _userProfile.copyWith(role: newRole);
    notifyListeners();
  }

  void logAuditAction({
    required AuditActionType actionType,
    required String title,
    required String details,
  }) {
    _auditLogs.insert(
      0,
      AuditLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        actionType: actionType,
        title: title,
        details: details,
        userName: _userProfile.name,
        userRole: _userProfile.role.displayName,
        timestamp: DateTime.now(),
      ),
    );
    _saveToCache();
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    logAuditAction(
      actionType: AuditActionType.addProduct,
      title: 'Добавлен товар: ${product.name}',
      details: 'Начальный остаток: ${product.currentStock} ${product.unit}',
    );
    _saveToCache();
  }

  void addContact(Contact contact) {
    _contacts.insert(0, contact);
    _saveToCache();
    notifyListeners();
  }

  void addStockTransaction({
    required String productId,
    required TransactionType type,
    required double quantity,
    required String note,
  }) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex == -1) return;

    final product = _products[productIndex];
    if (type == TransactionType.stockIn) {
      product.currentStock += quantity;
    } else {
      product.currentStock = (product.currentStock - quantity).clamp(0, double.infinity);
    }

    _transactions.insert(
      0,
      StockTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: product.name,
        type: type,
        quantity: quantity,
        unit: product.unit,
        timestamp: DateTime.now(),
        note: note,
      ),
    );

    logAuditAction(
      actionType: type == TransactionType.stockIn ? AuditActionType.stockIn : AuditActionType.stockOut,
      title: '${type == TransactionType.stockIn ? "Приход" : "Продажа"}: ${product.name}',
      details: 'Изменение: ${type == TransactionType.stockIn ? "+" : "-"}$quantity ${product.unit} | Остаток: ${product.currentStock}',
    );

    _saveToCache();
  }

  int importFromCsv(String csvText) {
    int imported = 0;
    final lines = csvText.split('\n');
    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length >= 3) {
        final name = parts[0].trim();
        final qty = double.tryParse(parts[1].trim()) ?? 0;
        final unit = parts[2].trim();
        final price = parts.length >= 4 ? (double.tryParse(parts[3].trim()) ?? 100.0) : 100.0;
        if (name.isNotEmpty && name != 'Название' && name != 'Name') {
          addProduct(
            Product(
              id: 'imp_${DateTime.now().microsecondsSinceEpoch}_$imported',
              name: name,
              category: 'Импортированные',
              unit: unit.isEmpty ? 'штук' : unit,
              currentStock: qty,
              minThreshold: 10.0,
              dailyBurnRate: 2.0,
              pricePerUnitKgs: price,
            ),
          );
          imported++;
        }
      }
    }
    if (imported > 0) {
      logAuditAction(
        actionType: AuditActionType.importCsv,
        title: 'Импорт из Google Таблиц',
        details: 'Загружено $imported новых позиций товаров',
      );
    }
    return imported;
  }

  void addDebt(Debt debt) {
    _debts.insert(0, debt);
    logAuditAction(
      actionType: AuditActionType.addDebt,
      title: 'Записан долг: ${debt.counterpartyName}',
      details: 'Сумма: ${debt.amountKgs} KGS (${debt.type == DebtType.receivable ? "Мне должны" : "Я должен"})',
    );
    _saveToCache();
  }

  void markDebtPaid(String debtId) {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index != -1) {
      _debts[index].isPaid = true;
      logAuditAction(
        actionType: AuditActionType.payDebt,
        title: 'Долг погашен: ${_debts[index].counterpartyName}',
        details: 'Сумма: ${_debts[index].amountKgs} KGS',
      );
      _saveToCache();
    }
  }

  PurchaseOrder createQuickPurchaseOrder(Product product, double orderQuantity) {
    final orderItem = PurchaseOrderItem(
      productName: product.name,
      quantity: orderQuantity,
      unit: product.unit,
      pricePerUnitKgs: product.pricePerUnitKgs,
    );

    final po = PurchaseOrder(
      id: 'po_${DateTime.now().millisecondsSinceEpoch}',
      supplierName: product.defaultSupplierName,
      supplierPhone: product.defaultSupplierPhone,
      items: [orderItem],
      status: OrderStatus.sent,
      createdAt: DateTime.now(),
    );

    _purchaseOrders.insert(0, po);
    notifyListeners();
    return po;
  }
}
