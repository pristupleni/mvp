import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/app_state_provider.dart';
import '../services/permission_service.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+996');
  final _locationController = TextEditingController();
  ContactRole _role = ContactRole.supplier;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickFromPhoneBook() async {
    final deviceContacts = await PermissionService.getDeviceContacts(context);
    if (deviceContacts.isNotEmpty && mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E293B),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) {
          return ListView.builder(
            itemCount: deviceContacts.length,
            itemBuilder: (context, index) {
              final c = deviceContacts[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF3B82F6),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(c.phone, style: const TextStyle(color: Colors.white70)),
                onTap: () {
                  setState(() {
                    _nameController.text = c.name;
                    _phoneController.text = c.phone;
                  });
                  Navigator.of(ctx).pop();
                },
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Добавить новый контакт', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              icon: const Icon(Icons.contacts, size: 18),
              label: const Text('Выбрать из контактов телефона', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: _pickFromPhoneBook,
            ),
            const SizedBox(height: 12),

            SegmentedButton<ContactRole>(
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
                ButtonSegment(value: ContactRole.supplier, label: Text('Поставщик')),
                ButtonSegment(value: ContactRole.workshop, label: Text('Цех / Покупатель')),
              ],
              selected: {_role},
              onSelectionChanged: (val) => setState(() => _role = val.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Имя / Контейнер / Цех',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Телефон (+996...)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Адрес / Контейнер (Дордой/Мадина)',
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
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              final newContact = Contact(
                id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                role: _role,
                location: _locationController.text.trim(),
              );
              context.read<AppStateProvider>().addContact(newContact);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
