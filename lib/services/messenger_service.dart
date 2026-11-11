import 'package:url_launcher/url_launcher.dart';
import '../models/debt.dart';
import '../models/purchase_order.dart';

class MessengerService {
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '').replaceAll('+', '');
  }

  static String generateWhatsAppUrl(String phone, String message) {
    final cleanPhone = cleanPhoneNumber(phone);
    final encodedMsg = Uri.encodeComponent(message);
    return 'https://wa.me/$cleanPhone?text=$encodedMsg';
  }

  static String generateTelegramUrl(String phone, String message) {
    final encodedMsg = Uri.encodeComponent(message);
    return 'https://t.me/share/url?url=&text=$encodedMsg';
  }

  static Future<bool> sendDebtReminderWhatsApp(Debt debt) async {
    final isReceivable = debt.type == DebtType.receivable;
    final message = isReceivable
        ? 'Салам! Напоминание по взаиморасчетам [${debt.counterpartyName}]:\n\n'
          'Сумма долга: ${debt.amountKgs.toStringAsFixed(0)} сом (KGS)\n'
          'Детали: ${debt.description}\n'
          'Срок оплаты: ${debt.dueDate.day}.${debt.dueDate.month}.${debt.dueDate.year}\n\n'
          'Просьба подтвердить дату перевода. Рахмат!'
        : 'Салам! Напоминаю про задолженность за сырье:\n\n'
          'Сумма: ${debt.amountKgs.toStringAsFixed(0)} сом (KGS)\n'
          'За: ${debt.description}\n'
          'Оплачу до: ${debt.dueDate.day}.${debt.dueDate.month}.${debt.dueDate.year}.\n\n'
          'Спасибо за ожидание!';

    final url = Uri.parse(generateWhatsAppUrl(debt.counterpartyPhone, message));
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> sendDebtReminderTelegram(Debt debt) async {
    final message = 'Салам! Напоминание по взаиморасчетам [${debt.counterpartyName}]:\n'
        'Сумма: ${debt.amountKgs.toStringAsFixed(0)} KGS\n'
        'Детали: ${debt.description}\n'
        'Срок: ${debt.dueDate.day}.${debt.dueDate.month}.${debt.dueDate.year}';

    final url = Uri.parse(generateTelegramUrl(debt.counterpartyPhone, message));
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> sendPurchaseOrderWhatsApp(PurchaseOrder order) async {
    final itemsList = order.items.map((it) => '• ${it.productName}: ${it.quantity} ${it.unit} (${it.totalPriceKgs.toStringAsFixed(0)} сом)').join('\n');

    final message = 'Салам Алейкум, ${order.supplierName}!\n\n'
        'Сформирован новый заказ на сырье:\n'
        '$itemsList\n\n'
        'Итого: ${order.totalAmountKgs.toStringAsFixed(0)} сом (KGS)\n'
        'Дата заявки: ${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}\n\n'
        'Просьба подтвердить наличие на контейнере на Дордое/Мадине. Рахмат!';

    final url = Uri.parse(generateWhatsAppUrl(order.supplierPhone, message));
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
