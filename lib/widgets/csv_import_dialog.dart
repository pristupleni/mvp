import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog({Key? key}) : super(key: key);

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  final _urlController = TextEditingController();
  final _csvTextController = TextEditingController(
    text: 'Ткань Джинс, 250, метры, 450\nНитки №50, 100, штуки, 80\nМолния 70см, 300, штуки, 25',
  );

  @override
  void dispose() {
    _urlController.dispose();
    _csvTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.table_chart, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text('Импорт из Google Таблиц', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вставьте ссылку на опубликую Google Таблицу или данные CSV:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://docs.google.com/spreadsheets/...',
                hintStyle: const TextStyle(color: Colors.white38),
                labelText: 'Ссылка на Google Sheet (CSV)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Или вставьте текст таблицы (Название, Количество, Ед.изм, Цена KGS):', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _csvTextController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final text = _csvTextController.text.trim();
            final count = context.read<AppStateProvider>().importFromCsv(text);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Успешно импортировано $count позиций в склад!')),
            );
          },
          child: const Text('Загрузить данные'),
        ),
      ],
    );
  }
}
