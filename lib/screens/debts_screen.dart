import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/app_state_provider.dart';
import '../widgets/counterparty_debt_card.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isRetailer = appState.userProfile.role.name == 'retailer';
    final currencyFormatter = NumberFormat('#,##0', 'ru_RU');

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRetailer ? 'Долги & Расчеты (Продавец)' : 'Дебиторка & Магазины (Оптовик)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            Text(
              isRetailer ? 'Учет задолженностей перед оптовиками Дордоя' : 'Учет долгов розничных магазинов за электронику',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF3B82F6),
          tabs: [
            Tab(text: '${appState.tr('receivables')} (${appState.receivables.length})'),
            Tab(text: '${appState.tr('payables')} (${appState.payables.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Сводная финансовая плашка (KGS)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(appState.tr('receivables'), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(
                      '${currencyFormatter.format(appState.totalReceivablesKgs)} KGS',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Container(height: 32, width: 1, color: Colors.white24),
                Column(
                  children: [
                    Text(appState.tr('payables'), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(
                      '${currencyFormatter.format(appState.totalPayablesKgs)} KGS',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Списки долгов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList(appState.receivables, 'У вас нет активных должников'),
                _buildDebtList(appState.payables, 'У вас нет активных задолженностей'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(appState.tr('add_debt')),
        onPressed: () => _showAddDebtDialog(context),
      ),
    );
  }

  Widget _buildDebtList(List<Debt> debtsList, String emptyMessage) {
    if (debtsList.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.white54, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: debtsList.length,
      itemBuilder: (context, index) {
        return CounterpartyDebtCard(debt: debtsList[index]);
      },
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController(text: '+996');
    final amountController = TextEditingController();
    final descController = TextEditingController();
    DebtType debtType = DebtType.receivable;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Записать новый долг (KGS)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<DebtType>(
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
                        ButtonSegment(value: DebtType.receivable, label: Text('Мне должны')),
                        ButtonSegment(value: DebtType.payable, label: Text('Я должен')),
                      ],
                      selected: {debtType},
                      onSelectionChanged: (val) {
                        setDialogState(() => debtType = val.first);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Выбор из списка контактов
                    if (appState.contacts.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Выбрать из ваших контактов',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: appState.contacts
                            .map((c) => DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.phone})')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selectedContact = appState.contacts.firstWhere((c) => c.name == val);
                            nameController.text = selectedContact.name;
                            phoneController.text = selectedContact.phone;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Контрагент (Магазин / Контейнер / Имя)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Сумма в сомах (KGS)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Детали (за какие клавиатуры/чехлы)',
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
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (nameController.text.isNotEmpty && amount > 0) {
                      final newDebt = Debt(
                        id: 'd_${DateTime.now().millisecondsSinceEpoch}',
                        counterpartyName: nameController.text,
                        counterpartyPhone: phoneController.text,
                        type: debtType,
                        amountKgs: amount,
                        dueDate: DateTime.now().add(const Duration(days: 7)),
                        description: descController.text,
                      );
                      context.read<AppStateProvider>().addDebt(newDebt);
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
