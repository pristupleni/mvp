import 'package:flutter/material.dart';
import '../models/product.dart';

class StockStatusBadge extends StatelessWidget {
  final StockStatus status;

  const StockStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case StockStatus.normal:
        color = const Color(0xFF10B981); // Emerald Green
        label = 'Норма';
        icon = Icons.check_circle_outline;
        break;
      case StockStatus.low:
        color = const Color(0xFFF59E0B); // Amber Yellow
        label = 'Заканчивается';
        icon = Icons.warning_amber_rounded;
        break;
      case StockStatus.critical:
        color = const Color(0xFFEF4444); // Bright Red
        label = 'Дефицит!';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
