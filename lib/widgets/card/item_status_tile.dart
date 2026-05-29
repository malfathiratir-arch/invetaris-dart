import 'package:flutter/material.dart';

class ItemModel {
  final String name;
  final int stock;
  final String status; // 'ok' | 'low' | 'out'

  const ItemModel({
    required this.name,
    required this.stock,
    required this.status,
  });
}

class ItemStatusTile extends StatelessWidget {
  final ItemModel item;

  const ItemStatusTile({super.key, required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'low':
        return const Color(0xFFF59E0B);
      case 'out':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case 'low':
        return 'Menipis';
      case 'out':
        return 'Habis';
      default:
        return 'Tersedia';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder — ganti dengan Image.asset() jika ada gambar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${item.stock} unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
