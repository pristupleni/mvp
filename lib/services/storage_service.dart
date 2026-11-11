import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/debt.dart';
import '../models/contact.dart';
import '../models/audit_log.dart';

class StorageService {
  static const String _keyProducts = 'smartsklad_products';
  static const String _keyDebts = 'smartsklad_debts';
  static const String _keyContacts = 'smartsklad_contacts';
  static const String _keyLogs = 'smartsklad_audit_logs';

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_keyProducts, jsonEncode(jsonList));
  }

  static Future<List<Product>?> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyProducts);
    if (str == null) return null;
    final List list = jsonDecode(str);
    return list.map((i) => Product.fromJson(i)).toList();
  }

  static Future<void> saveDebts(List<Debt> debts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = debts.map((d) => d.toJson()).toList();
    await prefs.setString(_keyDebts, jsonEncode(jsonList));
  }

  static Future<List<Debt>?> loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyDebts);
    if (str == null) return null;
    final List list = jsonDecode(str);
    return list.map((i) => Debt.fromJson(i)).toList();
  }

  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_keyContacts, jsonEncode(jsonList));
  }

  static Future<List<Contact>?> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyContacts);
    if (str == null) return null;
    final List list = jsonDecode(str);
    return list.map((i) => Contact.fromJson(i)).toList();
  }

  static Future<void> saveAuditLogs(List<AuditLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_keyLogs, jsonEncode(jsonList));
  }

  static Future<List<AuditLog>?> loadAuditLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyLogs);
    if (str == null) return null;
    final List list = jsonDecode(str);
    return list.map((i) => AuditLog.fromJson(i)).toList();
  }
}
