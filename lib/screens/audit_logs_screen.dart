import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_log.dart';
import '../providers/app_state_provider.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final logs = appState.auditLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          appState.tr('audit_logs'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
      body: logs.isEmpty
          ? const Center(child: Text('История операций пуста', style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (ctx, i) {
                final log = logs[i];
                Color badgeColor;
                IconData icon;

                switch (log.actionType) {
                  case AuditActionType.stockIn:
                    badgeColor = const Color(0xFF10B981);
                    icon = Icons.add_circle_outline;
                    break;
                  case AuditActionType.stockOut:
                    badgeColor = const Color(0xFFEF4444);
                    icon = Icons.remove_circle_outline;
                    break;
                  case AuditActionType.addProduct:
                    badgeColor = const Color(0xFF3B82F6);
                    icon = Icons.add_box;
                    break;
                  case AuditActionType.addDebt:
                    badgeColor = const Color(0xFFF59E0B);
                    icon = Icons.account_balance_wallet;
                    break;
                  case AuditActionType.payDebt:
                    badgeColor = const Color(0xFF10B981);
                    icon = Icons.check_circle_outline;
                    break;
                  case AuditActionType.importCsv:
                    badgeColor = const Color(0xFF38BDF8);
                    icon = Icons.table_chart;
                    break;
                }

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: badgeColor.withValues(alpha: 0.18),
                          child: Icon(icon, color: badgeColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                log.details,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Пользователь: ${log.userName} (${log.userRole})',
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                  Text(
                                    '${log.timestamp.day}.${log.timestamp.month} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
