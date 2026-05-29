import 'package:inventory_apps/models/item_model.dart';

class LoanModel {
  final int id;
  final String name;
  final int totalItem;
  final String date;
  final ItemModel? item;

  LoanModel({
    required this.id,
    required this.name,
    required this.totalItem,
    required this.date,
    this.item,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['date'] != null) {
      DateTime parsedDate = DateTime.parse(json['date']);
      formattedDate =
          "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
    }

    return LoanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      totalItem: json['total_item'] ?? 0,
      date: formattedDate,
      item: json['Item'] != null ? ItemModel.fromJson(json['Item']) : null,
    );
  }
}