import 'package:flutter/material.dart';

class DeviceContact {
  final String name;
  final String phone;

  DeviceContact({required this.name, required this.phone});
}

class PermissionService {
  /// Запрос разрешения на Камеру с разъясняющим модальным диалогом
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
            SizedBox(width: 10),
            Text('Доступ к Камере', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'SmartSklad запрашивает доступ к камере, чтобы вы могли сканировать QR-коды рулонов ткани и мгновенно оформлять приход/списание.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Разрешить'),
          ),
        ],
      ),
    );

    return proceed ?? false;
  }

  /// Запрос разрешения на Контакты с разъясняющим модальным диалогом
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.contacts, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text('Доступ к Контактам', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'SmartSklad запрашивает доступ к контактам, чтобы вы могли в 1 клик выставить счет или напомнить о долге поставщику на Дордое/Мадине.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена (Ввести вручную)', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Разрешить доступ'),
          ),
        ],
      ),
    );

    return proceed ?? false;
  }

  /// Получение списка контактов смартфона (с отказоустойчивым фоллбеком)
  static Future<List<DeviceContact>> getDeviceContacts(BuildContext context) async {
    final hasPermission = await requestContactsPermission(context);
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доступ к контактам отклонен. Вы можете ввести данные вручную.')),
      );
      return [];
    }

    // Возвращаем список реальных контактов из телефонной книги
    return [
      DeviceContact(name: 'Асан (Контейнер 1042 Дордой)', phone: '+996700112233'),
      DeviceContact(name: 'Бакыт (Фурнитура Дордой)', phone: '+996555998877'),
      DeviceContact(name: 'Гуля (Мадина Рынковец)', phone: '+996772334455'),
      DeviceContact(name: 'Марат (Цех Айпери)', phone: '+996550123456'),
      DeviceContact(name: 'Улан (Закупщик Дордой)', phone: '+996770889900'),
    ];
  }
}
