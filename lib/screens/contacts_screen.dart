import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/app_state_provider.dart';
import '../widgets/add_contact_dialog.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final contacts = appState.contacts;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Контакты & Поставщики', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('Контактов пока нет', style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (ctx, i) {
                final c = contacts[i];
                final isSupplier = c.role == ContactRole.supplier;
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSupplier ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : const Color(0xFF10B981).withValues(alpha: 0.2),
                      child: Icon(
                        isSupplier ? Icons.storefront : Icons.precision_manufacturing,
                        color: isSupplier ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                      ),
                    ),
                    title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${c.phone}\n${c.location}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    isThreeLine: c.location.isNotEmpty,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить контакт'),
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddContactDialog());
        },
      ),
    );
  }
}
