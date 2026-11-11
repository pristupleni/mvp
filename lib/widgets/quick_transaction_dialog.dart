import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../providers/app_state_provider.dart';

class QuickTransactionDialog extends StatefulWidget {
  final Product product;

  const QuickTransactionDialog({super.key, required this.product});

  @override
  State<QuickTransactionDialog> createState() => _QuickTransactionDialogState();
}

class _QuickTransactionDialogState extends State<QuickTransactionDialog> {
  TransactionType _type = TransactionType.stockIn;
  final TextEditingController _quantityController = TextEditingController(text: '10');
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Текущий остаток: ${widget.product.currentStock} ${widget.product.unit}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<TransactionType>(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _type == TransactionType.stockIn ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  }
                  return const Color(0xFF0F172A);
                }),
              ),
              segments: const [
                ButtonSegment(
                  value: TransactionType.stockIn,
                  label: Text('Приход (+)'),
                  icon: Icon(Icons.add_circle_outline, color: Colors.white),
                ),
                ButtonSegment(
                  value: TransactionType.stockOut,
                  label: Text('Списание (-)'),
                  icon: Icon(Icons.remove_circle_outline, color: Colors.white),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Количество (${widget.product.unit})',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(
                  _type == TransactionType.stockIn ? Icons.add : Icons.remove,
                  color: _type == TransactionType.stockIn ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Примечание (Партия / Цех)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
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
            backgroundColor: _type == TransactionType.stockIn ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final qty = double.tryParse(_quantityController.text) ?? 0.0;
            if (qty > 0) {
              context.read<AppStateProvider>().addStockTransaction(
                productId: widget.product.id,
                type: _type,
                quantity: qty,
                note: _noteController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(_type == TransactionType.stockIn ? 'Сохранить приход' : 'Сохранить списание'),
        ),
      ],
    );
  }
}
