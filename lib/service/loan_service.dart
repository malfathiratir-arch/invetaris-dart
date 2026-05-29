import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/loan_model.dart';

class LoanService {
  // Fungsi bantuan untuk mengambil token login dari SharedPreferences
Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? ''; 

    // === TAMBAHKAN UTK CEK TOKEN ===
    print("=== CEK KUNCI TOKEN ===");
    print("Token yang dikirim ke BE: '$token'");

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Fungsi utama untuk mengambil data peminjaman dengan sistem Pagination
  Future<Map<String, dynamic>?> fetchLoans({int page = 1, int limit = 5}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/loans?page=$page&limit=$limit');

    try {
      final customHeaders = await _getHeaders();
      final response = await http.get(url, headers: customHeaders);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final paginationData = decoded['data'];
        
        List<dynamic> rawData = paginationData['data'];
        List<LoanModel> loans = rawData.map((e) => LoanModel.fromJson(e)).toList();

        return {
          'loans': loans,
          'totalPage': paginationData['totalPage'],
          'totalData': paginationData['total'], 
        };
      } else {
        print('Gagal fetch loan: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error LoanService: $e');
      return null;
    }
  }

  // Fungsi untuk membuat data peminjaman baru (POST)
  Future<bool> createLoan({
    required int itemId,
    required String name,
    required int totalItem,
    required DateTime date,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/loans');

    try {
      final customHeaders = await _getHeaders();
      
      final response = await http.post(
        url,
        headers: customHeaders,
        body: jsonEncode({
          'item_id': itemId,
          'name': name,
          'total_item': totalItem,
          'date': date.toIso8601String(), 
        }),
      );

      if (response.statusCode == 201) {
        print('Sukses menambahkan data peminjaman');
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        print('Gagal menambahkan loan: ${decoded['message']}');
        return false;
      }
    } catch (e) {
      print('Error pada createLoan: $e');
      return false;
    }
  }
}