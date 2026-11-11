import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_transaction.dart';
import '../providers/app_state_provider.dart';
import '../services/permission_service.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  bool _isScanned = false;
  bool _hasCameraPermission = true;
  String _scannedProductCode = '';
  final TextEditingController _amountController = TextEditingController(text: '20');

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final granted = await PermissionService.requestCameraPermission(context);
      if (mounted) {
        setState(() {
          _hasCameraPermission = granted;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final products = appState.products;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isScanned ? 'Рулон распознан!' : 'Сканер Камеры QR',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isScanned) ...[
              // Имитация живой камеры с прицелом
              GestureDetector(
                onTap: () {
                  if (products.isNotEmpty) {
                    setState(() {
                      _isScanned = true;
                      _scannedProductCode = products.first.id;
                    });
                  }
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasCameraPermission ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.center_focus_strong,
                        color: _hasCameraPermission ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                        size: 54,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          _hasCameraPermission
                              ? 'Камера активна! Нажмите на область для считывания'
                              : 'Ожидание разрешения камеры...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Или выберите товар из списка (Фоллбек):', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        p.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('QR: ${p.qrCode}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                      onTap: () {
                        setState(() {
                          _isScanned = true;
                          _scannedProductCode = p.id;
                        });
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Ввод количества после сканирования
              Builder(
                builder: (context) {
                  final scannedProduct = products.firstWhere((p) => p.id == _scannedProductCode, orElse: () => products.first);
                  return Column(
                    children: [
                      Text(
                        scannedProduct.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Текущий остаток: ${scannedProduct.currentStock} ${scannedProduct.unit}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Введите количество',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.add_circle, size: 18),
                              label: const Text('+ Приход'),
                              onPressed: () {
                                final qty = double.tryParse(_amountController.text) ?? 0;
                                appState.addStockTransaction(
                                  productId: scannedProduct.id,
                                  type: TransactionType.stockIn,
                                  quantity: qty,
                                  note: 'QR Сканер Камеры',
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.remove_circle, size: 18),
                              label: const Text('- Списание'),
                              onPressed: () {
                                final qty = double.tryParse(_amountController.text) ?? 0;
                                appState.addStockTransaction(
                                  productId: scannedProduct.id,
                                  type: TransactionType.stockOut,
                                  quantity: qty,
                                  note: 'QR Сканер Камеры',
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
