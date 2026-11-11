import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_state_provider.dart';
import '../services/localization_service.dart';
import 'contacts_screen.dart';
import 'cost_calculator_screen.dart';
import 'audit_logs_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final profile = appState.userProfile;
    final isRetailer = profile.role == UserRole.retailer;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          appState.tr('profile'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Карточка аккаунта
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: Text(
                      profile.name[0],
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(profile.phone, style: const TextStyle(color: Colors.white70)),
                        Text(profile.location, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Раздел бизнес-инструментов
          const Text('Бизнес-инструменты', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calculate, color: Color(0xFF10B981)),
                  title: Text(appState.tr('cost_calculator'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Расчет себестоимости закупки, карго из Китая и маржи', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CostCalculatorScreen()),
                    );
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFF3B82F6)),
                  title: Text(appState.tr('audit_logs'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Всего записей аудита: ${appState.auditLogs.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Раздел роли пользователя
          const Text('Роль и адаптация UI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(
                isRetailer ? Icons.storefront : Icons.local_shipping,
                color: const Color(0xFF3B82F6),
              ),
              title: Text(
                profile.role.displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                isRetailer
                    ? 'Главный акцент: Учет клавиатур/чехлов, алерты закончивающихся гаджетов'
                    : 'Главный акцент: Входящие оптовые заказы, партии из Китая, дебиторка точек',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              value: profile.role == UserRole.wholesaler,
              onChanged: (_) {
                appState.toggleUserRole();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Роль изменена на: ${appState.userProfile.role.displayName}'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Раздел настроек и языка
          const Text('Настройки & Язык', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Языковой переключатель Русский ↔ Кыргызча
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF3B82F6)),
                  title: const Text('Язык приложения', style: TextStyle(color: Colors.white)),
                  trailing: SegmentedButton<AppLanguage>(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF3B82F6);
                        }
                        return const Color(0xFF0F172A);
                      }),
                    ),
                    segments: const [
                      ButtonSegment(value: AppLanguage.ru, label: Text('РУС')),
                      ButtonSegment(value: AppLanguage.ky, label: Text('КЫР')),
                    ],
                    selected: {appState.language},
                    onSelectionChanged: (_) => appState.toggleLanguage(),
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),

                // Статус соединения
                ListTile(
                  leading: Icon(
                    appState.isOnline ? Icons.wifi : Icons.wifi_off,
                    color: appState.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                  title: const Text('Режим работы сети', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    appState.isOnline ? 'Онлайн синхронизация активна' : 'Офлайн режим (Все данные в телефоне)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: Switch(
                    value: appState.isOnline,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (_) => appState.toggleNetworkMode(),
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),

                // Переход к справочнику контактов
                ListTile(
                  leading: const Icon(Icons.contacts, color: Color(0xFF38BDF8)),
                  title: const Text('Справочник контактов', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Всего контактов: ${appState.contacts.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContactsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Кнопки экспорта
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.table_chart),
                  label: Text(appState.tr('export_excel')),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отчет по остаткам сформирован в Excel (.xlsx)')),
                    );
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
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(appState.tr('export_pdf')),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Акт сверки экспортирован в PDF')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
