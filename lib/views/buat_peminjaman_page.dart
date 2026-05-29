import 'package:flutter/material.dart';
import 'package:inventory_apps/widgets/form/build_form_field.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:inventory_apps/service/item_service.dart'; 
import 'package:inventory_apps/service/loan_service.dart';

class BuatPeminjamanPage extends StatefulWidget {
  const BuatPeminjamanPage({super.key});
  @override
  State<BuatPeminjamanPage> createState() => _BuatPeminjamanPageState();
}

class _BuatPeminjamanPageState extends State<BuatPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final jumlahController = TextEditingController();

  // Inisialisasi Service untuk API sesuai panduan
  final LoanService _loanService = LoanService();
  final ItemService _itemService = ItemService(); 

  // Variabel untuk menampung data dari Backend
  List<ItemModel> _itemList = [];
  String _selectedItemName = "Pilih Barang"; // Label khusus untuk UI Dropdown modern
  int? _selectedItemId;
  DateTime _selectedDate = DateTime.now();
  
  // Indikator Loading
  bool _isLoadingItems = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchItemsForDropdown(); // Otomatis ambil data saat halaman dibuka
  }

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  // Fungsi mengambil data barang dari BE (Diubah ke .getItems() agar sinkron dengan Service)
  Future<void> _fetchItemsForDropdown() async {
    setState(() => _isLoadingItems = true);
    try {
      final items = await _itemService.getItems(); // FIX: Menggunakan getItems() sesuai isi ItemService di panduan
      if (items != null) {
        setState(() => _itemList = items);
      }
    } catch (e) {
      debugPrint("Gagal load item: $e");
    }
    setState(() => _isLoadingItems = false);
  }

  // Membuat UI Dropdown Modern menggunakan Bottom Sheet sesuai panduan
  void _showItemPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: MediaQuery.of(context).size.height * 0.5, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Pilih Barang', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _isLoadingItems
                  ? const Center(child: CircularProgressIndicator())
                  : _itemList.isEmpty
                      ? const Center(child: Text("Tidak ada data barang tersedia"))
                      : ListView.builder(
                          itemCount: _itemList.length,
                          itemBuilder: (context, index) {
                            final item = _itemList[index];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedItemId = item.id;
                                  _selectedItemName = item.name;
                                });
                                Navigator.pop(context); 
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB), size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name, 
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stok tersedia: ${item.stock} unit',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Format tanggal untuk UI preview
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  // Membuka Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Logika Submit Peminjaman ke API sesuai panduan
  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih barang terlebih dahulu!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true); 

    // Kirim data ke API via LoanService
    final isSuccess = await _loanService.createLoan(
      itemId: _selectedItemId!,
      name: namaController.text,
      totalItem: int.parse(jumlahController.text),
      date: _selectedDate,
    );

    setState(() => _isSubmitting = false); 

    if (isSuccess) {
      if (!mounted) return;
      // Berhasil: Langsung tutup halaman dan kirim info 'true' ke halaman list (Sesuai Panduan)
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat peminjaman. Cek kembali data atau stok.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF475569)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Buat Peminjaman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Form Peminjaman Baru',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Isi data di bawah untuk mencatat peminjaman barang',
                                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                      const Text(
                        'Informasi Peminjam',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 14),

                      // Nama Peminjam Field
                      buildFormField(
                        controller: namaController,
                        label: 'Nama Peminjam',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Nama peminjam wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),

                      // Custom Dropdown Button Sheet Picker
                      GestureDetector(
                        onTap: _isLoadingItems ? null : _showItemPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 22),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _isLoadingItems ? 'Memuat data...' : _selectedItemName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _selectedItemId == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                    fontWeight: _selectedItemId == null ? FontWeight.normal : FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Jumlah Unit Field
                      buildFormField(
                        controller: jumlahController,
                        label: 'Jumlah Unit',
                        icon: Icons.numbers,
                        isNumber: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                          if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Masukkan angka yang valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tanggal Peminjaman (Date Picker)
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 22),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tanggal Peminjaman',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(_selectedDate),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button dengan Loading State sesuai instruksi panduan
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitPeminjaman,
                          icon: _isSubmitting 
                              ? const SizedBox.shrink() 
                              : const Icon(Icons.send_rounded),
                          label: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'Kirim Peminjaman',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF93C5FD), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}