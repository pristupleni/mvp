import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/purchase_order.dart';
import '../providers/app_state_provider.dart';
import '../services/messenger_service.dart';

class AddPurchaseOrderDialog extends StatefulWidget {
  const AddPurchaseOrderDialog({super.key});

  @override
  State<AddPurchaseOrderDialog> createState() => _AddPurchaseOrderDialogState();
}

class _AddPurchaseOrderDialogState extends State<AddPurchaseOrderDialog> {
  final _productNameController = TextEditingController(text: 'Ткань Двунитка (Черный)');
  final _quantityController = TextEditingController(text: '100');
  final _priceController = TextEditingController(text: '320');
  String _unit = 'метры';
  String _supplierName = 'Контейнер 1042 (Асан)';
  String _supplierPhone = '+996700112233';

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.add_shopping_cart, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text('Добавить позицию в авто-закуп', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Выбор имеющегося товара или ввод вручную
            if (appState.products.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Выбрать из склада сырья',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: appState.products
                    .map((p) => DropdownMenuItem(value: p.name, child: Text(p.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    final selectedP = appState.products.firstWhere((p) => p.name == val);
                    setState(() {
                      _productNameController.text = selectedP.name;
                      _unit = selectedP.unit;
                      _priceController.text = selectedP.pricePerUnitKgs.toStringAsFixed(0);
                      _supplierName = selectedP.defaultSupplierName;
                      _supplierPhone = selectedP.defaultSupplierPhone;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
            ],

            TextField(
              controller: _productNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Наименование сырья / материала',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Количество',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E293B),
                    value: _unit,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Ед. изм.',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['метры', 'рулоны', 'штуки', 'кг']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unit = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ориентировочная цена за ед. (KGS)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Выбор поставщика из контактов
            if (appState.contacts.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Поставщик (Дордой/Мадина)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: appState.contacts
                    .map((c) => DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.phone})')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    final selectedC = appState.contacts.firstWhere((c) => c.name == val);
                    setState(() {
                      _supplierName = selectedC.name;
                      _supplierPhone = selectedC.phone;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final qty = double.tryParse(_quantityController.text) ?? 1.0;
            final price = double.tryParse(_priceController.text) ?? 100.0;
            final name = _productNameController.text.trim();

            if (name.isNotEmpty) {
              final poItem = PurchaseOrderItem(
                productName: name,
                quantity: qty,
                unit: _unit,
                pricePerUnitKgs: price,
              );

              final po = PurchaseOrder(
                id: 'po_${DateTime.now().millisecondsSinceEpoch}',
                supplierName: _supplierName,
                supplierPhone: _supplierPhone,
                items: [poItem],
                status: OrderStatus.sent,
                createdAt: DateTime.now(),
              );

              context.read<AppStateProvider>().createQuickPurchaseOrder(
                Product(
                  id: 'temp',
                  name: name,
                  category: 'Закуп',
                  unit: _unit,
                  currentStock: 0,
                  minThreshold: 10,
                  dailyBurnRate: 1,
                  pricePerUnitKgs: price,
                  defaultSupplierName: _supplierName,
                  defaultSupplierPhone: _supplierPhone,
                ),
                qty,
              );

              Navigator.of(context).pop();

              final success = await MessengerService.sendPurchaseOrderWhatsApp(po);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Заявка на "$name" отправлена в WhatsApp!')),
                );
              }
            }
          },
          child: const Text('Сформировать и отправить'),
        ),
      ],
    );
  }
}
