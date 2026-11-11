import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_state_provider.dart';
import '../widgets/stock_status_badge.dart';
import '../widgets/quick_transaction_dialog.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/csv_import_dialog.dart';
import '../widgets/qr_scanner_dialog.dart';
import 'cost_calculator_screen.dart';
import 'audit_logs_screen.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  String _selectedCategory = 'Все';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isRetailer = appState.userProfile.role == UserRole.retailer;
    final categories = ['Все', 'Клавиатуры', 'Чехлы', 'Подставки', 'Зарядки и кабели', 'Гаджеты'];

    final filteredProducts = appState.products.where((p) {
      final matchesCategory = _selectedCategory == 'Все' || p.category == _selectedCategory;
      final matchesQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRetailer ? 'Склад & Точки (Продавец)' : 'Склад & Опт (Дордой)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              isRetailer ? 'Учет клавиатур, чехлов и подставок' : 'Партии электроники и заказы с Дордоя',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate, color: Color(0xFF10B981)),
            tooltip: 'Калькулятор карго и маржи',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CostCalculatorScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF38BDF8)),
            tooltip: 'Журнал аудита операций',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF3B82F6)),
            tooltip: 'Сканер Камеры QR',
            onPressed: () {
              showDialog(context: context, builder: (_) => const QrScannerDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart, color: Color(0xFFF59E0B)),
            tooltip: 'Импорт из Google Таблиц',
            onPressed: () {
              showDialog(context: context, builder: (_) => const CsvImportDialog());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: appState.tr('search_hint'),
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
              ),
            ),
          ),

          // Категории
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3B82F6),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Список товаров с кнопками "+" и "-"
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Товары не найдены', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final fillRatio = product.fillRatio;
                      final daysRemaining = product.daysRemaining;

                      Color progressColor;
                      if (fillRatio < 0.2) {
                        progressColor = const Color(0xFFEF4444);
                      } else if (fillRatio < 0.5) {
                        progressColor = const Color(0xFFF59E0B);
                      } else {
                        progressColor = const Color(0xFF10B981);
                      }

                      return Card(
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StockStatusBadge(status: product.status),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Прогресс бар заполненности остатка
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: fillRatio,
                                  minHeight: 6,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Остаток: ${product.currentStock} ${product.unit}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          appState.tr('days_left', args: {'days': '$daysRemaining'}),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: daysRemaining < 3 ? const Color(0xFFEF4444) : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Компактные кнопки "+" и "-"
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(0xFFEF4444),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(38, 38),
                                          padding: EdgeInsets.zero,
                                        ),
                                        icon: const Icon(Icons.remove, size: 20),
                                        tooltip: 'Продажа (-)',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => QuickTransactionDialog(product: product),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(38, 38),
                                          padding: EdgeInsets.zero,
                                        ),
                                        icon: const Icon(Icons.add, size: 20),
                                        tooltip: 'Приход (+)',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => QuickTransactionDialog(product: product),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_box),
        label: Text(appState.tr('add_product')),
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddProductDialog());
        },
      ),
    );
  }
}
