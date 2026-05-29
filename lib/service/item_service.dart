import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/models/item_model.dart'; // Sudah disesuaikan tanpa 's'
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_apps/config/api_config.dart'; 

class ItemService {
  // Fungsi internal untuk mengambil token dari SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? ''; 

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 1. GET ALL ITEMS (Read)
  Future<List<ItemModel>> getItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];

        return dataList.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // 2. CREATE ITEM (Post dengan Image)
  Future<ItemModel> createItem({
    required String name,
    required String stock,
    required File imageFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    var request = http.MultipartRequest('POST', url);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['stock'] = stock;
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ItemModel.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal menyimpan barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // 3. UPDATE ITEM (Put dengan Image Opsional)
  Future<ItemModel> updateItem({
    required int id,
    required String name,
    required String stock,
    File? newImageFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    var request = http.MultipartRequest('PUT', url);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['stock'] = stock;

    if (newImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', newImageFile.path),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ItemModel.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal memperbarui barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // 4. DELETE ITEM (Delete)
  Future<bool> deleteItem(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    final headers = await _getHeaders();

    http.Response response;

    try {
      response = await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; 
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'Item is already related to a loan') {
        throw Exception('Barang tidak bisa dihapus karena sedang dalam masa peminjaman.');
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menghapus barang.');
      }
    } else {
      throw Exception('Terjadi kesalahan pada server (Error: ${response.statusCode})');
    }
  }

  Future<Object?> fetchItems() async {}
}