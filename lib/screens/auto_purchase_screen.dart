import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_state_provider.dart';
import '../services/messenger_service.dart';
import '../widgets/add_purchase_order_dialog.dart';

class AutoPurchaseScreen extends StatelessWidget {
  const AutoPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isRetailer = appState.userProfile.role == UserRole.retailer;
    final criticals = appState.criticalProducts;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          isRetailer ? 'Авто-закупки гаджетов' : 'Входящие оптовые заказы',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Предиктивный баннер
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_graph, color: Color(0xFF3B82F6), size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isRetailer ? 'Аналитика спроса и риск дефицита' : 'Спрос розничных точек Дордоя',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isRetailer
                        ? 'На основе скорости продаж дефицитные позиции закончится через ${criticals.isNotEmpty ? criticals.first.daysRemaining : 5} дней. Рекомендуется отправить закупку оптовику на Дордой или в Карго.'
                        : 'В этом месяце повышенный спрос на Механические клавиатуры и GaN зарядки 65W. Рекомендуется сформировать приход крупной партии из Китая.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Раздел алертов дефицита
            Text(
              isRetailer ? 'Алерты закончивающихся гаджетов' : 'Заявки от розничных магазинов',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            if (criticals.isEmpty)
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Все товары в наличии! Срочных закупать не требуется.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: criticals.length,
                itemBuilder: (context, index) {
                  final product = criticals[index];
                  final days = product.daysRemaining;

                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${product.name} закончится через $days дн.!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Остаток: ${product.currentStock} ${product.unit} (Порог: ${product.minThreshold} ${product.unit})',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Поставщик: ${product.defaultSupplierName} (${product.defaultSupplierPhone})',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Кнопка генерации Purchase Order в 1 клик
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text(
                                'Сформировать заказ в 1 клик (WhatsApp)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () async {
                                final po = appState.createQuickPurchaseOrder(product, 30.0);
                                final success = await MessengerService.sendPurchaseOrderWhatsApp(po);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Заявка отправлена оптовику на Дордой!')),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // История закупленных заявок
            const Text(
              'История сформированных заявок (PO)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            if (appState.purchaseOrders.isEmpty)
              const Text('Заявок пока нет', style: TextStyle(color: Colors.white54))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.purchaseOrders.length,
                itemBuilder: (context, index) {
                  final po = appState.purchaseOrders[index];
                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        'Заказ для ${po.supplierName}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Позиций: ${po.items.length} | Итого: ${po.totalAmountKgs.toStringAsFixed(0)} KGS',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Добавить в закупку'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddPurchaseOrderDialog(),
          );
        },
      ),
    );
  }
}
