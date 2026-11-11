import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/audit_log.dart';
import '../providers/app_state_provider.dart';

class CostCalculatorScreen extends StatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  final _nameController = TextEditingController(text: 'Механическая клавиатура RGB 75%');
  final _quantityController = TextEditingController(text: '200');
  final _purchasePriceController = TextEditingController(text: '1200');
  final _cargoController = TextEditingController(text: '180');
  final _packagingController = TextEditingController(text: '40');
  final _extraCostsController = TextEditingController(text: '30');

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _cargoController.dispose();
    _packagingController.dispose();
    _extraCostsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isUsd = appState.currency == AppCurrency.usd;
    final rate = appState.usdExchangeRate;

    final batchQty = double.tryParse(_quantityController.text) ?? 1.0;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final cargoCost = double.tryParse(_cargoController.text) ?? 0.0;
    final packaging = double.tryParse(_packagingController.text) ?? 0.0;
    final extraCosts = double.tryParse(_extraCostsController.text) ?? 0.0;

    // Расчет себестоимости 1 шт. товара с доставкой и карго в KGS
    final unitTotalCostKgs = purchasePrice + cargoCost + packaging + extraCosts;

    // Общая стоимость всей закупаемой партии в KGS
    final totalBatchCostKgs = unitTotalCostKgs * batchQty;

    // Рекомендуемая розничная цена с маржой 40%
    final recommendedRetailKgs = unitTotalCostKgs * 1.40;
    final estimatedBatchProfitKgs = (recommendedRetailKgs - unitTotalCostKgs) * batchQty;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          appState.tr('cost_calculator'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Переключатель валют (KGS / USD)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF38BDF8)),
            icon: const Icon(Icons.currency_exchange, size: 18),
            label: Text(
              isUsd ? 'USD (\$$rate)' : 'KGS (Сом)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => appState.toggleCurrency(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле наименования товара / гаджета
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Наименование товара / гаджета',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Ввод параметров закупки
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Закупка, карго и доставка из Китая', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildInputField(_quantityController, appState.tr('batch_quantity'), Icons.format_list_numbered),
                    const SizedBox(height: 10),
                    _buildInputField(_purchasePriceController, 'Закупочная цена 1 шт. (KGS)', Icons.shopping_bag),
                    const SizedBox(height: 10),
                    _buildInputField(_cargoController, appState.tr('accessories_cost'), Icons.local_shipping),
                    const SizedBox(height: 10),
                    _buildInputField(_packagingController, 'Упаковка и наклейка штрихкода (KGS)', Icons.inventory),
                    const SizedBox(height: 10),
                    _buildInputField(_extraCostsController, appState.tr('extra_costs'), Icons.account_balance_wallet),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Карточка результатов расчета маржи
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appState.tr('unit_cost'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        appState.formatCurrency(unitTotalCostKgs),
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appState.tr('total_batch_cost'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        appState.formatCurrency(totalBatchCostKgs),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appState.tr('recommended_price'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(
                        appState.formatCurrency(recommendedRetailKgs),
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ожидаемая прибыль партии', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(
                        appState.formatCurrency(estimatedBatchProfitKgs),
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка сохранения в прайс
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Сохранить и внести в Склад/Прайс', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final newProduct = Product(
                    id: 'calc_${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameController.text.trim(),
                    category: 'Гаджеты & Электроника',
                    unit: 'штуки',
                    currentStock: batchQty,
                    minThreshold: 15.0,
                    dailyBurnRate: 5.0,
                    pricePerUnitKgs: recommendedRetailKgs,
                  );
                  appState.addProduct(newProduct);
                  appState.logAuditAction(
                    actionType: AuditActionType.addProduct,
                    title: 'Закупка электроники: ${_nameController.text.trim()}',
                    details: 'Себестоимость: ${unitTotalCostKgs.toStringAsFixed(0)} KGS | Партия: $batchQty шт.',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Товар "${_nameController.text}" добавлен на Склад!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
