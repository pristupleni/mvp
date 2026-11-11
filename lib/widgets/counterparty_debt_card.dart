import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../services/messenger_service.dart';
import '../providers/app_state_provider.dart';

class CounterpartyDebtCard extends StatelessWidget {
  final Debt debt;

  const CounterpartyDebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ru_RU');
    final isReceivable = debt.type == DebtType.receivable;
    final statusColor = isReceivable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Card(
      color: const Color(0xFF1E293B),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: statusColor.withValues(alpha: 0.18),
                        child: Icon(
                          isReceivable ? Icons.arrow_downward : Icons.arrow_upward,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debt.counterpartyName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              debt.counterpartyPhone,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${currencyFormatter.format(debt.amountKgs)} KGS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      isReceivable ? 'Мне должны' : 'Я должен',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.white12),
            Text(
              'Детали: ${debt.description}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Text(
                  'Оплата до: ${debt.dueDate.day}.${debt.dueDate.month}.${debt.dueDate.year}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Быстрые кнопки мессенджеров
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      MessengerService.sendDebtReminderWhatsApp(debt);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Telegram', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      MessengerService.sendDebtReminderTelegram(debt);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Отметить как оплачено',
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white38),
                  onPressed: () {
                    context.read<AppStateProvider>().markDebtPaid(debt.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
