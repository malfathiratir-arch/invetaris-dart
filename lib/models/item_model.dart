import 'dart:io';

class ItemModel {
  final int id;
  final String name;
  final int stock;
  final String? imageUrl; // Menampung link gambar dari backend
  final File? localImage; // Menampung gambar dari image picker (untuk preview)

  ItemModel({
    required this.id,
    required this.name,
    required this.stock,
    this.imageUrl,
    this.localImage,
  });

  // Fungsi untuk mem-parsing data JSON dari respons Express.js
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['image'] ?? json['image_url'];

    if (rawImageUrl != null) {
      // Menyelaraskan IP & Port agar sama dengan ApiConfig kamu (Emulator 10.0.2.2 port 3000)
      rawImageUrl = rawImageUrl.replaceAll('localhost', '10.0.2.2');
      rawImageUrl = rawImageUrl.replaceAll(':5000', ':3000'); 
    }

    // Solusi Anti-Crash: Konversi paksa ke int jika backend mengirimkan String atau alternatif nama field
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0;
    } else if (json['id_barang'] != null) {
      parsedId = json['id_barang'] is int ? json['id_barang'] : int.tryParse(json['id_barang'].toString()) ?? 0;
    }

    int parsedStock = 0;
    var stockValue = json['stock'] ?? json['stok'] ?? json['qty'] ?? 0;
    parsedStock = stockValue is int ? stockValue : int.tryParse(stockValue.toString()) ?? 0;

    return ItemModel(
      id: parsedId,
      name: json['name'] ?? json['nama'] ?? json['nama_barang'] ?? 'Tanpa Nama',
      stock: parsedStock,
      imageUrl: rawImageUrl,
    );
  }
}